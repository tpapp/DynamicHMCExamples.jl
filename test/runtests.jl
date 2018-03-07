using Base.Test
using DynamicHMCExamples: rel_path
using NBInclude

nbinclude(rel_path("Estimation of a covariance matrix.ipynb"))
@test all(ESS .≥ 500)

nbinclude(rel_path("Independent Bernoulli draws.ipynb"))
@test all(ess_α .≥ 200)
