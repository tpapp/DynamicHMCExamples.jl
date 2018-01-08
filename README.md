# DynamicHMCExamples

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/DynamicHMCExamples.jl.svg?branch=master)](https://travis-ci.org/tpapp/DynamicHMCExamples.jl)
[![Coverage Status](https://coveralls.io/repos/tpapp/DynamicHMCExamples.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/DynamicHMCExamples.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/DynamicHMCExamples.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/DynamicHMCExamples.jl?branch=master)

Examples for my libraries for Bayesian inference. They are not (yet) registered, so you need to clone the repositories. You can do this easily by running [`clone-packages.jl`](clone-packages.jl) from this repository.

The examples are in the [src/](./src/) directory as Jupyter notebooks.

Note that this is *not* an introduction to Bayesian inference, merely an implementation in Julia using a certain approach that I find advantageous. The focus is on coding the (log) posterior as a function, then passing this to a modern Hamiltonian Monte Carlo sampler (a variant of NUTS, as described in [Betancourt (2017)](https://arxiv.org/abs/1701.02434).

The advantage of this approach is that you can debug, benchmark, and optimize your posterior calculations directly using the tools in Julia, like any other Julia code. In contrast to [Stan](http://mc-stan.org/), you don't need to use a DSL; in contrast to [Klara.jl](https://github.com/JuliaStats/Klara.jl) and [Mamba.jl](https://github.com/brian-j-smith/Mamba.jl), you are not formulating your model as a directed acyclic graph. The disadvantage is of course that you need to understand how to translate your model to a posterior function and code it in Julia.

The examples show how to do transformations and automatic differentiation with related libraries that wrap a log posterior function. However, if you prefer, you can use other approaches, such as manually coding the transformations or symbolic differentiation.
