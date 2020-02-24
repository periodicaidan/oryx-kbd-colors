using PackageCompiler

create_sysimage(:TOML, sysimage_path="./build/sys_toml.so", precompile_execution_file="./build/precompile_toml.jl")