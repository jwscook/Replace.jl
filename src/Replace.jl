"""
A macro `@replace` that replaces one function with another in an expression
"""
module Replace

using Cassette

export @replace

function _replace!(ctx::T, mapping) where T
  for (key, value) in mapping
    @eval Cassette.overdub(ctx::$T, fn::typeof($key), args...) = $value(args...)
  end
  return ctx
end

"""
`@replace foo bar` replaces occurences in expression `bar` of the first item of
each iteration of `foo` with the second item in each iteration of `foo`.

```julia
1 == @replace Dict(sin=>cos) sin(0.0)
exp(0.0) + 1 == @replace Dict(sin=>cos, tan=>exp) sin(0.0) + tan(0.0)
```
"""
macro replace(mapping, ex)
  @eval Cassette.@context Ctx
  quote
    ctx = Ctx()
    _replace!(ctx, $(esc(mapping)))
    Cassette.overdub(ctx, () -> $(esc(ex)))
  end
end

"""
`@replace foo bar qux` replaces the function `foo` with the function `bar` where it occurs in expression `qux`

```julia
1 == @replace sin cos sin(0.0)
```
"""
macro replace(this, forthat, inhere)
  quote
    @replace Dict($(esc(this))=>$(esc(forthat))) $(esc(inhere))
  end
end


end
