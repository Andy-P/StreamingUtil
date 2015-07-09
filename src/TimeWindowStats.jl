module TimeWindowStats

using Dates

export Sum, update!, Pct, Mean

abstract TimeWindowStatistic

type Sum<:TimeWindowStatistic
    tm::Int64
    size::Int64 # size of the array including empty cells
    len::Int64 # number of values in the calculation
    tail::Int64 # index of last value
    head::Int64 # index of last value
    tms::Vector{DateTime}
    xs::Vector
    v # value
    Sum(time::Int64, size::Int64=100) = new(time, size, 0, 0, 0, fill(DateTime(1900,1,1,0,0,0),size),[])
end

function update!(s::Sum, v, tm::DateTime)

    # initalization
    reducedCnt = 0
    reducedAmt = zero(typeof(v))
    arrayFull　= false
    nextHead = s.head+1 <= s.size? s.head+1:1

    if s.tail != 0
        i = s.tail
#         msg = tm - s.tms[i] > s.tm? "reduce":"no-reduce"

        while tm - s.tms[i] > s.tm && reducedCnt < s.len
            reducedAmt += s.xs[i]
            reducedCnt += 1
            i = i < s.size?i+1:1
#             println("  reduced $(s.len) $(int64(tm - s.tms[i-1])) reducedCnt $reducedCnt i=$(i-1) $(s.tms[i-1]) $(s.xs[i-1])")
        end
#         println("     $msg i=$i reduced $reducedAmt")
        s.tail = i

    else  # only happens during initialization
        s.tail = 1
        s.xs = zeros(typeof(v), s.size)
        s.v = zero(typeof(v))
    end

    s.len -= reducedCnt
    arrayFull = s.len + 1 >= s.size
#     println("    arrayFull $arrayFull")

    if !arrayFull
        s.xs[nextHead] = v
        s.tms[nextHead] = tm
        s.head = nextHead
    else
        newSize = iceil(s.size*1.05) # increase size by 5%
        newValues = zeros(typeof(v),newSize)
        newDates  = fill(DateTime(1900,1,1,0,0,0),newSize)
        s.size = newSize
#         println("Array full! size=$(s.size) newSize=$(newSize) head=$(s.head) tail=$(s.tail) nextHead=$(nextHead)")
        if  s.head > s.tail
            newValues[1:s.len] = s.xs[s.tail:s.head]
            newDates[1:s.len] = s.tms[s.tail:s.head]
        else
#             println("Reversed $(s.tail)  $(s.head)  $(s.len)")
            newValues[1:s.len] = vcat(s.xs[s.tail:end],s.xs[1:s.head])
            newDates[1:s.len]  = vcat(s.tms[s.tail:end],s.tms[1:s.head])
#             println("Reversed done")
        end
        s.xs = newValues
        s.tms = newDates
        s.tail = 1
        s.head = s.len+1
        s.xs[s.head] = v
        s.tms[s.head] = tm
#         println("Array full! tail=$(s.tail) head=$(s.head) nextHead=$(nextHead) newSize=$newSize")
    end

    s.v += v - reducedAmt # calculate and cache latest value
    s.len += 1
    return s
end

type Mean <:TimeWindowStatistic
    tm::Int64
    n::Sum # nominator
    v::Float64 # value
    Mean(time::Int64) = new(time, Sum(time), 0)
end

function update!(s::Mean, n, tm::DateTime)
    update!(s.n, n, tm)
    s.v = s.n.v / s.n.len
    return s
end

type Pct<:TimeWindowStatistic
    tm::Int64
    n::Sum # nominator
    d::Sum # denominator
    v::Float64 # value
    Pct(time::Int64, size::Int64=100) = new(time, Sum(time,size), Sum(time,size), 0)
end

function update!(s::Pct, n, d, tm::DateTime)
    update!(s.n, n, tm)
    update!(s.d, d, tm)
    s.v = s.d ==0?: 0: s.n.v/s.d.v
    return s
end

end # module
