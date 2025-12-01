function readinput()
    s = read("input/day2.txt", String)
    lines = split(s, "\n")
    return map(xs -> xs, lines)
end

function part1(input) 
    res = 0

    println(res)
end

function part2(input)
    res = 0

    println(res)
end

input = readinput()

@time part1(input)
@time part2(input)