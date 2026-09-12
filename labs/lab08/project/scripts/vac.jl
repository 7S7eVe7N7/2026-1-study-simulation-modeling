using Pkg
using DrWatson
Pkg.activate("../project")
include(srcdir("sir_model_vac.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]

function run_with_vaccination(fraction)
    Random.seed!(1234)
    m = MakeSIRModel(u0, p)
    activate(m)
    @process vaccinate(m.sim, m, 5.0, fraction)  
    sir_run(m, tmax)
    out(m)
end

df0 = run_with_vaccination(0.0)
df30 = run_with_vaccination(0.3)
df70 = run_with_vaccination(0.7)

@df df0 plot(:t, :I, label="Без вакцинации")
@df df30 plot!(:t, :I, label="30% вакцинировано")
@df df70 plot!(:t, :I, label="70% вакцинировано")
savefig(plotsdir("vaccination.png"))
