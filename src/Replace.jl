"""
A macro `@replace` that replaces one function with another in an expression
"""
module Replace

using Cassette

export @replace

"""
`@replace foo bar qux` replaces the function `foo` with the function `bar` where it occurs in expression `qux`

```julia
1 == @replace sin cos sin(0.0)
```
"""
macro replace(this, forthat, inhere)
  @eval Cassette.@context Ctx
  @eval Cassette.overdub(ctx::Ctx, fn::typeof($this), args...) = ctx.metadata(args...)
  quote
    Cassette.overdub(Ctx(metadata=$(esc(forthat))), () -> $(esc(inhere)))
  end
end

function _replace!(ctx::T, mapping) where T
  for (key, value) in mapping
    @eval Cassette.overdub(ctx::$T, fn::typeof($key), args...) = $value(args...)
  end
  return ctx
end

macro replace(mapping, ex)
  @eval Cassette.@context Ctx
  quote
    ctx = Ctx()
    _replace!(ctx, $(esc(mapping)))
    Cassette.overdub(ctx, () -> $(esc(ex)))
  end
end

end
