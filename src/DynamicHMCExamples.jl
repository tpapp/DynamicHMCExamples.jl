module DynamicHMCExamples

const src_path = @__DIR__

"Relative path using the DynamicHMCExamples src/ directory."
rel_path(parts...) = normpath(joinpath(src_path, parts...))

end # module
