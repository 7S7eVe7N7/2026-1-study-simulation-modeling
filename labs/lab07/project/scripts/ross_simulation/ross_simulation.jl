using Pkg
using DrWatson
Pkg.activate("../project")
using StableRNGs
include(srcdir("RossModel.jl"))
using .RossModel
using Statistics
using Plots, DataFrames, CSV
gr(fmt = :png)
default(fmt = :png, size = (800, 500))

N = 10; S = 3; R = 2; LAMBDA = 10.0; MU = 1.0
RUNS = 1
rng = StableRNG(42)

crash_times = Float64[]
for i = 1:RUNS
    t, _ = sim_repair(rng, N, S, R, LAMBDA, MU)
    println("Прогон $i: время падения = $t")
    push!(crash_times, t)
end
avg_crash = mean(crash_times)
println("Среднее время до падения: $avg_crash")

t_crash, log = sim_repair(rng, N, S, R, LAMBDA, MU)

times = [0.0]      # начальное время
working = [N + S]  # начальное число исправных
for (t, delta) in log
    push!(times, t)
    push!(working, working[end] + delta)
end

push!(times, t_crash)
push!(working, working[end])  # после краша не меняется

p = plot(times, working, xlabel="Время", ylabel="Число исправных машин",
         title="Динамика числа исправных машин", legend=false)
mkpath(plotsdir("lab07"))
savefig(p, plotsdir("lab07", "ross_trace.png"))

df = DataFrame(crash_time = crash_times)
CSV.write(datadir("ross_results.csv"), df)

display(p)
