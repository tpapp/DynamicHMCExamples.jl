var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "#Overview-1",
    "page": "Overview",
    "title": "Overview",
    "category": "section",
    "text": "This are automatically generated pages from DynamicHMCExamples.jl. Each page is for one example problem, you can study the source directly in the package repository."
},

{
    "location": "example_independent_bernoulli/#",
    "page": "Estimate Bernoulli draws probabilility",
    "title": "Estimate Bernoulli draws probabilility",
    "category": "page",
    "text": "EditURL = \"https://github.com/tpapp/DynamicHMCExamples.jl/blob/master/src/example_independent_bernoulli.jl\""
},

{
    "location": "example_independent_bernoulli/#Estimate-Bernoulli-draws-probabilility-1",
    "page": "Estimate Bernoulli draws probabilility",
    "title": "Estimate Bernoulli draws probabilility",
    "category": "section",
    "text": "We estimate a simple model of n independent Bernoulli draws, with probability α. First, we load the packages we use.using TransformVariables\nusing LogDensityProblems\nusing DynamicHMC\nusing MCMCDiagnostics\nusing Parameters\nusing StatisticsThen define a structure to hold the data. For this model, the number of draws equal to 1 is a sufficient statistic.\"\"\"\nToy problem using a Bernoulli distribution.\n\nWe model `n` independent draws from a ``Bernoulli(α)`` distribution.\n\"\"\"\nstruct BernoulliProblem\n    \"Total number of draws in the data.\"\n    n::Int\n    \"Number of draws `==1` in the data\"\n    s::Int\nendThen make the type callable with the parameters as a single argument.  We use decomposition in the arguments, but it could be done inside the function, too.function (problem::BernoulliProblem)((α, )::NamedTuple{(:α, )})\n    @unpack n, s = problem        # extract the datalog likelihood: the constant log(combinations(n, s)) term has been dropped since it is irrelevant to sampling.    s * log(α) + (n-s) * log(1-α)\nendWe should test this, also, this would be a good place to benchmark and optimize more complicated problems.p = BernoulliProblem(20, 10)\np((α = 0.5, ))Recall that we need totransform from ℝ to the valid parameter domain (0,1) for more efficient sampling, and\ncalculate the derivatives for this transformed mapping.The helper packages TransformVariables and LogDensityProblems take care of this. We use a flat prior (the default, omitted)P = TransformedLogDensity(as((α = as𝕀,)), p)\n∇P = ADgradient(:ForwardDiff, P);Finally, we sample from the posterior. chain holds the chain (positions and diagnostic information), while the second returned value is the tuned sampler which would allow continuation of sampling.chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, 1000)To get the posterior for α, we need to use get_position and then transformposterior = transform.(Ref(∇P.transformation), get_position.(chain));Extract the parameter.posterior_α = first.(posterior);check the meanmean(posterior_α)check the effective sample sizeess_α = effective_sample_size(posterior_α)NUTS-specific statisticsNUTS_statistics(chain)This page was generated using Literate.jl."
},

{
    "location": "example_linear_regression/#",
    "page": "Linear regression",
    "title": "Linear regression",
    "category": "page",
    "text": "EditURL = \"https://github.com/tpapp/DynamicHMCExamples.jl/blob/master/src/example_linear_regression.jl\""
},

