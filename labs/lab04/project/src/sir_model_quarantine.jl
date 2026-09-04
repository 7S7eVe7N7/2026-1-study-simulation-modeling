using Agents, Random
using Agents.Graphs
using StatsBase: sample, Weights
using Distributions: Poisson
using DrWatson: @dict

@agent struct Person(GraphAgent)
    days_infected::Int
    status::Symbol
end

function initialize_sir_quarantine(;
    Ns = [1000, 1000, 1000],
    migration_rates = nothing,
    β_und = [0.5, 0.5, 0.5],
    β_det = [0.05, 0.05, 0.05],
    infection_period = 14,
    detection_time = 7,
    death_rate = 0.02,
    reinfection_probability = 0.1,
    Is = [0, 0, 1],
    seed = 42,
    quarantine_threshold = 0.1,
)
    rng = Xoshiro(seed)
    C = length(Ns)

    if migration_rates == nothing
        migration_rates = zeros(C, C)
        for i in 1:C
            for j in 1:C
                migration_rates[i, j] = (Ns[i] + Ns[j]) / Ns[i]
            end
        end
        for i in 1:C
            migration_rates[i, :] ./= sum(migration_rates[i, :])
        end
    end

    properties = @dict(
        Ns,
        β_und,
        β_det,
        migration_rates,
        infection_period,
        detection_time,
        death_rate,
        reinfection_probability,
        C,
        quarantine_threshold,
        closed_cities = falses(C),
        rng = rng   # <--- добавляем rng в свойства
    )

    space = GraphSpace(complete_graph(C))
    model = StandardABM(Person, space; properties, rng,
                        agent_step! = sir_agent_step_quarantine!)

    for city in 1:C
        for _ in 1:Ns[city]
            add_agent!(city, model, 0, :S)
        end
    end

    for city in 1:C
        if Is[city] > 0
            city_agents = ids_in_position(city, model)
            infected_ids = sample(rng, city_agents, Is[city]; replace = false)
            for id in infected_ids
                agent = model[id]
                agent.status = :I
                agent.days_infected = 1
            end
        end
    end

    return model
end

function sir_agent_step_quarantine!(agent, model)
    current_city = agent.pos
    if !model.closed_cities[current_city]
        migrate!(agent, model)
    end

    if agent.status == :I
        transmit!(agent, model)
        agent.days_infected += 1
    end

    recover_or_die!(agent, model)
end

function migrate!(agent, model)
    current_city = agent.pos
    probs = model.migration_rates[current_city, :]
    target = sample(model.rng, 1:model.C, Weights(probs))
    if target ≠ current_city
        move_agent!(agent, target, model)
    end
end

function transmit!(agent, model)
    rate = if agent.days_infected < model.detection_time
        model.β_und[agent.pos]
    else
        model.β_det[agent.pos]
    end
    n_infections = rand(model.rng, Poisson(rate))
    n_infections == 0 && return nothing

    neighbors = [a for a in agents_in_position(agent.pos, model) if a.id != agent.id]
    shuffle!(model.rng, neighbors)

    for contact in neighbors
        if contact.status == :S
            contact.status = :I
            contact.days_infected = 1
            n_infections -= 1
        elseif contact.status == :R && rand(model.rng) <= model.reinfection_probability
            contact.status = :I
            contact.days_infected = 1
            n_infections -= 1
        end
        n_infections == 0 && return nothing
    end
end

function recover_or_die!(agent, model)
    if agent.status == :I && agent.days_infected >= model.infection_period
        if rand(model.rng) <= model.death_rate
            remove_agent!(agent, model)
        else
            agent.status = :R
            agent.days_infected = 0
        end
    end
end

function get_infected_fraction(model, city)
    agents = [a for a in allagents(model) if a.pos == city]
    isempty(agents) && return 0.0
    return count(a.status == :I for a in agents) / length(agents)
end
