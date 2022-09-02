using DynamicHMCExamples: rel_path
using Literate
using Documenter
using Random
Random.seed!(UInt32[0x57a97f0d, 0x1a38664c, 0x0dddb228, 0x7dbba96f])

####
#### generate using Literate
####


DOCROOT = rel_path("../docs")
DOCSOURCE = joinpath(DOCROOT, "src")
EXAMPLES = ["independent_bernoulli",
            "linear_regression",
            "logistic_regression",
            "multinomial_logistic_regression",
            ]

for example in EXAMPLES
    Literate.markdown(rel_path("example_$(example).jl"), DOCSOURCE)
end

####
#### render & deploy using Documenter
####

makedocs(root = DOCROOT,
         format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
         modules = Module[],
         sitename = "DynamicHMCExamples.jl",
         authors = "Tamás K. Papp",
         strict = true,
         pages = vcat(Any["index.md"],
                      Any["example_$(example).md" for example in EXAMPLES]))

deploydocs(root = DOCROOT,
           repo = "github.com/tpapp/DynamicHMCExamples.jl.git",
           push_preview = true)
