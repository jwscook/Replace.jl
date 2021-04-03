using Replace
using Test
using MacroTools

module Sine
  sine(x) = sin(x)
end
@testset "Replace" begin

@testset "Basic" begin
  @test 1.0 == @replace sin cos sin(0.0)
  @test 0.0 == @replace cos sin cos(0.0)
  # make sure that we haven't clobbered the definition of sin and cos
  @assert cos(0.0) == 1.0 && sin(0.0) == 0.0

  replacement() = pi
  @test pi + exp(0) == @replace rand replacement rand() + exp(0)

  x, y = rand(2)
  mapping = Dict(cos=>sin, tan=>exp)
  f(x, y) = sin(x) + exp(y)
  g(x, y) = cos(x) + tan(y)
  @test f(x, y) == @replace mapping g(x, y)
end

@testset "In a function" begin
  function foo()
    x = @replace cos sin cos(0.0)
  end
  @test foo() == 0.0

  function bar()
    x = @replace Dict(tan=>exp) tan(1.0)
  end
  @test bar() == exp(1.0)
end

@testset "Function declared outside another" begin
  foo(x) = cos(x)
  function bar(x)
    return @replace cos sin foo(x)
  end
  @test bar(0.0) == 0.0

  function baz(x)
    return @replace Dict(cos=>sin) foo(x)
  end
  @test baz(0.0) == 0.0
end

@testset "Inside a module" begin
  @test 1.0 == @replace sin cos Sine.sine(0.0)
end

@testset "How Cassette is supposed to work" begin
  replacement() = true
  original() = false
  @eval Cassette.@context Ctx
  Cassette.overdub(::Ctx, fn::typeof(original), args...) = replacement(args...)
  function functionbarrier()
    x = Cassette.overdub(Ctx(), original)
    return x
  end
  @test functionbarrier()
end

@testset "Some things inside a function" begin
  replacement() = true
  original() = false
  function functionbarrier()
    x = @replace Dict(original=>replacement) original()
    return x
  end
  @test_broken functionbarrier()
  @test functionbarrier()
end

@testset "Everything inside a function" begin
  function functionbarrier()
    replacement() = true
    original() = false
    x = @replace Dict(original=>replacement) original()
    return x
  end
  @test_broken functionbarrier()
  @test functionbarrier()
end


end
