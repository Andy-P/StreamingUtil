workspace()
using TimeWindowStats
using Base.Test, Datetime
# reload("StreamingUtil")

dt1 = datetime(2015,6,4,7,1,1)
dt2 = dt1 + seconds(2)
dt3 = dt1 + seconds(4)
dt4 = dt1 + seconds(6)

c = Sum{Float64}(5000)
update!(c,1., dt1)
length(c.xs)
@test length(c.xs)== 1
@test length(c.tms)== 1
@test c.v == 1.
@test typeof(c.xs) == Vector{Float64}
@test typeof(c.v) == Float64

update!(c,2., dt2)
@test length(c.xs)== 2
@test length(c.tms)== 2
@test c.v == 3.

update!(c,3., dt3)
@test length(c.xs)== 3
@test length(c.tms)== 3
@test c.v == 6.

update!(c,4., dt4)
@test length(c.xs)== 3
@test length(c.tms)== 3
@test c.v == 9.

update!(c,3., dt4)
@test length(c.xs)== 4
@test length(c.tms)== 4
@test c.v == 12.

c = Sum{Int64}(5000)
update!(c,1, dt1)
length(c.xs)
@test length(c.xs)== 1
@test length(c.tms)== 1
@test c.v == 1
@test typeof(c.xs) == Vector{Int64}
@test typeof(c.v) == Int64

c = Pct{Int64}(5000)
update!(c,1,1, dt1)
@test c.v == 1.
update!(c,0,1, dt2)
@test c.v == .5

c = Mean{Int64}(5000)
update!(c,1, dt1)
@test c.v == 1.
update!(c,2, dt2)
@test c.v == 1.5
update!(c,3., dt3)
@test c.v == 2.
update!(c,4., dt4)
@test c.v == 3.
