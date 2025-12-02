function readinput()
    s = read("input/day2.txt", String)
    lines = split(s, ",")
    return map(xs -> map(i -> parse(Int64, i), split(xs,"-")), lines)
end

function findinvalid1(range)
    filter(i -> let 
        s = string(i)

        if (length(s) % 2 != 0) 
            return false
        end
        
        half = div(length(s), 2)

        s[1:half] == s[half+1:end]
    end, range[1]:range[2])
end

function findinvalid2(range)
    filter(i -> let 
        s = string(i)
        s_length = length(s)
        half = div(s_length, 2)

        p = findfirst(is -> let
            if (s_length % is != 0)
                return false
            end 
            partitions = Iterators.partition(s, is)
            allequal(partitions)
        end, 1:half)

        p !== nothing
    end, range[1]:range[2])
end

function part1(input) 
    invalid = map(findinvalid1, input)
    flattened = Iterators.flatten(invalid)
    println(sum(flattened))
end

function part2(input)
    invalid = map(findinvalid2, input)
    flattened = Iterators.flatten(invalid)
    println(sum(flattened))
end

input = readinput()

@time part1(input)
@time part2(input)