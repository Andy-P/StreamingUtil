module TimeWindowStats

using Dates

export Sum,Pct,Mean,update!

abstract TimeWindowStatistic

type Sum{T} <:TimeWindowStatistic
    tm::Int64
    lastIdx::Int64
    xs::Vector{T}
    tms::Vector{DateTime}
    v::T # value
    Sum(time::Int64) = new(time,0,T[],DateTime[],zero(T))
end

function update!{T}(stat::Sum{T}, v::T, tm::DateTime)
    n = length(stat.xs)
    reduced = zero(T)
    i = 0
    while i < stat.lastIdx && (tm - stat.tms[i+1] > stat.tm)
        i += 1
        reduced += stat.xs[i]
    end

    if i > 0 # shift values if anything needs ot be removed
        stat.tms[1:stat.lastIdx-i] = stat.tms[1+i:stat.lastIdx]
        stat.xs[1:stat.lastIdx-i] = stat.xs[1+i:stat.lastIdx]
        stat.lastIdx -= i
    end

    stat.lastIdx += 1
    if stat.lastIdx <= length(stat.tms)
        stat.tms[stat.lastIdx] = tm
        stat.xs[stat.lastIdx]  = v
    else
        push!(stat.tms,tm)
        push!(stat.xs,v)
    end

    stat.v += v - reduced # calculate and cache latest value
    return stat
end

type Mean{T} <:TimeWindowStatistic
    tm::Int64
    n::Sum{T} # nominator
    v::Float64 # value
    Mean(time::Int64) = new(time, Sum{T}(time), zero(T))
end

function update!{T}(stat::Mean, n::T, tm::DateTime)
    update!(stat.n, n, tm)
    stat.v = stat.n.v / stat.n.lastIdx
    return stat
end

type Pct{T} <:TimeWindowStatistic
    tm::Int64
    n::Sum{T} # nominator
    d::Sum{T} # denominator
    v::Float64 # value
    Pct(time::Int64) = new(time, Sum{T}(time), Sum{T}(time), zero(T))
end

function update!{T}(stat::Pct, n::T, d::T, tm::DateTime)
    update!(stat.n, n, tm)
    update!(stat.d, d, tm)
    stat.v = stat.d!=0? stat.n.v/stat.d.v : zero(T)
    return stat
end

end # module
