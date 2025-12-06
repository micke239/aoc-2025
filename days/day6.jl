function readinput()
    s = read("input/day6.txt", String)

    map(l -> filter(il -> il != "", split(l, " ")), split(s, "\n"))
end

function part1(input)
    sum = 0
    for i in 1:length(input[1])
        op = input[length(input)][i]

        n = if op == "*" 1 else 0 end;
        for j in 1:(length(input)-1)
            x = parse(Int64, input[j][i])
            if op == "*" 
                n *= x 
            else 
                n += x 
            end
        end

        sum += n
    end

    display(sum)
end

function part2()
    s = read("input/day6.txt", String)
    perline = split(s, "\n")

    hoho = map(i -> begin
        map(j -> begin
            perline[j][i]
        end, 1:length(perline))
    end, 1:length(perline[1]))

    sum = 0
    curr = nothing
    op = nothing
    for na in hoho
        
        if (allequal(na))
            # println((op, curr, na))
            if curr !== nothing
                sum += curr
            end
            curr = nothing
            op = nothing
            continue
        end

        if op === nothing 
            if na[length(na)] == '*'
                op = '*'
                curr = 1 
            else 
                op = '+'
                curr = 0 
            end
            na[length(na)] = ' '
        end

        
        n = parse(Int64, String(na))
        
        if op == '*'
            curr *= n
        else 
            curr += n 
        end
    end

    sum += curr

    display(sum)
end

input = readinput()

@time part1(input)
@time part2()