extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"Another crumbled note...",
	"Controls:",
	"WASD to move.",
	"Left click to shoot.",
	"R to reload.",
	"Watch your ammo."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
