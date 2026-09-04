using Pkg
using DrWatson
Pkg.activate("../project")
using Agents, DataFrames, Plots, Statistics
include(srcdir("sir_model.jl"))

# Параметры по умолчанию
params = Dict(
    :Ns => [1000, 1000, 1000],
    :β_und => [0.5, 0.5, 0.5],
    :β_det => [0.05, 0.05, 0.05],
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
    :n_steps => 100,
)

model = initialize_sir(; params...)

# Сбор данных
times = 1:params[:n_steps]
S_vals = Vector{Int}(undef, params[:n_steps])
I_vals = similar(S_vals)
R_vals = similar(S_vals)

for t in 1:params[:n_steps]
    Agents.step!(model, 1)
    S_vals[t] = count(a.status == :S for a in allagents(model))
    I_vals[t] = count(a.status == :I for a in allagents(model))
    R_vals[t] = count(a.status == :R for a in allagents(model))
end

# График
plot(times, S_vals, label="S (Восприимчивые)", xlabel="Дни", ylabel="Численность")
plot!(times, I_vals, label="I (Инфицированные)")
plot!(times, R_vals, label="R (Выздоровевшие)")
savefig(plotsdir("task1_basic_dynamics.png"))
println("График сохранён в plots/task1_basic_dynamics.png")

# Расчёт R₀
β = params[:β_und][1]
infection_period = params[:infection_period]
γ = 1 / infection_period
R0 = β / γ  # = β * infection_period

println("R₀ = β/γ = $β / $γ = $R0")

# Сравнение с наблюдаемой динамикой
total_pop = sum(params[:Ns])
peak_I = maximum(I_vals)
peak_frac = peak_I / total_pop
println("Пик инфицированных: $peak_I (доля = $(round(peak_frac, digits=4)))")

if R0 > 1
    println("R₀ > 1, эпидемия развивается (пик > 5% популяции).")
else
    println("R₀ ≤ 1, эпидемия не развивается.")
end
