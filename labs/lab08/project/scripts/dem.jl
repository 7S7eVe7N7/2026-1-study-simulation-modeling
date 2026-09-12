using Pkg
using DrWatson
Pkg.activate("../project")
include(srcdir("sir_model_dem.jl"))
using Random, StatsPlots

tmax = 100.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25, 0.01, 0.01]  # β, c, γ, μ, ν

Random.seed!(1234)

m = MakeSIRModel_demography(u0, p)
activate_demography(m)
sir_run(m, tmax)  
df = out(m)

@df df plot(:t, [:S :I :R], labels=["S" "I" "R"], xlab="Время", ylab="Численность")

savefig(plotsdir("demography.png"))
