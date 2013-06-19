# Code generation facilities

# type aliases

typealias SymOrNum Union(Symbol, Number)
typealias ArrayOrNumber Union(AbstractArray, Number)
typealias VectorOrNumber Union(AbstractVector, Number)
typealias MatrixOrNumber Union(AbstractMatrix, Number)
typealias AbstractCube{T} AbstractArray{T,3}
typealias CubeOrNumber Union(AbstractCube, Number)

typealias DimSpec Union(Int, (Int, Int))

# element access

get_scalar(x::AbstractArray, i::Int) = x[i]
get_scalar(x::AbstractArray, i::Int, j::Int) = x[i,j]
get_scalar(x::AbstractArray, i::Int, j::Int, k::Int) = x[i,j,k]

get_scalar(x::Number, i::Int) = x
get_scalar(x::Number, i::Int, j::Int) = x
get_scalar(x::Number, i::Int, j::Int, k::Int) = x

# shape inference

map_shape(x1::AbstractArray, x2::AbstractArray) = promote_shape(size(x1), size(x2))
map_shape(x1::AbstractArray, x2::Number) = size(x1)
map_shape(x1::Number, x2::AbstractArray) = size(x2)

function map_length(x1::AbstractArray, x2::AbstractArray)
	if length(x1) != length(x2)
		throw(ArgumentError("Argment lengths must match."))
	end
	length(x1)
end

map_length(x1::AbstractArray, x2::Number) = length(x1)
map_length(x1::Number, x2::AbstractArray) = length(x2)

# value type inference

result_eltype{T}(op::UnaryFunctor, x::AbstractArray{T}) = result_type(op, T)
result_eltype{T1,T2}(op::BinaryFunctor, x1::AbstractArray{T1}, x2::AbstractArray{T2}) = result_type(op, T1, T2)
result_eltype{T1,T2<:Number}(op::BinaryFunctor, x1::AbstractArray{T1}, x2::T2) = result_type(op, T1, T2)
result_eltype{T1<:Number,T2}(op::BinaryFunctor, x1::T1, x2::AbstractArray{T2}) = result_type(op, T1, T2)

# building block generators

type _ParamList end
type _KernelExpr end

gen0(::_ParamList) = :(x::AbstractArray)
gen0(::_KernelExpr, i::Symbol) = :(x[$i])

gen1(::_ParamList) = (:(f::UnaryFunctor), :(x::AbstractArray))
gen1(::_KernelExpr, i::Symbol) = :(evaluate(f, x[$i]))

gen2(::_ParamList) = :(f::BinaryFunctor, x1::ArrayOrNumber, x2::ArrayOrNumber)
gen2(::_KernelExpr, i::Symbol) = :(evaluate(f, get_scalar(x1, $i), get_scalar(x2, $i)))

gen2_fdiff(::_ParamList) = :(f::UnaryFunctor, x1::ArrayOrNumber, x2::ArrayOrNumber)
gen2_fdiff(::_KernelExpr, i::Symbol) = :(evaluate(f, get_scalar(x1, $i) - get_scalar(x2, $i)))


# OLD code-gen devices

_ker_nofun(i::SymOrNum) = :(x[$i])
_ker_nofun(i::SymOrNum, j::SymOrNum) = :(x[$i, $j])
_ker_nofun(i::SymOrNum, j::SymOrNum, l::SymOrNum) = :(x[$i, $j, $l])

_ker_unaryfun(i::SymOrNum) = :(evaluate(f, x[$i]))
_ker_unaryfun(i::SymOrNum, j::SymOrNum) = :(evaluate(f, x[$i, $j]))
_ker_unaryfun(i::SymOrNum, j::SymOrNum, l::SymOrNum) = :(evaluate(f, x[$i, $j, $l]))

_ker_binaryfun(i::SymOrNum) = :(evaluate(f, get_scalar(x1, $i), get_scalar(x2, $i)))
_ker_binaryfun(i::SymOrNum, j::SymOrNum) = :(evaluate(f, get_scalar(x1, $i, $j), get_scalar(x2, $i, $j)))
_ker_binaryfun(i::SymOrNum, j::SymOrNum, l::SymOrNum) = :(evaluate(f, get_scalar(x1, $i, $j, $l), get_scalar(x2, $i, $j, $l)))

_ker_fdiff(i::SymOrNum) = :(evaluate(f, get_scalar(x1, $i) - get_scalar(x2, $i)))
_ker_fdiff(i::SymOrNum, j::SymOrNum) = :(evaluate(f, get_scalar(x1, $i, $j) - get_scalar(x2, $i, $j)))
_ker_fdiff(i::SymOrNum, j::SymOrNum, l::SymOrNum) = :(evaluate(f, get_scalar(x1, $i, $j, $l) - get_scalar(x2, $i, $j, $l)))
