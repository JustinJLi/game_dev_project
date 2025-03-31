extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"Welcome to the facility!",
	"Enjoy a taste of our artificial laboratory environments, perfect for all applications!",
	"Simply enter the blue door and be amazed at the seamless transitions between our simulated outdoor and indoor environments!"
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
