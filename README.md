Keyboard Backlight Color Utility for System76 Oryx Pro
===

## Requirements

- [Julia](https://julialang.org/)
- Superuser privileges on your machine (which you should have)

## Setup

### Building

To make the configuration file parsing a bit faster, this script may utilize a sysimage of [TOML.jl](https://github.com/JuliaLang/TOML.jl). To compile the sysimage, simply run the build script:

```shell
julia ./build.jl
```

This will install a shared object file called `sys_toml.so` into the `build` directory. Note that it may take a while to build the sysimage. Just be patient.

You can also run this script in the REPL if you so desire.

```juliarepl
julia> using Pkg; Pkg.activate(".")

julia> include("./build.jl")
```

However this is all optional.

### Configuring

System76 keyboard backlight dotfiles are stored in `/sys/class/leds/system76::kbd_backlight`. Since `/sys/` is owned
by root, you must `sudo` in order to use these utilities. Here's how to configure your `/etc/sudoers` file to enable this:

1. I recommend creating a folder somewhere to store scripts for `sudo`. I made one at `~/dev/.userscripts/sudo` (I'll refer to this as `SUDO_SCRIPTS` from now on).
1. Inside `SUDO_SCRIPTS`, create a symlink to `kbdcolor.jl` called `kbdcolor`.
1. Open your `/etc/sudoers` file using `sudo visudo`.
1. Add the path to your Julia interpreter to the `secure_path` (mine is in `~/julia-1.3.1/bin`).
1. Add the directive `NOPASSWD: SUDO_SCRIPTS/kbdcolor` to the `sudo` group

After making the changes, your `/etc/sudoers` file should look like:

```
# ...
Defaults secure_path=".../path/to/julia"

# Command alias for scripts that are safe to run as root
Cmnd_Alias SAFE = <SUDO_SCRIPTS>/kbdcolor

# ...

%sudo ALL=(ALL:ALL) ALL, NOPASSWD: SAFE
```

## Running the Utility

To make sure everything's working right, turn on the keyboard backlight (`Fn + Numpad *`), and on the command line, run `sudo kbdcolor rainbow`. This should change the keyboard color to a rainbow pattern (red-green-blue from left to righ). 

### Arguments

The simplest kind of argument is a hexadecimal RGB color code. These are written directly to the keyboard color files. If you pass only one color, it sets the whole keyboard to that color. If you pass two, the first color will be set for the left and right segments of the keyboard, and the second will be set for the middle segment. If you pass three, the first will be set for the left segment of the keyboard, the second for the center, and the third for the right. The 4th argument and onward will be ignored.

Passing colors like this is somewhat inconvenient, so you can also set color macros in the `ColorMacros.toml` file. Colors are set under the `colors` section, and consist of a single hexadecimal RGB color string. You can also set patterns of colors under the `patterns` section. Patterns are just lists of colors (which can correspond to colors you've defined in the `colors` section or can just be RGB color strings). Pattern macros will be expanded to color arguments, so a pattern of two colors will be treated as two color arguments.

```bash
$ sudo kbdcolor FF0000  # Changes color to red for whole keyboard
$ sudo kbdcolor red  # Same as above

$ sudo kbdcolor green blue # Changes left and right colors to green and middle to blue

$ sudo kbdcolor red green blue # Changes colors to red, green, blue
$ sudo kbdcolor rainbow # Same as above
```

### Macro Expansion Order

1. Expand pattern macros to color macros and/or color codes
1. Expand color macros to color codes
1. Take the first three expanded color codes

Macro expansion is *not* recursive, so putting patterns in patterns or patterns in colors will not work.
