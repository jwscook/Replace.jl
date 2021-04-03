"""
A macro `@replace` that replaces one function with another in an expression
"""
module Replace

using Cassette

export @replace

function _replace!(ctx::T, mapping, EvalModule) where T
  for (key, value) in mapping
    @eval EvalModule function Cassette.overdub(ctx::$T, fn::typeof($key), args...)
      return $value(args...)
    end
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
macro replace(mapping, ex, EvalModule::Module=__module__)
  @eval EvalModule using Cassette
  @eval EvalModule Cassette.@context Ctx
  quote
    ctx = $EvalModule.Ctx()
    _replace!(ctx, $(esc(mapping)), $EvalModule)
    Cassette.@overdub(ctx, $(esc(ex)))
  end
end

"""
`@replace foo bar qux` replaces the function `foo` with the function `bar` where it occurs in expression `qux`

```julia
1 == @replace sin cos sin(0.0)
```
"""
macro replace(this, forthat, inhere, EvalModule::Module=__module__)
  quote
    @replace Dict($(esc(this))=>$(esc(forthat))) $(esc(inhere)) $EvalModule
  end
end


end
