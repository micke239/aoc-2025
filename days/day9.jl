function readinput()
    s = read("input/day9.txt", String)
    lines = split(s, "\n")
    map(l -> let 
        st = split(l, ",")
        (parse(Int64, st[1]), parse(Int64, st[2]))
    end, lines)
end

function printmap(surface, minx, maxx, miny, maxy)
    for y in miny:maxy
        for x in minx:maxx
            c = (x,y)
            if (c in surface)
                print('#')
            else
                print('.')
            end
        end
        println()
    end
end

inRange = (x, (from,to)) -> from <= x && x <= to 

function part1(boxes)
    combos = []
    for i in 1:length(boxes)
        for j in (i+1):length(boxes)
            push!(combos, (boxes[i],boxes[j]))
        end
    end

    areas = map((b1) -> (b1, (abs(b1[2][1] - b1[1][1])+1)*(abs(b1[2][2] - b1[1][2])+1)), combos)

    println(maximum(l -> l[2], areas))
end

function part2(boxes)
    surface = Set()
    
    maxbox = length(boxes)
    for i in 1:maxbox
        j = if i != maxbox i+1 else 1 end
        
        box1 = boxes[i]
        box2 = boxes[j]
        if (box1[1] == box2[1])
            for y in min(box1[2], box2[2]):max(box1[2], box2[2])
                push!(surface, (box1[1], y))
            end
        else
            for x in min(box1[1], box2[1]):max(box1[1], box2[1])
                push!(surface, (x, box1[2]))
            end
        end
    end

    println(length(surface))

    xs = unique(map(l -> l[1], boxes))
    xs = sort(xs)
    ys = unique(map(l -> l[2], boxes))
    ys = sort(ys)

    boxcheck = Set(boxes)
    lines = Dict()
    for y in ys 
        p_start = nothing
        lines[y] = []
        safe_to = first(xs)
        for x in xs
            if ((x,y) in surface)
                if p_start === nothing
                    p_start = x
                    if (x,y) in boxcheck
                        index = findfirst(l -> l == (x,y), boxes)
                        next = if index == maxbox 1 else index+1 end
                        prev = if index == 1 maxbox else index-1 end

                        if boxes[next][2] == y
                            safe_to = boxes[next][1]
                        else
                            safe_to = boxes[prev][1]
                        end

                    end
                elseif x <= safe_to
                elseif !((x,y) in boxcheck)
                    push!(lines[y], (p_start, x))
                    p_start = nothing
                end
            elseif p_start !== nothing
                push!(lines[y], (p_start, x-1))
            end
        end
    end

    println("lines fixed")

    combos = []
    for i in 1:maxbox
        for j in (i+1):maxbox
            push!(combos, (boxes[i],boxes[j]))
        end
    end

    areas = map((b1) -> (b1, (abs(b1[2][1] - b1[1][1])+1)*(abs(b1[2][2] - b1[1][2])+1)), combos)

    areas = sort(areas, by=l -> l[2], rev=true)

    println("areas sorted")

    areai = findfirst(l -> begin
        ((red1, red2), _) = l

        xrange = min(red1[1], red2[1]):max(red1[1],red2[1])
        yrange = min(red1[2], red2[2]):max(red1[2],red2[2])
        
        for x in xs
            if (!inRange(x, (first(xrange), last(xrange))))
                continue
            end
            curr1 = (x, red1[2])
            curr2 = (x, red2[2])
            blah = !any(line -> inRange(curr1[1], line), lines[curr1[2]])
            bleh = !any(line -> inRange(curr2[1], line), lines[curr2[2]])
            
            if (blah || bleh)
                return false;
            end
        end

        for y in ys
            if (!inRange(y, (first(yrange), last(yrange))))
                continue
            end
            curr1 = (red1[1], y)
            curr2 = (red2[1], y)

            blah = !any(line -> inRange(curr1[1], line), lines[curr1[2]])
            bleh = !any(line -> inRange(curr2[1], line), lines[curr2[2]])

            if (blah || bleh)
                return false;
            end
        end
        
        return true
    end, areas)

    println(areas[areai])
end

input = readinput()

@time part1(input)
@time part2(input)