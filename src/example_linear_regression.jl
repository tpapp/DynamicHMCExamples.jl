# # Linear regression

# We estimate simple linear regression model with a half-T prior.
# First, we load the packages we use.

using TransformVariables, LogDensityProblems, DynamicHMC, DynamicHMC.Diagnostics
using MCMCDiagnostics
using Parameters, Statistics, Random, Distributions
import ForwardDiff              # use for AD

# Then define a structure to hold the data: observables, covariates, and the degrees of
# freedom for the prior.

"""
Linear regression model ``y ∼ Xβ + ϵ``, where ``ϵ ∼ N(0, σ²)`` IID.

Flat prior for `β`, half-T for `σ`.
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
    loglikelihood(Normal(0, σ), y .- X*β) + logpdf(TDist(ν), σ)
end

# We should test this, also, this would be a good place to benchmark and
# optimize more complicated problems.

N = 100
X = hcat(ones(N), randn(N, 2));
β = [1.0, 2.0, -1.0]
σ = 0.5
y = X*β .+ randn(N) .* σ;
p = LinearRegressionProblem(y, X, 1.0);
p((β = β, σ = σ))

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

results = mcmc_with_warmup(Random.GLOBAL_RNG, ∇P, 1000);

# We use the transformation to obtain the posterior from the chain.

posterior = transform.(t, results.chain);

# Extract the parameter posterior means: `β`,

posterior_β = mean(first, posterior)

# then `σ`:

posterior_σ = mean(last, posterior)

# Effective sample sizes (of untransformed draws)

ess = vec(mapslices(effective_sample_size,
                    DynamicHMC.position_matrix(results.chain);
                    dims = 2))

# NUTS-specific statistics

summarize_tree_statistics(results.tree_statistics)
