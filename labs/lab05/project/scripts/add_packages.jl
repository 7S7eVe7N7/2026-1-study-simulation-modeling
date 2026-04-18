#!/usr/bin/env julia
# scripts/add_packages.jl

using Pkg
Pkg.activate(".")   # активируем окружение проекта

packages = [
    "DrWatson",
    "OrdinaryDiffEq", # для решения ОДУ (детерминированное моделирование)
    "JLD2",
    "BenchmarkTools",
    "Plots",
    "DataFrames",
    "CSV",
    "Random",
    "LinearAlgebra",
    "Literate",
    "IJulia",
    "Quarto"
]

Pkg.add(packages)
