using Pkg
using DrWatson
Pkg.activate("../project")
include(srcdir("sir_model.jl"))
include(srcdir("sir_model_det.jl"))
using Random, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]
p = [0.05, 10.0, 0.25]

Random.seed!(1234)
m_stoch = MakeSIRModel(u0, p)
activate(m_stoch)
sir_run(m_stoch, tmax)
df_stoch = out(m_stoch)

Random.seed!(1234)
m_det = MakeSIRModel(u0, p)
activate(m_det)
sir_run(m_det, tmax)
df_det = out(m_det)

@df df_stoch plot(:t, :I, label="Стохастическая", xlab="Время", ylab="I")
@df df_det plot!(:t, :I, label="Детерминированная", linestyle=:dash)
savefig(plotsdir("compare_deterministic.png"))