{
    "location": "example_linear_regression/#Linear-regression-1",
    "page": "Linear regression",
    "title": "Linear regression",
    "category": "section",
    "text": "We estimate simple linear regression model with a half-T prior. First, we load the packages we use.using TransformVariables, LogDensityProblems, DynamicHMC, MCMCDiagnostics,\n    Parameters, Statistics, Distributions, ForwardDiffThen define a structure to hold the data: observables, covariates, and the degrees of freedom for the prior.\"\"\"\nLinear regression model ``y ∼ Xβ + ϵ``, where ``ϵ ∼ N(0, σ²)`` IID.\n\nFlat prior for `β`, half-T for `σ`.\n\"\"\"\nstruct LinearRegressionProblem{TY <: AbstractVector, TX <: AbstractMatrix,\n                               Tν <: Real}\n    \"Observations.\"\n    y::TY\n    \"Covariates\"\n    X::TX\n    \"Degrees of freedom for prior.\"\n    ν::Tν\nendThen make the type callable with the parameters as a single argument.function (problem::LinearRegressionProblem)(θ)\n    @unpack y, X, ν = problem   # extract the data\n    @unpack β, σ = θ            # works on the named tuple too\n    loglikelihood(Normal(0, σ), y .- X*β) + logpdf(TDist(ν), σ)\nendWe should test this, also, this would be a good place to benchmark and optimize more complicated problems.N = 100\nX = hcat(ones(N), randn(N, 2));\nβ = [1.0, 2.0, -1.0]\nσ = 0.5\ny = X*β .+ randn(N) .* σ;\np = LinearRegressionProblem(y, X, 1.0);\np((β = β, σ = σ))For this problem, we write a function to return the transformation (as it varies with the number of covariates).problem_transformation(p::LinearRegressionProblem) =\n    as((β = as(Array, size(p.X, 2)), σ = asℝ₊))Wrap the problem with a transformation, then use Flux for the gradient.P = TransformedLogDensity(problem_transformation(p), p)\n∇P = ADgradient(:ForwardDiff, P);Finally, we sample from the posterior. chain holds the chain (positions and diagnostic information), while the second returned value is the tuned sampler which would allow continuation of sampling.chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, 1000);We use the transformation to obtain the posterior from the chain.posterior = transform.(Ref(∇P.transformation), get_position.(chain));Extract the parameter posterior means: β,posterior_β = mean(first, posterior)then σ:posterior_σ = mean(last, posterior)Effective sample sizes (of untransformed draws)ess = mapslices(effective_sample_size,\n                get_position_matrix(chain); dims = 1)NUTS-specific statisticsNUTS_statistics(chain)This page was generated using Literate.jl."
},

{
    "location": "example_logistic_regression/#",
    "page": "Logistic regression",
    "title": "Logistic regression",
    "category": "page",
    "text": "EditURL = \"https://github.com/tpapp/DynamicHMCExamples.jl/blob/master/src/example_logistic_regression.jl\""
},

{
    "location": "example_logistic_regression/#Logistic-regression-1",
    "page": "Logistic regression",
    "title": "Logistic regression",
    "category": "section",
    "text": "using TransformVariables, LogDensityProblems, DynamicHMC, MCMCDiagnostics, Parameters,\n    Distributions, Statistics, StatsFuns, ForwardDiff\n\n\"\"\"\nLogistic regression.\n\nFor each draw, ``logit(Pr(yᵢ == 1)) ∼ Xᵢ β``. Uses a `β ∼ Normal(0, σ)` prior.\n\n`X` is supposed to include the `1`s for the intercept.\n\"\"\"\nstruct LogisticRegression{Ty, TX, Tσ}\n    y::Ty\n    X::TX\n    σ::Tσ\nend\n\nfunction (problem::LogisticRegression)(θ)\n    @unpack y, X, σ = problem\n    @unpack β = θ\n    loglik = sum(logpdf.(Bernoulli.(logistic.(X*β)), y))\n    logpri = sum(logpdf.(Ref(Normal(0, σ)), β))\n    loglik + logpri\nendMake up parameters, generate data using random draws.N = 1000\nβ = [1.0, 2.0]\nX = hcat(ones(N), randn(N))\ny = rand.(Bernoulli.(logistic.(X*β)));Create a problem, apply a transformation, then use automatic differentiation.p = LogisticRegression(y, X, 10.0)   # data and (vague) priors\nt = as((β = as(Array, length(β)), )) # identity transformation, just to get the dimension\nP = TransformedLogDensity(t, p)      # transformed\n∇P = ADgradient(:ForwardDiff, P)Sample using NUTS, random starting point.chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, 1000);Extract the posterior. Here the transformation was not really necessary.β_posterior = first.(transform.(Ref(∇P.transformation), get_position.(chain)));Check that we recover the parameters.mean(β_posterior)Quantilesqs = [0.05, 0.25, 0.5, 0.75, 0.95]\nquantile(first.(β_posterior), qs)\n\nquantile(last.(β_posterior), qs)Check that mixing is good.ess = vec(mapslices(effective_sample_size, reduce(hcat, β_posterior); dims = 2))This page was generated using Literate.jl."
},

]}
