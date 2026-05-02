#!/usr/bin/env julia
using Pkg
Pkg.activate(".")

packages = [
    "DrWatson",
    "AlgebraicPetri",
    "Catlab",
    "OrdinaryDiffEq",
    "Plots",
    "DataFrames",
    "CSV",
    "Random",
    "Literate",
    "IJulia",
    "Quarto"
]

Pkg.add(packages)
