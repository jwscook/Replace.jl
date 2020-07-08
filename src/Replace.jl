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
    _replace(f, $(esc(forthat))) = Cassette.overdub(Ctx(metadata=$(esc(forthat))), f)
    _replace(() -> $(esc(inhere)), $(esc(forthat)))
  end
end

end
