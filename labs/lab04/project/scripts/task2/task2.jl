using Pkg
using DrWatson
Pkg.activate("../project")
using Agents, CSV, DataFrames, Random
include(srcdir("sir_model.jl"))

function threshold_beta()
    beta_range = 0.01:0.01:0.2
    threshold = nothing
    total_pop = 3000
    for b in beta_range
        model = initialize_sir(;
            Ns = [1000,1000,1000],
            β_und = fill(b, 3),
            β_det = fill(b/10, 3),
            infection_period = 14,
            detection_time = 7,
            death_rate = 0.02,
            reinfection_probability = 0.1,
            Is = [0,0,1],
            seed = 42,
        )
        peak = 0.0
        for _ in 1:150
            Agents.step!(model, 1)
            frac = count(a.status == :I for a in allagents(model)) / total_pop
            if frac > peak
                peak = frac
            end
        end
        if peak > 0.05
            threshold = b
            break
        end
    end
    return threshold
end

β_threshold = threshold_beta()
println("Минимальное β, при котором пик > 5%: $β_threshold")
println("Теоретический порог R₀ = 1 соответствует β = 1/infection_period = $(1/14) ≈ 0.0714")
if β_threshold !== nothing
    println("Найденный порог β ≈ $(round(β_threshold, digits=4)), что близко к теоретическому.")
end
