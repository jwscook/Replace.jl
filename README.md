# Replace.jl

![CI](https://github.com/ScottishCovidResponse/Replace.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/ScottishCovidResponse/Replace.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ScottishCovidResponse/Replace.jl)


A macro, @replace, that replaces one function with another in an expression

```julia
julia> using Replace, Distributions,  Measurements

julia> replacement(b::Distributions.Binomial) = mean(b) ± std(b)
replacement (generic function with 1 method)

julia> b = Distributions.Binomial(10, 0.5)
Binomial{Float64}(n=10, p=0.5)

julia> @show rand(b)
rand(b) = 4
4

julia> @show replacement(b)
replacement(b) = 5.0 ± 1.6
5.0 ± 1.6

julia> @show @replace rand replacement rand(b)
#= REPL[6]:1 =# @replace(rand, replacement, rand(b)) = 5.0 ± 1.6
5.0 ± 1.6
```
