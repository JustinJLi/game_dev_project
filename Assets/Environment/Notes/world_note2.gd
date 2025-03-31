extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"Personal Diary:",
	'"Sarge sent me out for perimeter duty all because I mentioned the pets at the lab!"',
	'"How is it my fault that my curiousity got the better of me?!?!"'
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
