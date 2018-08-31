using Test
using DynamicHMCExamples: rel_path
using Random
Random.seed!(UInt32[0x57a97f0d, 0x1a38664c, 0x0dddb228, 0x7dbba96f])

# includenbinclude(rel_path("Estimation of a covariance matrix.ipynb"))
# @test all(ESS .≥ 500)

@testset "independent bernoulli" begin
    include(rel_path("example_independent_bernoulli.jl"))
    @test ess_α ≥ 200
end

include("../docs/make.jl")
