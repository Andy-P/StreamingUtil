module TimeWindowStats

using Dates

export Sum, update!, Pct, Mean

abstract TimeWindowStatistic

type Sum<:TimeWindowStatistic
    tm::Int64
    size::Int64
    tail::Int64
    head::Int64
    xs::Vector
    tms::Vector{DateTime}
    v # value
    Sum(time::Int64, size::Int64=100) = new(time, size, 0, 0, zeros(size), Array(DateTime,size), 0)
    Sum(T::Type, time::Int64, size::Int64=100) = new(time, size, 0, 0, zeros(T,size), Array(DateTime, size), zero(T))
end

function update!{T}(stat::Sum, v::T, tm::DateTime)
#     n = length(stat.xs)
    reduced = zero(T)

    arrayFull　= false
    nextHead = stat.head+1 <= stat.size? stat.head+1:1
    i = stat.tail
    if stat.tail ==0
        stat.tail = 1
    else
        while tm - stat.tms[i] > stat.tm
            reduced += stat.xs[i]
#             println("reducing stat.xs[$(i)] v=$(stat.xs[i]) reduced $reduced")
            i = i < stat.size?i+1:1
        end
        stat.tail = i
        arrayFull = nextHead == stat.tail
    end

    if !arrayFull
        stat.xs[nextHead] = v
        stat.tms[nextHead] = tm
        stat.head = nextHead
    else
        newSize = iceil(stat.size*1.05) # increase size by 5%
        newValues = zeros(T,newSize)
        newDates  = Array(DateTime,newSize)
#         println("Array full! size=$(stat.size) newSize=$(newSize) head=$(stat.head) tail=$(stat.tail) nextHead=$(nextHead)")
        if  stat.head > stat.tail
            newValues[1:stat.size] = stat.xs[stat.tail:stat.head]
            newDates[1:stat.size] = stat.tms[stat.tail:stat.head]
        else
            newValues[1:stat.size] = vcat(stat.xs[stat.tail:end],stat.xs[1:stat.head])
            newDates[1:stat.size]  = vcat(stat.tms[stat.tail:end],stat.tms[1:stat.head])
        end
        stat.xs = newValues
        stat.tms = newDates
        stat.tail = 1
        stat.head = stat.size+1
        stat.xs[stat.head] = v
        stat.tms[stat.head] = tm
        stat.size = newSize
#         println("Array full! tail=$(stat.tail) head=$(stat.head) nextHead=$(nextHead) newSize=$newSize")
    end

    stat.v += v - reduced # calculate and cache latest value
    return stat
end

type Mean <:TimeWindowStatistic
    tm::Int64
    n::Sum # nominator
    v::Float64 # value
    Mean(time::Int64) = new(time, Sum(time), 0)
    Mean(T::Type, time::Int64) = new(time, Sum(T,time), zero(T))
end

function update!{T}(stat::Mean, n::T, tm::DateTime)
    update!(stat.n, n, tm)
    len = stat.n.tail <= stat.n.head? stat.n.head - stat.n.tail + 1 : stat.n.size - stat.n.tail + stat.n.head + 1
    stat.v = stat.n.v / len
    return stat
end

type Pct<:TimeWindowStatistic
    tm::Int64
    n::Sum # nominator
    d::Sum # denominator
    v::Float64 # value
    Pct(time::Int64) = new(time, Sum(time), Sum(time), 0)
    Pct(T::Type, time::Int64) = new(time, Sum(T,time), Sum(T,time), zero(T))
end

function update!{T}(stat::Pct, n::T, d::T, tm::DateTime)
    update!(stat.n, n, tm)
    update!(stat.d, d, tm)
    stat.v = stat.d!=0? stat.n.v/stat.d.v : zero(T)
    return stat
end

end # module
