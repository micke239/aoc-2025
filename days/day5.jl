function readinput()
    s = read("input/day5.txt", String)
    lines = split(s, "\n\n")

    fresh = Iterators.map(l -> let
        splitted = split(l, '-')
        from = parse(Int64, splitted[1])
        to = parse(Int64, splitted[2])

        (from, to)
    end, split(lines[1], "\n"))

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
    wip_ranges = []

    for (r_s, r_e) in fresh
        inner_ranges = []

        for (r2_s, r2_e) in wip_ranges
            start_in_range = inRange(r2_s, (r_s, r_e)) 
            end_in_range = inRange(r2_e, (r_s, r_e))
    
            new_ranges = if (start_in_range && end_in_range) 
                []
            elseif (!start_in_range && end_in_range)
                [(r2_s, r_s-1)]
            elseif (start_in_range && !end_in_range)
                [(r_e+1, r2_e)]                
            elseif (r2_s < r_s && r2_e > r_e)
                [(r2_s, r_s-1), (r_e+1, r2_e)]
            else
                [(r2_s, r2_e)]
            end

            for (nr_from, nr_to) in new_ranges
                if (nr_to >= nr_from) 
                    push!(inner_ranges, (nr_from, nr_to))
                end
            end
        end

        push!(inner_ranges, (r_s, r_e))

        wip_ranges = inner_ranges
    end

    summed = sum(r -> begin
        (s, e) = r

        e - s + 1
    end, wip_ranges)

    println(summed)
end

function part2_2(fresh)
    sorted = sort(collect(fresh), by = r -> r[1])

    aggregated = []
    sum = 0
    (accfrom, accto) = popfirst!(sorted)
    for (from, to) in sorted
        if from <= accto
            accto = max(to, accto)
        else
            push!(aggregated, (accfrom, accto))
            sum += accto - accfrom + 1
            accfrom = from
            accto = to
        end
    end
    push!(aggregated, (accfrom, accto))
    sum += accto - accfrom + 1

    println(sum)
end

function part2_3(fresh)
    wip_ranges = []

    for (r_s, r_e) in fresh
        inner_ranges = Iterators.flatmap(r -> begin
            (r2_s, r2_e) = r

            start_in_range = inRange(r2_s, (r_s, r_e)) 
            end_in_range = inRange(r2_e, (r_s, r_e))
    
            new_ranges = if (start_in_range && end_in_range) 
                []
            elseif (!start_in_range && end_in_range)
                [(r2_s, r_s-1)]
            elseif (start_in_range && !end_in_range)
                [(r_e+1, r2_e)]                
            elseif (r2_s < r_s && r2_e > r_e)
                [(r2_s, r_s-1), (r_e+1, r2_e)]
            else
                [(r2_s, r2_e)]
            end
        end, wip_ranges)

        inner_ranges = Iterators.filter(r -> begin
            (r_from, r_to) = r
            r_to >= r_from
        end, inner_ranges)

        wip_ranges = collect(inner_ranges)
        push!(wip_ranges, (r_s, r_e))
    end

    summed = sum(r -> begin
        (s, e) = r

        e - s + 1
    end, wip_ranges)

    println(summed)
end


(fresh, ingredients) = readinput()

@time part1(fresh, ingredients)
@time part1(fresh, ingredients)

println("my first 2")

@time part2(fresh)
@time part2(fresh)

println("another 2")

@time part2_2(fresh)
@time part2_2(fresh)

println("a third 2")

@time part2_3(fresh)
@time part2_3(fresh)