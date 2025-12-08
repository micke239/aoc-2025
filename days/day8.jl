function readinput()
    s = read("input/day8.txt", String)
    lines = split(s, "\n")
    map(l -> let 
        st = split(l, ",")
        (parse(Int64, st[1]), parse(Int64, st[2]), parse(Int64, st[3]))
    end, lines)
end

function part1(boxes)
    max = 1000
    combos = []
    for i in 1:length(boxes)
        for j in (i+1):length(boxes)
            push!(combos, (boxes[i],boxes[j]))
        end
    end

    sort!(combos, by=combo -> (combo[1][1] - combo[2][1])^2 + (combo[1][2] - combo[2][2])^2 + (combo[1][3] - combo[2][3])^2)

    circuits = []

    for _ in 1:max
        friends = popfirst!(combos)
        (box1, box2) = friends
        circuit1 = findfirst(c -> box1 in c, circuits)
        circuit2 = findfirst(c -> box2 in c, circuits)

        if circuit1 === nothing && circuit2 === nothing
            push!(circuits, Set([box1,box2]))
        elseif circuit1 === nothing
            push!(circuits[circuit2], box1)
        elseif circuit2 === nothing
            push!(circuits[circuit1], box2)
        elseif circuit1 == circuit2
        else
            union!(circuits[circuit1], circuits[circuit2])
            deleteat!(circuits, circuit2)
        end
    end

    lens = map(xpd -> length(xpd), circuits)

    sort!(lens, rev=true)

    x = foldl((x,y) -> x * y, first(lens,3), init=1)

    println(x)
end

function part2(boxes)

    combos = []
    total = length(boxes)

    for i in 1:length(boxes)
        for j in (i+1):length(boxes)
            push!(combos, (boxes[i],boxes[j]))
        end
    end

    sort!(combos, by=combo -> (combo[1][1] - combo[2][1])^2 + (combo[1][2] - combo[2][2])^2 + (combo[1][3] - combo[2][3])^2)

    circuits = []
    lastfriends = nothing
    while isempty(circuits) || length(circuits[1]) != total
        friends = popfirst!(combos)
        lastfriends = friends
        (box1, box2) = friends
        circuit1 = findfirst(c -> box1 in c, circuits)
        circuit2 = findfirst(c -> box2 in c, circuits)

        if circuit1 === nothing && circuit2 === nothing
            push!(circuits, Set([box1,box2]))
        elseif circuit1 === nothing
            push!(circuits[circuit2], box1)
        elseif circuit2 === nothing
            push!(circuits[circuit1], box2)
        elseif circuit1 == circuit2
        else
            union!(circuits[circuit1], circuits[circuit2])
            deleteat!(circuits, circuit2)
        end
    end

    ((x1,_,_),(x2,_,_)) = lastfriends

    println(x1 * x2)
end

input = readinput()

@time part1(input)
@time part2(input)