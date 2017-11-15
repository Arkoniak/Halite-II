### Welcome to your first Halite-II bot!
### 
### This bot's name is Settler. It's purpose is simple (don't expect it to win complex games :) ):
### 1. Initialize game
### 2. If a ship is not docked and there are unowned planets
### 2.a. Try to Dock in the planet if close enough
### 2.b If not, go towards the planet
### 
### Note: Please do not place print statements here as they are used to communicate with the Halite engine. If you need
### to log anything use the logging module.

# Let's start by importing the Halite Starter Kit so we can interface with the Halite engine
include("hlt/Halite.jl")
using Halite

using Memento
logger = get_logger("bot-logger")

game = Game("Julyax")

# Here one can do all preliminary checks and warmups, using initial 60s timeout.
initial_map = game.initial_game_map
debug(logger, @sprintf("width: %d; height: %d; players: %d; my ships: %d; planets: %d", 
                       initial_map.width, initial_map.height,
                       initial_map |> all_players |> length,
                       initial_map |> get_me |> all_ships |> length,
                       initial_map |> all_planets |> length))

turn = 1

start_game(game)

while true
    # TURN START
    # Update the map for the new turn and get the latest version
    debug(logger, "------ TURN $turn ------")

    command_queue = request_commands(game)
    send_command_queue(command_queue)
    turn += 1
    # TURN END
end
# GAME END
