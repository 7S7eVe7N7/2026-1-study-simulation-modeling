using Pkg
using DrWatson
Pkg.activate("../project")
using Agents, DataFrames, Plots
include(srcdir("sir_model.jl"))

β_und_hetero = [0.3, 0.6, 0.9]
β_det_hetero = [0.03, 0.06, 0.09]
params = Dict(
    :Ns => [1000, 1000, 1000],
    :β_und => β_und_hetero,
    :β_det => β_det_hetero,
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
)

model = initialize_sir(; params...)
n_steps = 150

city_data = [Dict(:S=>Int[], :I=>Int[], :R=>Int[]) for _ in 1:3]

for t in 1:n_steps
    Agents.step!(model, 1)
    for city in 1:3
        agents_in_city = [a for a in allagents(model) if a.pos == city]
        push!(city_data[city][:S], count(a.status == :S for a in agents_in_city))
        push!(city_data[city][:I], count(a.status == :I for a in agents_in_city))
        push!(city_data[city][:R], count(a.status == :R for a in agents_in_city))
    end
end

p = []
for city in 1:3
    df = DataFrame(S=city_data[city][:S], I=city_data[city][:I], R=city_data[city][:R])
    p_city = plot(1:n_steps, [df.S, df.I, df.R],
                  label=["S" "I" "R"],
                  title="Город $city (β = $(β_und_hetero[city]))",
                  xlabel="Дни", ylabel="Численность")
    push!(p, p_city)
end
plot(p..., layout=(3,1), size=(800, 600))
savefig(plotsdir("task3_heterogeneity.png"))
println("Графики сохранены в plots/task3_heterogeneity.png")
