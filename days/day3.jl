function readinput()
    s = read("input/day3.txt", String)
    lines = split(s, "\n")
    return map(xs -> map(i -> parse(Int64, i), collect(xs)), lines)
end

function part1(input) 
    x = map(line -> let 
        max1 = 0
        max2 = 0
        for i in 1:(length(line)-1)
            if (line[i] > max1)
                max1 = line[i]
                max2 = line[i+1]
            elseif line[i+1] > max2 
                max2 = line[i+1]
            end 
        end

        max1*10 + max2
    end, input)

    display(sum(x))
end

function part2(input)
    n = 12
    x = map(line -> let 
        max = zeros(Int8, n)
        for i in 1:(length(line)-(n-1))
            for j in 0:(n-1)
                if (line[i+j] > max[j+1])
                    for k in j:(n-1)
                        max[k+1] = line[i+k]
                    end
                    continue
                end
            end
        end

        parse(Int64, join(max))
    end, input)

    display(sum(x))
end

input = readinput()

@time part1(input)
@time part2(input)