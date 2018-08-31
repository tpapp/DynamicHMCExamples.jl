using Test
using DynamicHMCExamples: rel_path
using Random
using Literate
using Documenter

Random.seed!(UInt32[0x57a97f0d, 0x1a38664c, 0x0dddb228, 0x7dbba96f])

# includenbinclude(rel_path("Estimation of a covariance matrix.ipynb"))
# @test all(ESS .≥ 500)

@testset "independent bernoulli" begin
    include(rel_path("independent_bernoulli.jl"))
    @test ess_α ≥ 200
end


# generate using Literate

DOCROOT = rel_path("../docs")
DOCSOURCE = joinpath(DOCROOT, "src")
EXAMPLES = ["independent_bernoulli"]

for example in EXAMPLES
    Literate.markdown(rel_path("$(example).jl"), DOCSOURCE)
end


# render & deploy using Documenter

makedocs(root = DOCROOT,
         modules = Module[],
         format = :html,
         sitename = "DynamicHMCExamples.jl",
         pages = vcat(Any["index.md"],
                      Any["$(example).md" for example in EXAMPLES]))

deploydocs(root = DOCROOT,
           repo = "github.com/tpapp/DynamicHMCExamples.jl.git",
           target = "build",
           osname = "linux",
           julia = "1.0",
           deps = nothing,
           make = nothing)
