workspace()
using TimeWindowStats
using Base.Test, Dates
# reload("StreamingUtil")
dt1 = DateTime(2015,6,4,7,1,1)
dt2 = dt1 + Second(2)
dt3 = dt1 + Second(4)
dt4 = dt1 + Second(5)
dt5 = dt1 + Second(8)

c = Sum(5000,4)
update!(c,1., dt1)
@test c.head == 1
@test c.tail == 1
@test c.v == 1.
@test typeof(c.xs) == Vector{Float64}
@test typeof(c.v) == Float64

update!(c,2., dt2)
@test c.head == 2
@test c.tail == 1
@test c.v == 3.

update!(c,3., dt3)
@test c.head == 3
@test c.tail == 1
@test c.v == 6.

update!(c,4., dt4)
@test c.head == 4
@test c.tail == 1
@test c.size == 4
@test c.v == 10.

update!(c,5., dt4)
@test c.head == 5
@test c.tail == 1
@test c.size == 5
@test c.v == 15.

update!(c,6., dt5)
@test c.head == 1
@test c.tail == 3
@test c.size == 5
@test c.v == 18.

update!(c,7., dt5)
@test c.head == 2
@test c.tail == 3
@test c.size == 5
@test c.v == 25.

update!(c,8., dt5)
@test c.head == 6
@test c.tail == 1
@test c.size == 6
@test c.v == 33.

update!(c,9., dt5)
@test c.head == 7
@test c.tail == 1
@test c.size == 7
@test c.v == 42.

c = Sum(Int64,5000)
update!(c,1, dt1)
@test c.v == 1
@test typeof(c.xs) == Vector{Int64}
@test typeof(c.v) == Int64

c = Pct(Int64,5000)
update!(c,1,1, dt1)
@test c.v == 1.
update!(c,0,1, dt2)
@test c.v == .5

c = Mean(Int64,5000)
update!(c,1, dt1)
@test c.v == 1.
update!(c,2, dt2)
@test c.v == 1.5
update!(c,3, dt3)
@test c.v == 2.
update!(c,4, dt4)
@test c.v == 2.5
update!(c,5, dt5)
@test c.v == 4.
