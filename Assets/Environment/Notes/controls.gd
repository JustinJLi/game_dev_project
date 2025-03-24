extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

# Dialog lines for different inputs
const lines_keyboard: Array[String] = [
	"A crumbled note...",
	"Controls:",
	"WASD to move.",
	"Hold left shift to sprint.",
	"Left click to attack.",
	"R to reload.",
	"F to toggle flashlight.",
	"Q or scroll mouse to switch weapons.",
	"Watch your ammo."
]

const lines_controller: Array[String] = [
	"A crumbled note...",
	"Controls:",
	"Left stick to move.",
	"Hold L3 to sprint.",
	"R2 to attack.",
	"Square to reload.",
	"R3 to toggle flashlight.",
	"Triangle to switch weapons.",
	"Watch your ammo."
]

#Call interact function when player is within proximity
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

#Upon interaction...
func _on_interact():
	#Pause game, display dialog based on input, and wait until the dialog is finished before starting the game
	get_tree().paused = true
	if player.is_mouse:
		DialogueManager.start_dialog(global_position, lines_keyboard)
	else:
		DialogueManager.start_dialog(global_position, lines_controller)
	await DialogueManager.dialog_finished
	get_tree().paused = false
