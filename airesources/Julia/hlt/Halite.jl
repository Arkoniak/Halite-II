module Halite

using Memento

export Game, GameMap, DockedStatus, start_game, thrust, dock, undock, update_map, 
    all_players, all_planets, all_ships, all_docked_ships, get_player, get_me, get_planet, 
    get_docked_ship, isdocked, isowned, isfull, can_dock, navigate, send_command_queue, 
    closest_point_to, nearest_unoccupied_planet, request_commands

@enum DockedStatus UNDOCKED=0 DOCKING=1 DOCKED=2 UNDOCKING=3

include("constants.jl")
include("types.jl")
include("parse.jl")
include("utils.jl")
include("commands.jl")

end #module
