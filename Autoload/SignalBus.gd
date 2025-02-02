# Global signal bus for game-wide communication
# All game events and system interactions should be routed through here
extends Node

## Game pause state toggle
## Emitted when: Pause menu is opened/closed
## Connected to: GameController, UI systems
## @param is_paused: Current pause state (true = game paused)
signal pause(is_paused : bool)

## Minigame visibility management
## Emitted when: Starting a minigame
## Connected to: Minigame controllers, UI layers
## @param id: Unique identifier for minigame instance
## @param type: Minigame type ("rush", "lock", etc)
signal minigame_show(id : int, type : String)

## Emitted when: Closing any active minigame
## Connected to: Minigame cleanup systems
signal minigame_hide

## Popup overlay management
## Emitted when: Opening any modal overlay/popup
## Connected to: UI layer, input blocking systems
signal pop_open

## Emitted when: Closing all overlays/popups
## Connected to: UI cleanup, input restoration
signal pop_close

## Present interaction events
## Emitted when: Player interacts with a present
## Connected to: Present minigame systems
## @param present_name: Name identifier of the present
signal present_open(present_name : String)

## Emitted when: Present interaction completes
## Connected to: Present cleanup systems
signal present_close

## Mouse position requests
## Emitted when: Need world-space mouse position
## Connected to: Input systems, drag-and-drop handlers
## @return: Vector2 of mouse position in world coordinates
signal get_mouse_world_pos

## Puzzle configuration events
## Emitted when: Present is opened with puzzles
## Connected to: Minigame managers
## @param present_name: Name of source present
## @param puzzles: Dictionary of puzzle configurations
signal define_puzzles(present_name : String, puzzles : Dictionary)

## Combat events
## Emitted when: Enemy initiates attack
## Connected to: Defense systems, UI warnings
signal attacking

## Current usage: Puppet animation completion event
## Connected to: Animation systems, popup cleanup
signal puppet_cummed

# Usage Examples:
# SignalBus.pause.emit(true)
# SignalBus.minigame_show.emit(1, "rush")
# SignalBus.define_puzzles.emit("Present3", {"rush": true, "lock": false})
