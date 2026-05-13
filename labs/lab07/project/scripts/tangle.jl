#!/usr/bin/env julia
# tangle.jl - Генератор отчетов из Literate-скриптов

using DrWatson
@quickactivate "project"

using Literate

function main()
    if length(ARGS) == 0
        println("""
        Использование: julia tangle.jl <путь_к_скрипту>

        Пример: julia tangle.jl scripts/dining_philosophers.jl
        """)
        return
    end

    script_path = ARGS[1]
    if !isfile(script_path)
        error("Файл не найден: $script_path")
    end

    script_dir = dirname(script_path)
    script_name = splitext(basename(script_path))[1]

    println("Генерация из: $script_path")

    # Чистый скрипт (без комментариев)
    out_script_dir = scriptsdir(script_name)
    Literate.script(script_path, out_script_dir; credit=false)
    println("  ✓ Чистый скрипт: $(out_script_dir)/$(script_name).jl")

    # Quarto-документ
    quarto_dir = projectdir("markdown", script_name)
    Literate.markdown(script_path, quarto_dir;
        flavor = Literate.QuartoFlavor(),
        name = script_name,
        credit = false)
    println("  ✓ Quarto: $(quarto_dir)/$(script_name).qmd")

    # Jupyter notebook
    notebooks_dir = projectdir("notebooks", script_name)
    Literate.notebook(script_path, notebooks_dir;
        name = script_name,
        execute = false,
        credit = false)
    println("  ✓ Notebook: $(notebooks_dir)/$(script_name).ipynb")

    println("\nГотово!")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
