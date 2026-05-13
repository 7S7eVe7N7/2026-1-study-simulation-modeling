##!/usr/bin/env julia
## test_setup.jl
using DrWatson
@quickactivate "project"
println("✅ Проект активирован: ", projectdir())
## Проверка пакетов
packages = [
    "DrWatson", 
    "DifferentialEquations", 
    "Plots", 
    "DataFrames", 
    "CSV", 
    "JLD2", 
    "Literate", 
    "IJulia", 
    "BenchmarkTools", 
    "Quarto" 
    ]
println("\nПроверка пакетов:")
for pkg in packages
    try
        eval(Meta.parse("using $pkg"))
        println(" ✓ $pkg")
        catch e
        println(" ✗ $pkg: Ошибка загрузки")
    end
end
## Проверка путей
println("\nСтруктура проекта:")
println(" Корень: ", projectdir())
println(" Данные: ", datadir())
println(" Скрипты: ", srcdir())
println(" Графики: ", plotsdir())
