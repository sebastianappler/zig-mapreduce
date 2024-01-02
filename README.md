# Zig MapReduce

## Introduction

This is a MapReduce implementation in Zig inspired by a lab from MIT course
[6.5840 Distributed Systems](https://pdos.csail.mit.edu/6.824/). It's a toy
project to have an excuse to learn Zig :)

The lab can be found at https://pdos.csail.mit.edu/6.824/labs/lab-mr.html

## Getting started

Make sure Zig is in the path and run:
```sh
zig run src/main.zig
# OR
zig build run
```

## Build

By default Zig will build with the host as target. To build for another target
e.g. Windows run:
```sh
zig build -Dtarget=x86_64-windows --summary all
```

To make an optimized build with e.g. `ReleaseFast`:
```sh
zig build -Doptimize=ReleaseFast --summary all
```

Check `zig build --help` for all options.
