module StreamingUtil
using Datetime

export Sum,Pct,Mean,update!

abstract TimeWindowStats

type Sum{T} <:TimeWindowStats
    tm::Int64
    xs::Vector{T}
    tms::Vector{DateTime}
    v::T # value
    Sum(time::Int64) = new(time,T[],DateTime[],zero(T))
end

function update!{T}(stat::Sum, v::T, tm::DateTime)
    n = length(stat.xs)
    reduced = zero(T)
    while (length(stat.xs)>0) && (tm - stat.tms[1] > stat.tm)
#         println("removing $(stat.tms[1]), $(stat.xs[1])")
        reduced += stat.xs[1]
        shift!(stat.tms)
        shift!(stat.xs)
    end
    stat.v += v - reduced
    push!(stat.tms,tm)
    push!(stat.xs,v)
    return stat
end

type Mean{T} <:TimeWindowStats
    tm::Int64
    n::Sum{T} # nominator
    d::Sum{T} # denominator (count)
    v::Float64 # value
    Mean(time::Int64) = new(time, Sum{T}(time), Sum{Int64}(time), zero(T))
end

function update!{T}(stat::Mean, n::T, tm::DateTime)
    update!(stat.n, n, tm)
    update!(stat.d, 1, tm)
    stat.v = stat.n.v / stat.d.v
    return stat
end

type Pct{T} <:TimeWindowStats
    tm::Int64
    n::Sum{T} # nominator
    d::Sum{T} # denominator
    v::Float64 # value
    Pct(time::Int64) = new(time, Sum{T}(time), Sum{T}(time), zero(T))
end

function update!{T}(stat::Pct, n::T, d::T, tm::DateTime)
    update!(stat.n, n, tm)
    update!(stat.d, d, tm)
    stat.v = stat.d!=0? stat.n.v/stat.d.v:zero(T)
    return stat
end

end # module
