include("hlt/Halite.jl")
using Halite


function worker(sid, server, done_channel::Channel)
    sock = accept(server)
    info = split(readline(sock))
    id, width, height = parse.(Int, info)
    try
        while isopen(sock)
            game_map_str = readline(sock)
            if isempty(game_map_str)
                close(sock)
                break
            end
            game_map = GameMap(id, width, height, game_map_str)

            # Here we define the set of commands to be sent to the Halite engine at the end of the turn
            command_queue = Vector{String}()
            # For every ship that I control
            for ship in all_ships(get_me(game_map))
                if isdocked(ship)
                    # skip this ship
                    continue
                end

                # For each planet in the game (only non-destroyed planets are included)
                for planet in all_planets(game_map)
                    if isowned(planet)
                        # Skip this planet
                        continue
                    end

                    # If we can dock, let's (try to) dock. If two ships try to dock at once, neither will be able to.
                    if can_dock(ship, planet)
                        # We add the command by appending it to the command_queue
                        push!(command_queue, dock(ship, planet))
                    else
                        # If we can't dock, we move towards the closest empty point near this planet (by using closest_point_to)
                        # with constant speed. Don't worry about pathfinding for now, as the command will do it for you.
                        # We run this navigate command each turn until we arrive to get the latest move.
                        # Here we move at half our maximum speed to better control the ships
                        # In order to execute faster we also choose to ignore ship collision calculations during navigation.
                        # This will mean that you have a higher probability of crashing into ships, but it also means you will
                        # make move decisions much quicker. As your skill progresses and your moves turn more optimal you may
                        # wish to turn that option off.
                        navigate_command = navigate(game_map,
                            ship,
                            closest_point_to(ship, planet),
                            speed = round(Int, MAX_SPEED/2),
                            ignore_ships = true)
                        # If the move is possible, add it to the command_queue (if there are too many obstacles on the way
                        # or we are trapped (or we reached our destination!), navigate_command will return empty string;
                        # don't fret though, we can run the command again the next turn)
                        if !isempty(navigate_command)
                            push!(command_queue, navigate_command)
                        end
                    end
                    break
                end
            end
            
            println("Socket: $sid, command: $(join(command_queue))")
            write(sock, join(command_queue))
            write(sock, "\n")
        end
    catch err
        st = catch_stacktrace()
        for s in st
            println(s)
        end
        println(err)
    end
    # close(server)
    put!(done_channel, sid)
end


function master()
    pool_size = 10

    server = listen("2017")
    done_channel = Channel(pool_size)

    for id in 1:pool_size
        @schedule worker(id, server, done_channel)
    end
    println("Server started")

    while true
        id = take!(done_channel)
        @schedule worker(id, server, done_channel)
    end
end

master()
