# DynamicHMCExamples.jl

![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![build](https://github.com/tpapp/DynamicHMCExamples.jl/workflows/CI/badge.svg)](https://github.com/tpapp/DynamicHMCExamples.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/DynamicHMCExamples.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/DynamicHMCExamples.jl?branch=master)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://tpapp.github.io/DynamicHMCExamples.jl/stable)

This repository contains examples for my the libraries related Bayesian inference I maintain. Install this with

```julia
pkg> add https://github.com/tpapp/DynamicHMCExamples.jl
```

which will download a working and tested set of versions. Optionally, you can `pkg> up` after this.

The examples are in the [src/](./src/) directory as Julia source files, marked up for [Literate.jl](https://github.com/fredrikekre/Literate.jl). This means that they can be executed directly, but they are also available as [webpages](https://tpapp.github.io/DynamicHMCExamples.jl/latest).

Note that this is *not* an introduction to Bayesian inference, merely an implementation in Julia using a certain approach that I find advantageous. The focus is on coding the (log) posterior as a function, then passing this to a modern Hamiltonian Monte Carlo sampler (a variant of NUTS, as described in [Betancourt (2017)](https://arxiv.org/abs/1701.02434).

The advantage of this approach is that you can [debug](https://github.com/JuliaDebug/Debugger.jl), [benchmark](https://github.com/JuliaCI/BenchmarkTools.jl), and [optimize](https://docs.julialang.org/en/v1/manual/performance-tips/) your posterior calculations directly using the tools in Julia, like any other Julia code. In contrast to other libraries,

1. you don't need to use a DSL,
2. you are not formulating your model as a directed acyclic graph,
3. and you can calculate some are all derivatives manually.

The implicit requirement for this approach is of course that you need to understand how to translate your model to a posterior function and code it in Julia.

The examples show how to do transformations and automatic differentiation with related libraries that wrap a log posterior function. However, if you prefer, you can use other approaches, such as manually coding the transformations or symbolic differentiation.
