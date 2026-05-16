# # Параметрическое сканирование M/M/c
#
# Исследуем зависимость среднего времени ожидания от загрузки системы ρ.

using Pkg
using DrWatson
Pkg.activate("../project")
using StableRNGs
include(srcdir("MMcModel.jl"))
using .MMcModel
using Statistics, Plots, DataFrames, CSV
gr(fmt = :png)
default(fmt = :png, size = (800, 500))


# ## Параметры сканирования
c = 2
μ = 0.5
λ_values = 0.1:0.1:0.95
N = 500
rng = StableRNG(123)

results = []
for λ in λ_values
    waiting, _, _ = run_simulation(rng, c, λ, μ, N)
    avg = mean(waiting)
    push!(results, (λ=λ, ρ=λ/(c*μ), avg_wait=avg))
end

df = DataFrame(results)
CSV.write(datadir("mmc_scan.csv"), df)

p = plot(df.ρ, df.avg_wait, marker=:circle,
         xlabel="Загрузка ρ", ylabel="Среднее время ожидания",
         title="Зависимость Wq от ρ (c=$c)")
mkpath(plotsdir("lab07"))
savefig(plotsdir("lab07", "mmc_scan.png"))

# ## График
display(p)
