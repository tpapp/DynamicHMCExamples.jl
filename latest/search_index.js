var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Overview",
    "title": "Overview",
    "category": "section",
    "text": "This are automatically generated pages from DynamicHMCExamples.jl. Each page is for one example problem, you can study the source directly in the package repository."
},

{
    "location": "example_independent_bernoulli.html#",
    "page": "Estimate Bernoulli draws probabilility",
    "title": "Estimate Bernoulli draws probabilility",
    "category": "page",
    "text": "EditURL = \"https://github.com/tpapp/DynamicHMCExamples.jl/blob/master/src/example_independent_bernoulli.jl\""
},

{
    "location": "example_independent_bernoulli.html#Estimate-Bernoulli-draws-probabilility-1",
    "page": "Estimate Bernoulli draws probabilility",
    "title": "Estimate Bernoulli draws probabilility",
    "category": "section",
    "text": "We estimate a simple model of n independent Bernoulli draws, with probability α. First, we load the packages we use.using TransformVariables\nusing LogDensityProblems\nusing DynamicHMC\nusing MCMCDiagnostics\nusing Parameters\nusing StatisticsThen define a structure to hold the data. For this model, the number of draws equal to 1 is a sufficient statistic.\"\"\"\nToy problem using a Bernoulli distribution.\n\nWe model `n` independent draws from a ``Bernoulli(α)`` distribution.\n\"\"\"\nstruct BernoulliProblem\n    \"Total number of draws in the data.\"\n    n::Int\n    \"Number of draws `==1` in the data\"\n    s::Int\nendThen make the type callable with the parameters as a single argument.  We use decomposition in the arguments, but it could be done inside the function, too.function (problem::BernoulliProblem)((α, )::NamedTuple{(:α, )})\n    @unpack n, s = problem        # extract the data\n    s * log(α) + (n-s) * log(1-α) # log likelihood\nendWe should test this, also, this would be a good place to benchmark and optimize more complicated problems.p = BernoulliProblem(20, 10)\np((α = 0.5, ))Recall that we need totransform from ℝ to the valid parameter domain (0,1) for more efficient sampling, and\ncalculate the derivatives for this transformed mapping.The helper packages TransformVariables and LogDensityProblems take care of this. We use a flat prior (the default, omitted)P = TransformedBayesianProblem(to_tuple((α = to_𝕀,)), p);\n∇P = ForwardDiffLogDensity(P);Finally, we sample from the posterior. chain holds the chain (positions and diagnostic information), while the second returned value is the tuned sampler which would allow continuation of sampling.chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, 1000)To get the posterior for α, we need to use get_position and then transformposterior = transform.(Ref(∇P.transformation), get_position.(chain));Extract the parameter.posterior_α = first.(posterior);check the meanmean(posterior_α)check the effective sample sizeess_α = effective_sample_size(posterior_α)NUTS-specific statisticsNUTS_statistics(chain)This page was generated using Literate.jl."
},

]}
