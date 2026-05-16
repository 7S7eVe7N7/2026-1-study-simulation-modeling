module RossModel

using ConcurrentSim
using ResumableFunctions
using Distributions
using StableRNGs

export sim_repair

# Глобальные параметры и лог событий
rng = StableRNG(0)
N = 10
S = 3
R = 2
LAMBDA = 100.0
MU = 1.0
F = Exponential(LAMBDA)
G = Exponential(MU)

# Лог событий: (время, изменение числа исправных машин)
event_log = Tuple{Float64, Int}[]

@resumable function machine(env, repair_facility, spares)
    while true
        try
            @yield timeout(env, Inf)
        catch
        end
        @yield timeout(env, rand(rng, F))   # отказ
        t_fail = now(env)
        push!(event_log, (t_fail, -1))      # одна машина выходит из строя
        get_spare = take!(spares)
        @yield get_spare | timeout(env)
        if state(get_spare) != ConcurrentSim.idle
            @yield interrupt(value(get_spare))
        else
            throw(StopSimulation("No more spares!"))
        end
        @yield request(repair_facility)      # начало ремонта
        @yield timeout(env, rand(rng, G))    # ремонт
        t_repaired = now(env)
        @yield unlock(repair_facility)
        @yield put!(spares, active_process(env))
        push!(event_log, (t_repaired, +1))   # машина возвращается в строй
    end
end

@resumable function start_sim(env, repair_facility, spares)
    for _ = 1:N
        proc = @process machine(env, repair_facility, spares)
        @yield interrupt(proc)
    end
    for _ = 1:S
        proc = @process machine(env, repair_facility, spares)
        @yield put!(spares, proc)
    end
end

function sim_repair(_rng::StableRNG, _N::Int, _S::Int, _R::Int, _LAMBDA::Float64, _MU::Float64)
    global rng = _rng
    global N, S, R, LAMBDA, MU = _N, _S, _R, _LAMBDA, _MU
    global F = Exponential(LAMBDA)
    global G = Exponential(MU)
    empty!(event_log)

    sim = Simulation()
    repair_facility = Resource(sim, R)
    spares = Store{Process}(sim)
    @process start_sim(sim, repair_facility, spares)
    msg = run(sim)
    return now(sim), copy(event_log)
end

end # module
