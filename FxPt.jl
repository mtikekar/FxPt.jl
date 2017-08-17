__precompile__()
module FxPt

import Base: convert, +, -, ==, *, /, typemax, typemin, show, promote_rule

struct FxPt{i, f} <: Real
    x::Int8

    function (::Type{FxPt{i,f}})(x::Integer, _) where {i,f}
        m = 1 << (i+f-1)
        new{i,f}(clamp(x, -m, m-1))
    end

    (::Type{FxPt{i,f}})(x) where {i,f} = convert(FxPt{i,f}, x)
end

convert(::Type{FxPt{i,f}}, x::Integer) where {i,f} = FxPt{i,f}(x << f, 0)
convert(::Type{FxPt{i,f}}, x::AbstractFloat) where {i,f} = FxPt{i,f}(round(Integer, x * (1<<f)), 0)

convert(::Type{T}, x::FxPt{i,f}) where {T <: AbstractFloat, i, f} = T(x.x) / (1 << f)

+(a::FxPt{i,f}, b::FxPt{i,f}) where {i,f} = FxPt{i,f}(Int16(a.x) + Int16(b.x), 0)
-(a::FxPt{i,f}, b::FxPt{i,f}) where {i,f} = FxPt{i,f}(Int16(a.x) - Int16(b.x), 0)
==(a::FxPt{i,f}, b::FxPt{i,f}) where {i,f} = a.x == b.x

function *(a::FxPt{i,f}, b::FxPt{i,f}) where {i,f}
    n = Int16(a.x) * Int16(b.x)
    n >>= f
    FxPt{i,f}(n, 0)
end

function /(a::FxPt{i,f}, b::FxPt{i,f}) where {i,f}
    n = Int16(a.x) << f
    n = div(n, Int16(b.x))
    FxPt{i,f}(n, 0)
end

typemin(::Type{FxPt{i,f}}) where {i,f} = FxPt{i,f}(typemin(Int8), 0)
typemax(::Type{FxPt{i,f}}) where {i,f} = FxPt{i,f}(typemax(Int8), 0)
show(io::IO, x::FxPt{i,f}) where {i,f} = show(io, float(x))

promote_rule(ft::Type{FxPt{i,f}}, ::Type{TI}) where {i,f,TI <: Integer} = FxPt{i,f}
promote_rule(::Type{FxPt{i,f}}, ::Type{TF}) where {i,f,TF <: AbstractFloat} = TF

convert(::Type{FxPt{i1,f}}, x::FxPt{i2,f}) where {i1,i2,f} = FxPt{i1,f}(x.x, 0)

end
