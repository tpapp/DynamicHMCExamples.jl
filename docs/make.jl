using DynamicHMCExamples: rel_path
using Literate
using Documenter
using Random
Random.seed!(UInt32[0x57a97f0d, 0x1a38664c, 0x0dddb228, 0x7dbba96f])


# generate using Literate

DOCROOT = rel_path("../docs")
DOCSOURCE = joinpath(DOCROOT, "src")
EXAMPLES = ["independent_bernoulli"]

for example in EXAMPLES
    Literate.markdown(rel_path("example_$(example).jl"), DOCSOURCE)
end


# render & deploy using Documenter

makedocs(root = DOCROOT,
         modules = Module[],
         format = :html,
         sitename = "DynamicHMCExamples.jl",
         pages = vcat(Any["index.md"],
                      Any["example_$(example).md" for example in EXAMPLES]))

deploydocs(root = DOCROOT,
           repo = "github.com/tpapp/DynamicHMCExamples.jl.git",
           target = "build",
           osname = "linux",
           julia = "1.0",
           deps = nothing,
           make = nothing)
