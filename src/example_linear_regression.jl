# # Linear regression

# We estimate simple linear regression model with a half-T prior.
# First, we load the packages we use.

# First, we import DynamicHMC and related libraries,

using TransformVariables, LogDensityProblems, DynamicHMC, TransformedLogDensities

# then some packages that help code the log posterior,

using Parameters, Statistics, Random, Distributions, LinearAlgebra

# then diagnostic and benchmark tools,

using MCMCDiagnosticTools, DynamicHMC.Diagnostics, BenchmarkTools

# and use ForwardDiff for AD since the dimensions is small.

import ForwardDiff

# Then define a structure to hold the data: observables, covariates, and the degrees of
# freedom for the prior.

"""
Linear regression model ``y ∼ Xβ + ϵ``, where ``ϵ ∼ N(0, σ²)`` IID.

Weakly informative prior for `β`, half-T for `σ`.
"""
struct LinearRegressionProblem{TY <: AbstractVector, TX <: AbstractMatrix,
                               Tν <: Real}
    "Observations."
    y::TY
    "Covariates"
    X::TX
    "Degrees of freedom for prior."
    ν::Tν
end

# Then make the type callable with the parameters *as a single argument*.

function (problem::LinearRegressionProblem)(θ)
    @unpack y, X, ν = problem   # extract the data
    @unpack β, σ = θ            # works on the named tuple too
    ϵ_distribution = Normal(0, σ) # the error term
    ℓ_error = mapreduce((y, x) -> logpdf(ϵ_distribution, y - dot(x, β)), +,
                        y, eachrow(X))    # likelihood for error
    ℓ_σ = logpdf(TDist(ν), σ)             # prior for σ
    ℓ_β = loglikelihood(Normal(0, 10), β) # prior for β
    ℓ_error + ℓ_σ + ℓ_β
end

# Make up random data and test the function runs.

N = 100
X = hcat(ones(N), randn(N, 2));
β = [1.0, 2.0, -1.0]
σ = 0.5
y = X*β .+ randn(N) .* σ;
p = LinearRegressionProblem(y, X, 1.0);
p((β = β, σ = σ))

# It is usually a good idea to benchmark and optimize your log posterior code at this stage.
# Above, we have carefully optimized allocations away using `mapreduce`.

@btime p((β = $β, σ = $σ))

# For this problem, we write a function to return the transformation (as it varies with the
# number of covariates).

function problem_transformation(p::LinearRegressionProblem)
    as((β = as(Array, size(p.X, 2)), σ = asℝ₊))
end

# Wrap the problem with a transformation, then use ForwardDiff for the gradient.

t = problem_transformation(p)
P = TransformedLogDensity(t, p)
∇P = ADgradient(:ForwardDiff, P);

# Finally, we sample from the posterior. `chain` holds the chain (positions and
# diagnostic information), while the second returned value is the tuned sampler
# which would allow continuation of sampling.

results = map(_ -> mcmc_with_warmup(Random.default_rng(), ∇P, 1000), 1:5)

# We use the transformation to obtain the posterior from the chain.

posterior = transform.(t, eachcol(pool_posterior_matrices(results)));

# Extract the parameter posterior means: `β`,

posterior_β = mean(first, posterior)

# then `σ`:

posterior_σ = mean(last, posterior)

# Effective sample sizes (of untransformed draws)

ess, R̂ = ess_rhat(stack_posterior_matrices(results))

# summarize NUTS-specific statistics of all chains

summarize_tree_statistics(mapreduce(x -> x.tree_statistics, vcat, results))
