# # Estimate Bernoulli draws probabilility

# We estimate a simple model of ``n`` independent Bernoulli draws, with
# probability ``α``. First, we load the packages we use.

using TransformVariables, LogDensityProblems, DynamicHMC, DynamicHMC.Diagnostics,
    TransformedLogDensities, Parameters, Statistics, Random, MCMCDiagnosticTools
import ForwardDiff              # use for AD

# Then define a structure to hold the data.
# For this model, the number of draws equal to `1` is a sufficient statistic.

"""
Toy problem using a Bernoulli distribution.

We model `n` independent draws from a ``Bernoulli(α)`` distribution.
"""
struct BernoulliProblem
    "Total number of draws in the data."
    n::Int
    "Number of draws `==1` in the data"
    s::Int
end

# Then make the type callable with the parameters *as a single argument*.  We
# use decomposition in the arguments, but it could be done inside the function,
# too.

function (problem::BernoulliProblem)(θ)
    @unpack α = θ               # extract the parameters
    @unpack n, s = problem      # extract the data
    ## log likelihood: the constant log(combinations(n, s)) term
    ## has been dropped since it is irrelevant for posterior sampling.
    s * log(α) + (n-s) * log(1-α)
end

# We should test this, also, this would be a good place to benchmark and
# optimize more complicated problems.

p = BernoulliProblem(20, 10)
p((α = 0.5, ))

# Recall that we need to
#
# 1. transform from ``ℝ`` to the valid parameter domain `(0,1)` for more efficient sampling, and
#
# 2. calculate the derivatives for this transformed mapping.
#
# The helper packages `TransformVariables` and `LogDensityProblems` take care of
# this. We use a flat prior.

t = as((α = as𝕀,))
P = TransformedLogDensity(t, p)
∇P = ADgradient(:ForwardDiff, P);

# Finally, we sample from the posterior. The returned value the posterior matrix, diagnostic
# information, and the tuned sampler which would allow continuation of sampling.

results = [mcmc_with_warmup(Random.default_rng(), ∇P, 1000) for _ in 1:5]

# To get the posterior for ``α``, we need to use the columns of the `posterior_matrix` and
# then transform

posterior = transform.(t, eachcol(pool_posterior_matrices(results)));

# Extract the parameter.

posterior_α = first.(posterior);

# check the mean

mean(posterior_α)

# check the effective sample size

ess, R̂ = ess_rhat(stack_posterior_matrices(results))

# NUTS-specific statistics of the first chain

summarize_tree_statistics(results[1].tree_statistics)
