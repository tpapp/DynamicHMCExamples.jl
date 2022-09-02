# # Logistic regression

# First, we import DynamicHMC and related libraries,

using TransformVariables, LogDensityProblems, DynamicHMC, TransformedLogDensities

# then some packages that help code the log posterior,

using Parameters, Statistics, Random, Distributions, LinearAlgebra, StatsFuns, LogExpFunctions

# then diagnostic and benchmark tools,

using MCMCDiagnosticTools, BenchmarkTools

# and use ForwardDiff for AD since the dimensions is small.

import ForwardDiff

"""
Logistic regression.

For each draw, ``logit(Pr(yᵢ == 1)) ∼ Xᵢ β``. Uses a `β ∼ Normal(0, σ)` prior.

`X` is supposed to include the `1`s for the intercept.
"""
struct LogisticRegression{Ty, TX, Tσ}
    y::Ty
    X::TX
    σ::Tσ
end

function (problem::LogisticRegression)(θ)
    @unpack y, X, σ = problem
    @unpack β = θ
    ℓ_y = mapreduce((y, x) -> logpdf(Bernoulli(logistic(dot(x, β))), y), +, y, eachrow(X))
    ℓ_β =  loglikelihood(Normal(0, σ), β)
    ℓ_y + ℓ_β
end

# Make up parameters, generate data using random draws.

N = 1000
β = [1.0, 2.0]
X = hcat(ones(N), randn(N))
y = rand.(Bernoulli.(logistic.(X*β)));

# Create a problem, apply a transformation, then use automatic differentiation.

p = LogisticRegression(y, X, 10.0)   # data and (vague) priors
t = as((β = as(Array, length(β)), )) # identity transformation, just to get the dimension
P = TransformedLogDensity(t, p)      # transformed
∇P = ADgradient(:ForwardDiff, P)

# Benchmark

@btime p((β = $β,))

# Sample using NUTS, random starting point.

results = map(_ -> mcmc_with_warmup(Random.default_rng(), ∇P, 1000), 1:5)

# Extract the posterior. (Here the transformation was not really necessary).

β_posterior = first.(transform.(t, eachcol(pool_posterior_matrices(results))))

# Check that we recover the parameters.

mean(β_posterior)

# Quantiles

qs = [0.05, 0.25, 0.5, 0.75, 0.95]
quantile(first.(β_posterior), qs)

quantile(last.(β_posterior), qs)

# Check that mixing is good.

ess, R̂ = ess_rhat(stack_posterior_matrices(results))
