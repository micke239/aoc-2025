function readinput()
    s = read("input/day1.txt", String)
    splitted = split(s, "\n")
    return map(xs -> (xs[1:1], xs[2:end]), splitted)
end

function part1(input) 
    res = 0
    pos = 50

    for x in input
        rotate = parse(Int32, x[2])

        if (x[1] == "R")
            pos += rotate
        else
            pos -= rotate
        end
        
        pos %= 100

        if (pos == 0)
            res+=1
        elseif (pos < 0)
            pos = 100 + pos
        end
        
    end

    println(res)
end

function part2(input)
    res = 0
    pos = 50

    for x in input
        s_pos = pos
        rotate = parse(Int32, x[2])

        if (x[1] == "R")
            pos += rotate
        else
            pos -= rotate
        end

        res += abs(div(pos, 100))
        pos = pos % 100

        if (x[1] == "L" && pos == 0)
            res += 1
        elseif (pos < 0)
            if (s_pos != 0)
                res += 1
            end
            pos = 100 + pos
        end
    end

    println(res)
end

input = readinput()

@time part1(input)
@time part2(input)