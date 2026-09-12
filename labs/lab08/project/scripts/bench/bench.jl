using Pkg
using DrWatson
Pkg.activate("../project")
include(srcdir("sir_model.jl"))
using BenchmarkTools, Random, CSV, DataFrames, Statistics

u0 = [9990, 10, 0]
p  = [0.05, 10.0, 0.25]
tmax = 40.0


run_once() = (m = MakeSIRModel(u0, p); activate(m); sir_run(m, tmax); m)

Random.seed!(1234)
t = @benchmark run_once() samples=10 evals=1


println("Медиана:  $(round(median(t).time/1e9, digits=3)) с")
println("Среднее:  $(round(mean(t).time/1e9, digits=3)) с")
println("Память:   $(round(mean(t).memory/1e6, digits=2)) МБ")


CSV.write(datadir("benchmark.csv"), DataFrame(
    median_s = median(t).time/1e9,
    mean_s   = mean(t).time/1e9,
    memory_MB = mean(t).memory/1e6,
))
