using Statistics, Random, Distributions, StatsPlots, TransformVariables, LogDensityProblems,
    DynamicHMC, MCMCDiagnosticTools, Parameters, Statistics, Distributions, ForwardDiff,
    LinearAlgebra

# We estimate a simple discrete time stochastic volatility model, using
# several simulated moment conditions, and the asymptotic Gaussian
# likelihood of the moment conditions.

# # Helper functions

# The function below returns the variable (or matrix), lagged p times,
# with the first p rows filled with ones (to avoid divide errors).
# Remember to drop those rows before doing analysis.

function lag(x,p::Int64)
    n = size(x,1)
    lagged_x = zeros(eltype(x),n,p)
    lagged_x = [ones(p); x[1:n-p]]
end

# lags of a vector from 1 to p in a p column array
function lags(x,p)
    n = size(x,1)
    lagged_x = zeros(eltype(x),n,p)
    for i = 1:p
	lagged_x[:,i] = lag(x,i)
    end
    return lagged_x
end

# compute moving average using p most recent values, including current value
function ma(x, p)
    m = similar(x)
    for i = p:size(x,1)
        m[i] = mean(x[i-p+1:i])
    end
    return m
end

# auxiliary model: HAR-RV
# Corsi, Fulvio. "A simple approximate long-memory model
# of realized volatility." Journal of Financial Econometrics 7,
# no. 2 (2009): 174-196.
function HAR(y)
    ylags = lags(y,10)
    X = [ones(size(y,1)) ylags[:,1]  mean(ylags[:,1:4],dims=2) mean(ylags[:,1:10],dims=2)]
    # drop missings
    y = y[11:end]
    X = X[11:end,:]
    βhat = X \ y
    σhat = std(y-X*βhat)
    vcat(βhat,σhat)
end

function aux_stat(y)
    y = abs.(y)
    m = mean(y)
    s = std(y)
    y = (y .- m)./s
    # look for evidence of volatility clusters
    mm = ma(y,5)
    mm = mm[5:end]
    clusters5 = quantile(mm,0.75) / quantile(mm, 0.25)
    mm = ma(y,10)
    mm = mm[10:end]
    clusters10 = quantile(mm,0.75) / quantile(mm, 0.25)
    ϕ = HAR(y)
    vcat(m, s, clusters5, clusters10, ϕ)
end

# For the data generating process, we use a simple discrete time stochastic volatility (SV)
# model.

function SVmodel(σu, ρ, σe, n, shocks_u, shocks_e)
    burnin = size(shocks_u,1) - n
    hlag = 0.0
    h = ρ.*hlag .+ σu.*shocks_u[1] # figure out type
    y = σe.*exp(h./2.0).*shocks_e[1]
    ys = zeros(eltype(y),n)
    for t = 1:burnin+n
        h = ρ.*hlag .+ σu.*shocks_u[t]
        y = σe.*exp(h./2.0).*shocks_e[t]
        if t > burnin
            ys[t-burnin] = y
        end
        hlag = h
    end
    sqrt(n)*aux_stat(ys)
end

# Define a structure for the problem
# Should hold the data and  the parameters of prior distributions.
struct MSM_Problem{Tm <: Vector{Float64}, Tn <: Int, Tshocks_u <: Array{Float64,2},
                   Tshocks_e <: Array{Float64,2}}
    "statistic"
    m::Tm
    "sample size"
    n::Tn
    "shocks"
    shocks_u::Tshocks_u
    shocks_e::Tshocks_e
end

# Make the type callable with the parameters *as a single argument*.
function (problem::MSM_Problem)(θ)
    @unpack m, n, shocks_u, shocks_e = problem   # extract the data
    @unpack σu, ρ, σe = θ         # extract parameters (only one here)
    S = size(shocks_u,2)
    k = size(m,1)
    ms = zeros(eltype(SVmodel(σu, ρ, σe, n, shocks_u[:,1], shocks_e[:,1])), S, k)
    for s = 1:S
        ms[s,:] = SVmodel(σu, ρ, σe, n, shocks_u[:,s], shocks_e[:,s])
    end
    mbar = mean(ms,dims=1)[:]
    Σ = cov(ms)
    x = (m .- mbar)
    logL = try
        logL = -0.5*log(det(Σ)) - 0.5*x'*inv(Σ)*x
    catch
        logL = -Inf
    end
end
# generate data
σu = exp(-0.736/2.0)
ρ = 0.9
σe = 0.363
n = 500 # sample size
burnin = 100
S = 100 # number of simulations
shocks_u = randn(n+burnin,1)
shocks_e = randn(n+burnin,1)
m = SVmodel(σu, ρ, σe, n, shocks_u, shocks_e)
shocks_u = randn(n+burnin,S) # fixed shocks for simulations
shocks_e = randn(n+burnin,S) # fixed shocks for simulations
# original problem, without transformation of parameters
p = MSM_Problem(m, n, shocks_u, shocks_e)
# define the transformation of parameters (in this case, priors are uniform on segments of real line)
# σu ~ U(0,2), ρ ~U(0,1), σe ~ U(0,1)
function problem_transformation(p::MSM_Problem)
    as((σu=as(Real, 0.0, 2.0), ρ=as(Real, 0.0, 1.0) ,σe=as(Real,0.0,1.0)))
end
# Wrap the problem with the transformation
t = problem_transformation(p)
P = TransformedLogDensity(t, p)
# use AD for the gradient
∇P = ADgradient(:ForwardDiff, P)
# Sample from the posterior. `chain` holds the chain (positions and
# diagnostic information), while the second returned value is the tuned sampler
# which would allow continuation of sampling.
n = dimension(problem_transformation(p))
results = mcmc_with_warmup(Random.default_rng(), ∇P, 1000)
# FIXME commented out start values; ϵ=0.2, q = zeros(n), p = ones(n))
# We use the transformation to obtain the posterior from the chain.
posterior = transform.(t, eachcol(pool_posterior_matrices([results])))

# # Plots

# Extract the parameters and plot the posteriors
density_σu = density(map(x -> x.σu, posterior));
density_ρ = density(map(x -> x.ρ, posterior));
density_σe = density(map(x -> x.σe, posterior));
plot(density_σu, density_ρ, density_σe, layout = (3,1), legend = false)
