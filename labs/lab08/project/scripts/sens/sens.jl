using Pkg
using DrWatson
Pkg.activate("../project")
include(srcdir("sir_model.jl"))
using Random, DataFrames, CSV, StatsPlots

tmax = 40.0
u0 = [990, 10, 0]

betas  = [0.03, 0.05, 0.07]
cs     = [5.0, 10.0, 20.0]
gammas = [0.1, 0.25, 0.5]


results = DataFrame(beta=Float64[], c=Float64[], gamma=Float64[],
                    peak_I=Int[], time_peak=Float64[], final_R=Int[])


trajectories = Dict{Tuple{Float64,Float64,Float64}, DataFrame}()

for β in betas, c in cs, γ in gammas
    Random.seed!(1234)
    m = MakeSIRModel(u0, [β, c, γ])
    activate(m)
    sir_run(m, tmax)
    df = out(m)
    trajectories[(β, c, γ)] = df

    peak_I = maximum(df.I)
    idx_peak = argmax(df.I)
    time_peak = df.t[idx_peak]
    final_R = df.R[end]
    push!(results, (β, c, γ, peak_I, time_peak, final_R))
end

CSV.write(datadir("sensitivity_results.csv"), results)
println(results)


p1 = plot(title="Влияние β (c=10, γ=0.25)", xlab="Время", ylab="Инфицированные I(t)")
for β in betas
    df = trajectories[(β, 10.0, 0.25)]
    plot!(p1, df.t, df.I, label="β=$(β)", linewidth=2)
end
savefig(p1, plotsdir("sensitivity_beta.png"))


p2 = plot(title="Влияние c (β=0.05, γ=0.25)", xlab="Время", ylab="Инфицированные I(t)")
for c in cs
    df = trajectories[(0.05, c, 0.25)]
    plot!(p2, df.t, df.I, label="c=$(c)", linewidth=2)
end
savefig(p2, plotsdir("sensitivity_c.png"))


p3 = plot(title="Влияние γ (β=0.05, c=10)", xlab="Время", ylab="Инфицированные I(t)")
for γ in gammas
    df = trajectories[(0.05, 10.0, γ)]
    plot!(p3, df.t, df.I, label="γ=$(γ)", linewidth=2)
end
savefig(p3, plotsdir("sensitivity_gamma.png"))


combined = plot(p1, p2, p3, layout=(1,3), size=(1200, 350))
savefig(combined, plotsdir("sensitivity_all.png"))

println("Графики сохранены в plots/sensitivity_*.png")
