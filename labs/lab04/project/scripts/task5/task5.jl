using Pkg
using DrWatson
Pkg.activate("../project")
using Agents, DataFrames, Plots, Statistics
include(srcdir("sir_model_quarantine.jl"))

function run_quarantine_simulation(threshold; n_steps = 150)
    model = initialize_sir_quarantine(;
        Ns = [1000, 1000, 1000],
        β_und = [0.5, 0.5, 0.5],
        β_det = [0.05, 0.05, 0.05],
        infection_period = 14,
        detection_time = 7,
        death_rate = 0.02,
        reinfection_probability = 0.1,
        Is = [0, 0, 1],
        seed = 42,
        quarantine_threshold = threshold,
    )

    S_vals = Int[]
    I_vals = Int[]
    R_vals = Int[]
    total_vals = Int[]
    closed_status = []

    for step in 1:n_steps

        for city in 1:model.C
            infected_frac = get_infected_fraction(model, city)
            if infected_frac > model.quarantine_threshold
                model.closed_cities[city] = true
            end
        end

        Agents.step!(model, 1)

        push!(S_vals, count(a.status == :S for a in allagents(model)))
        push!(I_vals, count(a.status == :I for a in allagents(model)))
        push!(R_vals, count(a.status == :R for a in allagents(model)))
        push!(total_vals, nagents(model))
        push!(closed_status, copy(model.closed_cities))
    end

    return (S = S_vals, I = I_vals, R = R_vals, total = total_vals,
            closed = closed_status)
end

base = run_quarantine_simulation(1.0)
quar = run_quarantine_simulation(0.05)
quar_10 = run_quarantine_simulation(0.10)
quar_20 = run_quarantine_simulation(0.20)

total_pop = 3000
deaths_base = total_pop - base.total[end]
deaths_quar = total_pop - quar.total[end]
deaths_10  = total_pop - quar_10.total[end]
deaths_20  = total_pop - quar_20.total[end]

println("=== Сравнение смертности ===")
println("Без карантина: $deaths_base умерших")
println("Карантин при 5%:  $deaths_quar умерших (снижение на $(round((deaths_base - deaths_quar)/deaths_base*100, digits=2))%)")
println("Карантин при 10%: $deaths_10 умерших (снижение на $(round((deaths_base - deaths_10)/deaths_base*100, digits=2))%)")
println("Карантин при 20%: $deaths_20 умерших (снижение на $(round((deaths_base - deaths_20)/deaths_base*100, digits=2))%)")

p = plot(title = "Сравнение карантинных мер", xlabel = "Дни", ylabel = "Количество инфицированных")
plot!(p, 1:150, base.I, label = "Без карантина", linewidth = 2)
plot!(p, 1:150, quar.I, label = "Карантин при 5%", linestyle = :dash, linewidth = 2)
plot!(p, 1:150, quar_10.I, label = "Карантин при 10%", linestyle = :dot, linewidth = 2)
plot!(p, 1:150, quar_20.I, label = "Карантин при 20%", linestyle = :dashdot, linewidth = 2)
savefig(p, plotsdir("task5_quarantine_comparison.png"))
println("График сохранён в plots/task5_quarantine_comparison.png")

n_days = length(quar.closed)
n_cities = 3
closed_matrix = zeros(Int, n_days, n_cities)
for (day, closed_vec) in enumerate(quar.closed)
    for city in 1:n_cities
        closed_matrix[day, city] = closed_vec[city] ? 1 : 0
    end
end

heatmap(closed_matrix', title = "Закрытие городов (порог 5%)",
        xlabel = "День", ylabel = "Город", colorbar = false)
savefig(plotsdir("task5_closed_cities.png"))
println("Тепловая карта закрытых городов сохранена в plots/task5_closed_cities.png")
