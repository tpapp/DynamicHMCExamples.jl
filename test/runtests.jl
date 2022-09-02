using Test
using DynamicHMCExamples: rel_path
using Random
Random.seed!(UInt32[0x57a97f0d, 0x1a38664c, 0x0dddb228, 0x7dbba96f])

# includenbinclude(rel_path("Estimation of a covariance matrix.ipynb"))
# @test all(ESS .≥ 500)

@testset "independent bernoulli" begin
    include(rel_path("example_independent_bernoulli.jl"))
    @test ess[1] ≥ 1500
    @test R̂[1] ≤ 1.01
end

@testset "linear regression" begin
    include(rel_path("example_linear_regression.jl"))
    @test all(ess .≥ 3000)
    @test all(R̂ .≤ 1.01)
end

@testset "logistic regression" begin
    include(rel_path("example_logistic_regression.jl"))
    @test all(ess .≥ 1500)
    @test all(R̂ .≤ 1.01)
end

@testset "multinomial logistic regression" begin
    include(rel_path("example_multinomial_logistic_regression.jl"))
    @test all(ess .≥ 500)
    @test all(R̂ .≤ 1.01)
end
