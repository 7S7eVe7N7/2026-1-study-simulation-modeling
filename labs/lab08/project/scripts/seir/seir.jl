using Pkg
using DrWatson
Pkg.activate("../project")

include(srcdir("sir_model_seir.jl"))
using Random, StatsPlots


tmax = 60.0
u0 = [990, 0, 10, 0]
p  = [0.05, 10.0, 0.25, 0.5]

Random.seed!(1234)

m = MakeSIRModel_seir(u0, p)
activate_seir(m)
sir_run(m, tmax)
df = out(m)

@df df plot(:t, [:S :E :I :R],
            labels = ["S" "E" "I" "R"],
            xlab = "Время",
            ylab = "Численность",
            title = "SEIR модель",
            linewidth = 2)
savefig(plotsdir("seir.png"))

println("График: plots/seir.png")
println("Пик I: ", maximum(df.I), " при t = ", df.t[argmax(df.I)])
println("Итоговое R: ", df.R[end])
