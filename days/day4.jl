function readinput()
    s = read("input/day4.txt", String)
    lines = split(s, "\n")
    x = 0
    y = 0
    mapped = map(xs -> let 
        y+=1
        x=0
        map(i -> let 
            x+=1
            ((x, y), i)
        end, collect(xs))
    end, lines)

    (x, y, Dict(Iterators.flatten(mapped)))
end

function part1(maxx, maxy, input) 
    count=0
    for y in 1:maxy
        for x in 1:maxx
            if (input[(x,y)] != '@') 
                continue
            end

            neighbours = [
                (x-1,y-1),
                (x-1,y),
                (x-1,y+1),
                (x,y-1),
                (x,y+1),
                (x+1,y-1),
                (x+1,y),
                (x+1,y+1),
            ]

            o = filter(n -> if haskey(input, n) input[n] == '@' else false end, neighbours)

            if (length(o) < 4)
                count+=1
            end
        end
    end

    display(count)
end

function part2(maxx,maxy,input)
    prev_input = nothing
    count=0
    while (prev_input != input)
        to_remove = []
        prev_input = input
        for y in 1:maxy
            for x in 1:maxx
                if (input[(x,y)] != '@') 
                    continue
                end

                neighbours = [
                    (x-1,y-1),
                    (x-1,y),
                    (x-1,y+1),
                    (x,y-1),
                    (x,y+1),
                    (x+1,y-1),
                    (x+1,y),
                    (x+1,y+1),
                ]

                o = filter(n -> if haskey(input, n) input[n] == '@' else false end, neighbours)

                if (length(o) < 4)
                    push!(to_remove, (x,y))
                    count+=1
                end
            end
        end

        input = Dict(input)
        for o in to_remove
            input[o] = '.'
        end
    end
    

    display(count)
end

(x, y, input) = readinput()

@time part1(x,y,input)
@time part2(x,y,input)