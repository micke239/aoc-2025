using Pkg
Pkg.add("DataStructures")

using DataStructures

function readinput()
    s = read("input/day10.txt", String)
    lines = split(s, "\n")
    map(l -> let 
        groups = match(r"\[(.*)] ([^\{]*){(.*)}", l)

        lights = map(s -> s === '#', collect(groups[1]))
        buttons = map(s -> begin
            s = replace(s, " " => "")
            s = replace(s, "(" => "")
            s = replace(s, ")" => "")
        
            map(b -> parse(Int64, b), split(s, ","))
        end, filter(x -> x != "", split(groups[2], " ")))
        jolts = map(s -> parse(Int32, s), split(groups[3],","))
        (collect(lights), collect(buttons), collect(jolts))
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
    i = 0
    s = map(box -> begin
        expect = box[1]
        best = nothing

        tested = Set()

        tests = []
        curr = fill(false, length(box[1]))
        for button in box[2]
            push!(tested, (curr, button))
            push!(tests, (curr, button, 1))
        end

        while !isempty(tests)
            (then, button, i) = popfirst!(tests)


            if best !== nothing && best <= i
                continue
            end

            curr = copy(then)
            for idx in button
                curr[idx+1] = !curr[idx+1] 
            end
            
            if expect == curr 
                best = i
                continue
            end

            for button in box[2]
                if !((curr, button) in tested)
                    push!(tested, (curr, button))
                    push!(tests, (curr, button, i+1))
                end
            end

        end
        i += 1
        # println(i, " ", expect, " ", box[2], ": ", best)

        best
    end, boxes)

    println(s)
    println(sum(s))
end

function pushdone!(done, btn, value, deps, buttonreqs)
    if (value < 0)
        return false
    end

    if haskey(done, btn)
        if done[btn] != value
            return false
        end
    else
        push!(done, btn => value)
        push!(buttonreqs, (value, Set(btn)))
        if haskey(deps, btn)
            for (nbtn, diff) in deps[btn]
                success = pushdone!(done, nbtn, value + diff, deps, buttonreqs)
                if (!success) 
                    return false
                end
            end
        end
    end
    # println(done, " | ", buttonreqs, " | ", deps)
    # println(done, " | ", buttonreqs, " | ", deps)
    return true
end

function reduce_buttonreqs!(buttonreqs, done, deps)
    # println("hello ", buttonreqs, " ", done, " ", deps)
    
    changed = true
    while (changed) 
        changed = false
        # println("hello")
        for buttonreqqer in buttonreqs
            (expected, idx_buttons) = buttonreqqer
            # for button in idx_buttons
            # otherbuttons = filter(b -> b !== button, idx_buttons)
            found = filter(buttonreq -> begin
                if buttonreq == buttonreqqer
                    false
                else
                    all(b -> b in buttonreq[2], idx_buttons)
                end
            end, buttonreqs)

            for f in found
                # println(expected)
                #  println(f, " | ", idx_buttons, ", ", expected, " | ", done)
                new_buttons = filter(b -> !(b in idx_buttons), f[2])
                if (isempty(new_buttons))
                    continue
                end
                if (f[1]-expected < 0)
                    # println("egg")
                    return nothing
                end

                nval = f[1]-expected

                if (nval == 0)
                    for ibtn in new_buttons
                        succ = pushdone!(done, ibtn, 0, deps, buttonreqs)
                        if (!succ)
                            # println("humbu")
                            return nothing
                        end
                    end
                elseif (length(new_buttons) == 1)
                    ibtn = first(new_buttons)
                    succ = pushdone!(done, ibtn, nval, deps, buttonreqs)
                    if (!succ)
                        # println("bsdkfjb")
                        return nothing
                    end
                else
                    push!(buttonreqs, (nval, new_buttons))
                end

                delete!(buttonreqs, f)
                # println(buttonreqs)
                changed = true
                # println("added ", (f[1]-expected, new_buttons))
            end


            # end
        end
    # println("hello inner ", buttonreqs, " ", done, " ", deps)

    end

    # ska in här
    for buttonreqqer in buttonreqs
        # for button in idx_buttons
        # otherbuttons = filter(b -> b !== button, idx_buttons)
        l = length(buttonreqqer[2])
        if (l == 1)
            continue
        end

        found = map(buttonreq -> begin

            if (buttonreq == buttonreqqer)
                return (nothing, nothing, nothing)
            end
            
            olen = length(buttonreq[2])

            if (olen !== l)
                return (nothing, nothing, nothing)
            end

            inters = symdiff(buttonreqqer[2], buttonreq[2])
            reqqers1 = intersect(buttonreqqer[2], inters)
            reqqers2 = intersect(buttonreq[2], inters)

            (buttonreq, reqqers1, reqqers2)
        end, collect(buttonreqs))

        for (f, reqqers1, reqqers2) in found
            if (reqqers1 === nothing || reqqers2 === nothing)
                continue
            elseif length(reqqers1) != 1 || length(reqqers2) != 1
                continue
            end

            reqqer1 = first(reqqers1)
            reqqer2 = first(reqqers2)
            
            if (haskey(deps, reqqer1))
                if (haskey(deps[reqqer1], reqqer2))
                    if (deps[reqqer1][reqqer2] != (buttonreqqer[1] - f[1]))
                        # println("possible ", buttonreqqer, " | ", f, " | ", reqqer1, " | ", reqqer2)
                        # println("conflicto!! ", deps, ", ", reqqer1, ", ", reqqer2, ", ", buttonreqqer[1] - f[1], ", ", deps[reqqer1][reqqer2], buttonreqqer[1] - f[1] != deps[reqqer1][reqqer2])
                        #                         println(buttonreqs, ", ", done)

                        return nothing
                    end
                else
                    push!(deps[reqqer1], reqqer2 => buttonreqqer[1] - f[1])
                end
            else
                push!(deps, reqqer1 => Dict(reqqer2 => buttonreqqer[1] - f[1]))
            end

            if (haskey(deps, reqqer2))
                if (haskey(deps[reqqer2], reqqer1))
                    if (deps[reqqer2][reqqer1] != (f[1] - buttonreqqer[1]))
                        # println("possible ", buttonreqqer, " | ", f, " | ", reqqer1, " | ", reqqer2)

                        # println("conflict!! ", deps, ", ", reqqer2, ", ", reqqer2, ", ", f[1] - buttonreqqer[1])
                        # println(buttonreqs, ", ", done)
                        return nothing
                    end
                else
                    push!(deps[reqqer2], reqqer1 => f[1] - buttonreqqer[1])
                end
            else
                push!(deps, reqqer2 => Dict(reqqer1 => f[1] - buttonreqqer[1]))
            end
            # push!(deps, reqqer1 => (reqqer2, buttonreqqer[1] - f[1]))
            # push!(deps, reqqer2 => (reqqer1, f[1] - buttonreqqer[1]))
            # if (reqqer1 == 4 || reqqer2 == 4)
            #     println(deps)
            # end
        end
    end

    # for (k,v) in deps
    #     for (k1,v1) in v
    #         if deps[k1][k] != -1*v1
    #             println("how?")
    #             bubug
    #         end
    #     end
    # end
    
    i = 1
    for brq in buttonreqs
        for brq2 in Iterators.drop(buttonreqs,i)
            if (brq[1] !== brq2[1] && brq[2]==brq2[2])
                        # println("confict!!")
                    # println("conflicto noo")

                return nothing #conflict
            end
        end
        i+=1
    end

    for brq in buttonreqs
        if (length(brq[2]) === 1)
            delete!(buttonreqs, brq)
        end
    end

    # println("hello again ", buttonreqs, " ", done, " ", deps)
    
    return (buttonreqs, done, deps)
end

# function handle_stuff(buttonreqs, btn, f, available)
#     nf = copy(f[2])
#     if (btn in nf)
#         delete!(nf,btn)
#     else
#         delete!(nf,-1*btn)
#     end

#     (add, values) = if btn in f[2] 
#         (-f[1], map(l -> -1*l, collect(nf)))
#     else 
#         (f[1], nf)
#     end
#     println(add, "; ", values)
#     for br in available
#         println(buttonreqs)
#         if (btn in br[2])
#             println("in pos ", br)
#             buttonreqs = collect(filter(xy -> !issetequal(xy[2], br[2]), buttonreqs))

#             nbr = copy(br[2])
#             delete!(nbr, btn)
#             for nf_i in values
#                 push!(nbr, nf_i)
#             end
#             push!(buttonreqs, (br[1] + add, nbr))
#         else
#             println("in neg ", br)
#             buttonreqs = collect(filter(xy -> !issetequal(xy[2], br[2]), buttonreqs))
#             nbr = copy(br[2])
#             delete!(nbr, -1*btn)
#             for nf_i in values
#                 push!(nbr, -1*nf_i)
#             end
#             push!(buttonreqs, (br[1] - add, nbr))
#         end
#     end
#     return buttonreqs
# end

# function solve_buttonreqs!(buttonreqs)
#     buttonreqs = collect(buttonreqs)
#     buttons = unique(Iterators.flatmap(r -> r[2], buttonreqs))
#     solved = Dict()
#     println(buttonreqs)
#     it = 0
#     for btn in buttons
#         for btn in buttons 
#             println(btn)
#             available = filter(l -> btn in l[2] || -1*btn in l[2], buttonreqs)

#             if (length(available) <= 1)
#                 continue
#             end

#             f = first(available)
#             r = Iterators.drop(available, 1)
#             cr = first(r)
#             cr = (cr[1], copy(cr[2]))
#             # println(buttonreqs)

#             buttonreqs = handle_stuff(buttonreqs, btn, f, r)
#             buttonreqs = handle_stuff(buttonreqs, btn, cr, [f])

#             # println(buttonreqs)

#             for br in buttonreqs
#                 for ibtn in br[2]
#                     if (-1*ibtn) in br[2]
#                         delete!(br[2], ibtn)
#                         delete!(br[2], -1*ibtn)
#                     end
#                 end
#             end

#             println(buttonreqs)

#         end
#         it += 1

#         # if (it > 10)
#             break
#         # end

#         println("ONE DONE")
#     end

#     return solved
# end

# global superkey = "min!"

function fork_find(buttonreqs, cache, min_cache, depth, done, buttons, deps)
    println(buttonreqs)
    # tests = Queue{Any}()
    tests = PriorityQueue()
    push!(tests, (buttonreqs,done, deps) => 1)
    global_min = 100000000
    tested=Set()
    iterators = 0
    while !isempty(tests)
        ((buttonreqs,done, deps),_) = popfirst!(tests)

        iterators += 1
        if (iterators % 10000 === 0)
            println(iterators, ": ", length(tests))
        end

        # println(buttonreqs,", ",done,", ",deps)

        maxs = copy(done)
        counts = Dict()
        for f in buttons
            # println(f)
            if (haskey(done, f))
                push!(counts, f => 1)
                continue
            end
            # println(buttons)
            maxim = nothing
            cou = 0
            for i in filter(lo -> f in lo[2], buttonreqs)
                cou+=1
                if maxim === nothing || i[1] < maxim
                    maxim = i[1]
                end
            end
            push!(maxs, f => maxim)
            push!(counts, f => cou)
        end
        # println(maxs)
        tt_break = false
        mins = copy(done)
        for f in buttons
            if (haskey(done, f))
                continue
            end

            minim = 0
            for i in filter(lo -> f in lo[2], buttonreqs)
                # println(maxs)
                nminim = i[1] - sum(b -> maxs[b], filter(b -> b !== f, i[2]), init = 0)
                if nminim > minim
                    minim = nminim
                end
            end
            if maxs[f] < minim
                # println(buttonreqs, ", ", done, ", ", maxs)
                tt_break = true;
                break;
            end
            push!(mins, f => minim)
        end
        # println(mins)

        if tt_break
            continue;
        end

        # println(mins)
        
        current_min = sum(values(mins), init = 0)
        if (current_min >= global_min)
            # println((current_min, buttonreqs))
            # println(mins, ", ", maxs, ", ", done)
            continue
        end
        # println(done)
        all_done = all(b -> haskey(done, b), buttons)
        if (all_done)
            # println((current_min, done))
            # println(done)
            # println(mins)
            # println(maxs)
            # println("==")
            if (current_min < global_min)
                global_min = current_min
            end
            continue
        end
        # println(current_min)
        # println(global_min)
        # println(buttonreqs)
        # println(mins)
        # println(mins)
        # println(maxs)
                
            # println(iterators, ": ", done, ", ", deps)

        if (iterators % 10000 === 0)
            println(iterators, ": ", done, ", ", deps)
        end
        for btn in buttons
            if (haskey(done, btn))
                continue
            end
            # if (maxval < mins[btn])
            #     println(btn, " | ", mins[btn],":",maxval , " | ", buttonreqs)
            # end

            totval = sum(values(mins)) 
            # println(btn, ": ", mins[btn]:maxs[btn])
            for idx in mins[btn]:maxs[btn]
                illegal = any(x -> begin
                    (val, btnsi) = x
                    if !(btn in btnsi) 
                        return false
                    end
                    val2 = sum(y -> if y == btn idx else mins[y] end, btnsi)
                    val2 > val
                end, buttonreqs)
                
                if (illegal)
                    # println("illegal!!")
                    break;
                end

                if (totval + (idx - mins[btn])) >= global_min
                    break;
                end
                
                nbuttonreq = copy(buttonreqs)
                ndone = copy(done)
                
                success = pushdone!(ndone, btn, idx, deps, nbuttonreq)

                if (!success)
                    continue
                end

                ndeps = deepcopy(deps)
                news = reduce_buttonreqs!(nbuttonreq, ndone, ndeps)

                if (news !== nothing)
                    (nbuttonreq, ndone, ndeps) = news
                    totval = sum(values(ndone))
                    if (totval >= global_min)
                        break;
                    end
                    
                    if !((nbuttonreq,ndone) in tested) && !haskey(tests, (nbuttonreq,ndone,ndeps))
                        # println("pushing ", nbuttonreq, ", ", ndone, ", ", ndeps)
                        # println((buttonreqs, done)," => ", (nbuttonreq, ndone))
                        push!(tested, (nbuttonreq, ndone))
                        push!(tests, (nbuttonreq, ndone, ndeps) => if haskey(ndeps, btn) 1 else totval end)
                    end
                else
                    # println("bad dog")
                end

            end
        end
        # bubu
    end
    # println(depth)
    # if buttonreqs in cache
    #     return nothing
    # end

    # push!(cache, buttonreqs)
    # println(buttonreqs)

    # println(buttonreqs)
    # illegal = any(r -> r[1] < 0, buttonreqs)
    # if (illegal)
    #     return nothing
    # end
    
    # vis = Set()
    # illegal2 = any(r -> begin
    #         if length(r[2]) == 1 
    #             rf =  first(r[2]) 
    #             if rf in vis
    #                 true
    #             else
    #                push!(vis, rf) 
    #                false
    #             end
    #         else
    #             false
    #         end
    # end, buttonreqs)

    # if (illegal2)
    #     return nothing
    # end

    # mins = Dict()
    # counts = Dict()
    # for f in unique(Iterators.flatmap(r -> r[2], buttonreqs))
    #     minim = nothing
    #     for i in filter(lo -> f in lo[2], buttonreqs)
    #         counts[f] = if haskey(counts, f)
    #             counts[f] + 1
    #         else
    #             1
    #         end
    #         if minim === nothing || i[1] < minim
    #             minim = i[1]
    #         end
    #     end
    #     push!(mins, f => minim)
    # end

    # if (haskey(min_cache, superkey) && sum(values(mins)) >= min_cache[superkey])
    #     return nothing
    # end

    # done = length(vis) == length(buttonreqs)
    # if (done)
    #     ni = sum(r -> r[1], buttonreqs)
    #     min_cache[superkey] = ni
    #     return (ni, buttonreqs)
    # end

    # min = nothing
    # for (btn, minval) in mins
    #     if (btn in vis)
    #         continue
    #     end
    #     for idx in 0:minval
    #         nbuttonreq = copy(buttonreqs)
    #         push!(nbuttonreq, (idx, Set(btn)))
    #         nbuttonreq = reduce_buttonreqs!(nbuttonreq)

    #         if (nbuttonreq !== nothing)
    #             # println(btn, ", ", idx, ", ", nbuttonreq)
    #             pot_min = fork_find(nbuttonreq, cache, min_cache, depth+1)
    
    #             if (pot_min !== nothing && (min === nothing || pot_min[1] < min[1]))
    #                 println(pot_min)
    #                 min = pot_min
    #             end
    #         end
    #     end

    #     # # println(expected)
    #     # #  println(f)
    #     # new_buttons = filter(b -> !(b in idx_buttons), f[2])
    #     # if (isempty(new_buttons))
    #     #     continue
    #     # end
        
    #     # changed = true
    #     # println("added ", (f[1]-expected, new_buttons))
    # end
    # println(min)
    global_min
end

function part2(boxes)
    println(boxes)
    iter = 0
    s = map(box -> begin
        # println("start")
        expect = box[3]
        best = nothing

        tested = Set()

        tests = PriorityQueue(Base.Order.Reverse)
        boxlen = length(expect)
        curr = fill(0, boxlen)

        maxpresses = Dict()
        presses = []
        buttonreqs = Set()
        done = Dict()
        println(length(box[2]))
        for idx in 1:boxlen
            idx_buttons = filter(button -> any(b -> b === idx-1, box[2][button],), 1:length(box[2]))

            if (length(idx_buttons) == 1)
                push!(done, first(idx_buttons) => expect[idx])
            end

            push!(buttonreqs, (expect[idx], Set(idx_buttons)))
        end

        # for (val, btns) in buttonreqs

        # end
        deps = Dict()
        (buttonreqs, done,ndeps) = reduce_buttonreqs!(buttonreqs, done, deps)
        println((buttonreqs, done,ndeps))
        # solved = solve_buttonreqs!(buttonreqs)
        # println(iter, ": ", buttonreqs)

        # sum(values(solved))

        # println(buttonreqs)

        min = fork_find(buttonreqs, Set(), Dict(), 1, done, 1:length(box[2]), deps)
        println(iter, ": ", min)
        iter+=1
        min

        # while !all(brq -> length(brq[2]) !== 1, buttonreqs)
        #     f = findfirst(brq -> length(brq[2]) === 2, buttonreqs)

        #     for f in found
        #         # println(expected)
        #         #  println(f)
        #         new_buttons = filter(b -> !(b in idx_buttons), f[2])
        #         if (isempty(new_buttons))
        #             continue
        #         end

        #         push!(buttonreqs, (f[1]-expected, new_buttons))
        #         delete!(buttonreqs, f)
        #         changed = true
        #         # println("added ", (f[1]-expected, new_buttons))
        #     end

        #     buttonreqs = reduce_buttonreqs(buttonreqs)
        #     buttonreqs = collect(buttonreqs)
        #     # println(buttonreqs)
        # end

        # for buttonreqqer in buttonreqs
        #     (expected, idx_buttons) = buttonreqqer

        # end

        # availablebuttons = Set(1:length(box[2]))
        # spath = Dict()
        # si = 0
        # for buttoreq in buttonreqs 
        #     if length(buttoreq[2]) == 1
        #         bu = first(buttoreq[2])
        #         push!(spath, bu => buttoreq[1])
        #         delete!(availablebuttons, bu)
        #         si += buttoreq[1]
        #         for idx in box[2][bu]
        #             curr[idx+1] += buttoreq[1]
        #         end
        #         println("added ", buttoreq)
        #     end
        # end

        # testet = Iterators.flatmap(buttonreqqer -> begin
        #     (expected, idx_buttons) = buttonreqqer
        #     map(br -> (br, expected), collect(idx_buttons))
        # end, buttonreqs)

        # testet = Set(testet)

        # best=0
        # for button_idx in 1:length(box[2])
        #     tsts = filter(t -> t[1] === button_idx, testet) 
        #     expected = minimum(x -> x[2], tsts)
        #     best+=expected
        #     println(button_idx, ", ", expected)
        # end

        # for button_idx in availablebuttons
        #     tsts = filter(t -> t[1] === button_idx, testet) 
        #     expected = minimum(filter)
        #     npath = copy(spath)
        #     if (haskey(npath, button_idx))
        #         npath[button_idx] = expected
        #     else
        #         push!(npath, button_idx => expected)
        #     end
        #     push!(tested, npath)
        #     push!(tests, (curr, box[2][button_idx], expected, npath) => 1)
        # end

        # while !isempty(tests)
        #     ((then, button, i, prevpath), _) = popfirst!(tests)

        #     if best !== nothing && best <= i
        #         continue
        #     end

        #     buttonreqqedss = map(b -> (sum(l -> if haskey(prevpath, l) prevpath[l] else 0 end, b[2]), b[1]), buttonreqs) 
        #     # println(prevpath)
        #     if any(bqs -> bqs[1] > bqs[2], buttonreqqedss) 
        #         println("isbigger")
        #         println(prevpath)
        #         continue
        #     elseif all(bqs -> bqs[1] == bqs[2], buttonreqqedss) 
        #         best = i
        #         println(iter, " | ", expect, " | ", curr, " | ", box[2], ": ", best)
        #         println(prevpath)
        #     end

        #     for button_idx in availablebuttons
        #         for (_, expected) in filter(t -> t[1] === button_idx, testet) 
        #             npath = copy(spath)
        #             if (haskey(npath, button_idx))
        #                 npath[button_idx] = expected
        #             else
        #                 push!(npath, button_idx => expected)
        #             end
        #             if !(npath in tested)
        #                 push!(tested, npath)
        #                 push!(tests, (curr, box[2][button_idx], expected, npath) => length(keys(npath)))
        #             end
        #         end

        #         # # println(tested)
        #         # if !(npath in tested)
        #         #     # println("IN")
        #         #     push!(tested, npath)
        #         #     push!(tests, (curr, box[2][button_idx], i+1, npath) => 10000-sum(b -> b[1] - sum(l -> if haskey(npath, l) npath[l] else 0 end, b[2]), buttonreqs))
        #         #     # push!(tests, (curr, button, i+1, npath) => 1)
        #         # end
        #     end

        # # end
        # iter += 1

        # # if isempty(availablebuttons) 
        # #     println("no available :O")
        # #     best = si
        # # end

        # println(iter, " | ", expect, " ", box[2], ": ", best)

        # best
    end, boxes)

    println(s)
    println(sum(s))
end

input = readinput()

@time part1(input)
@time part2(input)