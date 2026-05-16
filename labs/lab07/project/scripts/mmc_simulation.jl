# # Модель M/M/c: имитационное моделирование
#
# **Цель:** оценить производительность системы массового обслуживания
# с пуассоновским входным потоком и несколькими каналами.

using Pkg
using DrWatson
Pkg.activate("../project")
using StableRNGs
include(srcdir("MMcModel.jl"))
using .MMcModel
using Statistics, Plots, DataFrames, CSV
gr(fmt = :png)
default(fmt = :png, size = (800, 500))

# ## Параметры
c = 2            # число каналов
λ = 0.9          # интенсивность входного потока
μ = 0.5          # интенсивность обслуживания (одного канала)
num_customers = 1000
rng = StableRNG(42)

# ## Запуск симуляции
waiting, arrivals, departures = run_simulation(rng, c, λ, μ, num_customers)

avg_wait = mean(waiting)
println("Среднее время ожидания: $avg_wait")

# ## Гистограмма времени ожидания
p1 = histogram(waiting, bins=30, label="Время ожидания",
               xlabel="Время", ylabel="Частота",
               title="Гистограмма времени ожидания в очереди")

# ## Динамика длины очереди
times = sort(unique([arrivals; departures]))
queue_len = [max(0, count(a -> a <= t, arrivals) - count(d -> d <= t, departures) - c) for t in times]
p2 = plot(times, queue_len, lw=1, xlabel="Время", ylabel="Длина очереди",
          title="Динамика длины очереди")

layout = plot(p1, p2, layout=(2,1), size=(800,600))
mkpath(plotsdir("lab07"))
savefig(layout, plotsdir("lab07", "mmc_simulation.png"))

df = DataFrame(wait_time = waiting)
CSV.write(datadir("mmc_waiting.csv"), df)

# ## График 1
display(p1)

# ## График 2
display(p2)
