# using Pkg
# Pkg.add("DataStructures")

# using DataStructures

function readinput()
    str = read("input/day7.txt", String)
    y = 0
    x = 0
    s = nothing
    x1 = Iterators.flatmap(l -> begin
        y += 1
        x = 0
        Iterators.map(p -> begin
            x += 1
            if p == 'S'
                s = (x,y)
            end
            ((x,y), p)
        end, collect(l))
    end, split(str, "\n"))

    d = collect(x1)

    (s, Dict(d))
end

function printmap(map, beams, split)
    println("hello")
    maxx = maximum(m -> m[1], keys(map))
    maxy = maximum(m -> m[2], keys(map))
    for y in 1:maxy
        for x in 1:maxx
            c = (x,y)
            p = map[c] 
            if (in(c, split))
                print('x')
            elseif (in(c, beams))
                print('|')
            else
                print(p)
            end
        end
        println()
    end
end

global cache = Dict()

function beamIt(beam, map) 
    if (haskey(cache, beam))
        return cache[beam]
    end

    (x,y) = beam
    
    np = (x, y+1)
    
    countered = if !haskey(map, np)
        1
    elseif (map[np] == '.')
        beamIt(np, map)
    elseif (map[np] == '^')
        b = beamIt((x+1, y+1), map)
        g = beamIt((x-1, y+1), map)
        b + g
    else
        1
    end

    cache[beam] = countered

    countered
end

function part1(start, map)
    beams = Set([start])
    visited = Set()
    split = Set()
    s = 0
    while !isempty(beams)
        for beam in beams
            delete!(beams, beam)

            if (beam in visited)
                continue
            end

            push!(visited, beam)

            (x,y) = beam
            np = (x, y+1)
        
            if !haskey(map, np)
            elseif (map[np] == '.')
                push!(beams, np)
            elseif (map[np] == '^')
                push!(split, np)
                push!(beams, (x+1, y+1))
                push!(beams, (x-1, y+1))
            else
            end
        end
    end

    println(length(split))
end

function part2(start, map)
    s = beamIt(start, map)
    println(s)
end

(start, map) = readinput()

@time part1(start, map)
@time part2(start, map)