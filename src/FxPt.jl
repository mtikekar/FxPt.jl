__precompile__()

module FxPt

import Base: convert, +, -, ==, *, /, typemax, typemin, show, promote_rule
export Fx8

struct Fx8{i, f} <: Real
    x::Int8

    function (::Type{Fx8{i,f}})(x::Integer, _) where {i,f}
        m = 1 << (i+f-1)
        new{i,f}(clamp(x, -m, m-1))
    end

    (::Type{Fx8{i,f}})(x) where {i,f} = convert(Fx8{i,f}, x)
end

convert(::Type{Fx8{i,f}}, x::Integer) where {i,f} = Fx8{i,f}(x << f, 0)
convert(::Type{Fx8{i,f}}, x::AbstractFloat) where {i,f} = Fx8{i,f}(round(Integer, x * (1<<f)), 0)

convert(::Type{T}, x::Fx8{i,f}) where {T <: AbstractFloat, i, f} = T(x.x) / (1 << f)

+(a::Fx8{i,f}, b::Fx8{i,f}) where {i,f} = Fx8{i,f}(Int16(a.x) + Int16(b.x), 0)
-(a::Fx8{i,f}, b::Fx8{i,f}) where {i,f} = Fx8{i,f}(Int16(a.x) - Int16(b.x), 0)
==(a::Fx8{i,f}, b::Fx8{i,f}) where {i,f} = a.x == b.x

function *(a::Fx8{i,f}, b::Fx8{i,f}) where {i,f}
    n = Int16(a.x) * Int16(b.x)
    n >>= f
    Fx8{i,f}(n, 0)
end

function /(a::Fx8{i,f}, b::Fx8{i,f}) where {i,f}
    n = Int16(a.x) << f
    n = div(n, Int16(b.x))
    Fx8{i,f}(n, 0)
end

typemin(::Type{Fx8{i,f}}) where {i,f} = Fx8{i,f}(typemin(Int8), 0)
typemax(::Type{Fx8{i,f}}) where {i,f} = Fx8{i,f}(typemax(Int8), 0)
show(io::IO, x::Fx8{i,f}) where {i,f} = show(io, float(x))

promote_rule(ft::Type{Fx8{i,f}}, ::Type{TI}) where {i,f,TI <: Integer} = Fx8{i,f}
promote_rule(::Type{Fx8{i,f}}, ::Type{TF}) where {i,f,TF <: AbstractFloat} = TF

convert(::Type{Fx8{i1,f}}, x::Fx8{i2,f}) where {i1,i2,f} = Fx8{i1,f}(x.x, 0)

end
