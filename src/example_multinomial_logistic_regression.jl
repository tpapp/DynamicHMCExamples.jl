# # Multinomial logistic regression

using TransformVariables, LogDensityProblems, DynamicHMC, DynamicHMC.Diagnostics,
    TransformedLogDensities,  Parameters, Statistics, Random, Distributions,
    MCMCDiagnosticTools, LogExpFunctions, FillArrays, LinearAlgebra
import ForwardDiff # use for automatic differentiation (AD)

"""
Multinomial logistic regression.

For each draw, ``Pr(yᵢ) ∼ softmax(Xᵢ β)``. Uses a `β ∼ MultivariateNormal(0, σI)` prior.

`X` is supposed to include the `1`s for the intercept.
"""
struct MultinomialLogisticRegression{Ty, TX, Tσ}
    y::Ty
    X::TX
    σ::Tσ
end

function (problem::MultinomialLogisticRegression)(θ)
    @unpack y, X, σ = problem
    @unpack β = θ
    num_rows, num_covariates = size(X)
    num_classes = size(β, 2) + 1
    η = X * hcat(zeros(num_covariates), β) # the first column of all zeros corresponds to the base class
    μ = softmax(η; dims = 2)
    D = MvNormal(Diagonal(Fill(σ ^ 2, num_classes - 1)))
    ℓ_likelihood = mapreduce((μ, y) -> logpdf(Multinomial(1, μ), y), +, eachrow(μ), eachrow(y))
    ℓ_prior = mapreduce(β -> logpdf(D, β), +, eachrow(β))
    ℓ_likelihood + ℓ_prior
end

# Make up parameters, generate data using random draws.
N = 10_000
# There are two covariates. The first one (the column of all ones) is the intercept.
X = hcat(ones(N), randn(N));
# If we have C classes, then for each covariate we need (C - 1) coefficients.
# we consider the first class to be the "base class"
# and then for each of the other classes, we have a coefficient comparing that class to the base class
# In this example, we have four classes, so we need three coefficients for each covariate.
# There are two covariates, so we will have six coefficients in total.
# the rows of β correspond to the covariates
# e.g. the first row of β corresponds to the first covariate (the intercept)
# e.g. the second row of β corresponds to the second covariate
# the columns of β correspond to classes
# recall that we set the first class as our "base class"
# then the jth column of β contains the coefficients comparing the (j+1) class against the first class
# e.g. the first column of β contains coefficients comparing the second class against the first class
# e.g. the second column of β contains coefficients comparing the third class against the first class
# e.g. the third column of β contains coefficients comparing the fourth class against the first class
β_true = [1.0 2.0 3.0;
          4.0 5.0 6.0]
η = X * hcat(zeros(size(β_true, 1)), β_true);
μ = softmax(η; dims = 2);
# y has N rows and C columns
# the rows of y correspond to observations
# the columns of y correspond to classes
y = mapreduce(μ -> permutedims(rand(Multinomial(1, μ))), vcat, eachrow(μ))

# Create a problem, apply a transformation, then use automatic differentiation.
p = MultinomialLogisticRegression(y, X, 100.0) # data and (vague) priors
t = as((β = as(Array, size(β_true)), )) # identity transformation, just to get the dimension
P = TransformedLogDensity(t, p)         # transformed
∇P = ADgradient(:ForwardDiff, P)        # use ForwardDiff for automatic differentiation

# Sample using NUTS, random starting point.
results = map(_ -> mcmc_with_warmup(Random.default_rng(), ∇P, 1000), 1:3)

posterior = transform.(t, eachcol(pool_posterior_matrices(results)));

# Extract the posterior. (Here the transformation was not really necessary).
β_posterior = first.(posterior)

# Check that we recover the parameters.
mean(β_posterior)

function _median(x)
    n = length(x)
    result = similar(first(x))
    for i in eachindex(result)
	result[i] = median([x[j][i] for j = 1:n])
    end
	return result
end

_median(β_posterior)

# Quantiles
qs = [0.05, 0.25, 0.5, 0.75, 0.95]
quantile([β_posterior[i][1, 1] for i in 1:length(β_posterior)], qs)
quantile([β_posterior[i][1, 2] for i in 1:length(β_posterior)], qs)
quantile([β_posterior[i][1, 3] for i in 1:length(β_posterior)], qs)
quantile([β_posterior[i][2, 1] for i in 1:length(β_posterior)], qs)
quantile([β_posterior[i][2, 2] for i in 1:length(β_posterior)], qs)
quantile([β_posterior[i][2, 3] for i in 1:length(β_posterior)], qs)

# Check that mixing is good.
ess, R̂ = ess_rhat(stack_posterior_matrices(results))
