function readinput()
    s = read("input/day5.txt", String)
    lines = split(s, "\n\n")

    fresh = Iterators.map(l -> let
        splitted = split(l, '-')
        from = parse(Int64, splitted[1])
        to = parse(Int64, splitted[2])

        (from, to)
    end, split(lines[1], "\n"))

    fresh = Set(fresh)
    ingredients = map(xs -> parse(Int64, xs), split(lines[2], "\n"))


    return (fresh, ingredients)
end

inRange = (x, (from,to)) -> from <= x && x <= to 

function part1(fresh, ingredients) 
    x = count(ingredient -> let 
        any(z -> inRange(ingredient, z), fresh)
    end, ingredients)

    display(x)
end

function part2(fresh)
    ranges = []

    for (r_s, r_e) in fresh
        ranges = Iterators.flatmap(z -> begin 
            (r2_s, r2_e) = z

            start_in_range = inRange(r2_s, (r_s, r_e)) 
            end_in_range = inRange(r2_e, (r_s, r_e))

            if (start_in_range && end_in_range) 
                [nothing]
            elseif (!start_in_range && end_in_range)
                [(r2_s, r_s-1)]
            elseif (start_in_range && !end_in_range)
                [(r_e+1, r2_e)]                
            elseif (r2_s < r_s && r2_e > r_e)
                [(r2_s, r_s-1), (r_e+1, r2_e)]
            else
                [z]
            end

        end, ranges)
        
        ranges = Iterators.filter(r -> r !== nothing, ranges)
        ranges = Iterators.filter(r -> begin
            (s,e) = r
            e >= s
        end, ranges)

        ranges = collect(ranges)

        ranges = if length(ranges) == 0
            [(r_s, r_e)]
        else
            push!(ranges, (r_s, r_e))
        end
    end

    summed = sum(r -> begin
        (s, e) = r

        e - s + 1
    end, ranges)

    println(summed)
end

(fresh, ingredients) = readinput()

@time part1(fresh, ingredients)
@time part2(fresh)