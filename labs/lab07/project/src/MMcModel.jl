module MMcModel

using ConcurrentSim
using ResumableFunctions
using Distributions
using StableRNGs
using Statistics

export run_simulation

# Глобальные переменные для текущего прогона
rng = StableRNG(0)
arrival_dist = Exponential(1.0)
service_dist = Exponential(1.0)

# Массивы для сбора статистики (очищаются перед каждым запуском)
const waiting_times = Float64[]
const arrival_times = Float64[]
const departure_times = Float64[]

@resumable function customer(env::Environment, server::Resource, id::Integer, t_a::Float64)
    @yield timeout(env, t_a)
    arrive_time = now(env)
    @yield request(server)
    wait_time = now(env) - arrive_time
    @yield timeout(env, rand(rng, service_dist))
    @yield unlock(server)
    push!(waiting_times, wait_time)
    push!(arrival_times, arrive_time)
    push!(departure_times, now(env))
end

function run_simulation(_rng::StableRNG, c::Int, λ::Float64, μ::Float64, N::Int)
    global rng = _rng
    global arrival_dist = Exponential(1/λ)
    global service_dist = Exponential(1/μ)

    empty!(waiting_times)
    empty!(arrival_times)
    empty!(departure_times)

    sim = Simulation()
    server = Resource(sim, c)

    t = 0.0
    for i = 1:N
        t += rand(rng, arrival_dist)
        @process customer(sim, server, i, t)
    end

    run(sim)
    return copy(waiting_times), copy(arrival_times), copy(departure_times)
end

end # module
