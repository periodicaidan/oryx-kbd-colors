#! /bin/bash
#=
filedir=`dirname $( realpath $0 )`
exec /usr/bin/env julia \
    --project=$filedir \
    -J ${filedir}/build/sys_toml.so \
    -e "include(popfirst!(ARGS))" \
    ${BASH_SOURCE[0]} $@
=#

using Base.Iterators

""" Gets the real path of a file that may or may not be a symlink """
resolving_links(path::String) = if islink(path) readlink(path) else path end

# If the TOML sysimage isn't being used, include TOML normally.
if !isdefined(Main, :TOML)
    using Pkg; Pkg.instantiate()
    using TOML
end

const SYSTEM76_KBD_BACKLIGHT_DIR = "/sys/class/leds/system76::kbd_backlight/"
const KBD_COLOR_FILES = map(
    f -> joinpath(SYSTEM76_KBD_BACKLIGHT_DIR::String, f), 
    ["color_left", "color_center", "color_right"]
)
const COLOR_MACROS_FILE = joinpath(dirname(resolving_links(@__FILE__)), "ColorMacros.toml")

openwrite(file, contents) = open(f -> write(f, contents), file, "w")

expand_colormacro(config::Dict{AbstractString,Any}, m::String) = 
    get(config["colors"], m, m)

expand_patternmacro(config::Dict{AbstractString,Any}, m::String) =
    map(
        p -> expand_colormacro(config, p), 
        get(config["patterns"], m, [m])
    )

function main() 
    # Parse the color macros from a file
    color_macros = TOML.parsefile(COLOR_MACROS_FILE::String) 

    # Expand the color macros into corresponding hex codes
    expanded_args = map(
        t -> expand_patternmacro(color_macros, t), 
        ARGS
    ) |> flatten

    # Take the first three expanded args 
    # This cycles the args and takes 3, so given N args, the colors will be:
    # N  | L C R 
    # -----------
    # 1  | 1 1 1
    # 2  | 1 2 1
    # 3+ | 1 2 3
    colors = take(expanded_args |> cycle, 3)

    # Finally, write the colors into their respective files 
    foreach(
        kv -> openwrite(kv...),
        zip(KBD_COLOR_FILES::Vector{String}, colors)
    )
end

main()