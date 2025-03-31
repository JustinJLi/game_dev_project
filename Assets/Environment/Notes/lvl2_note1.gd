extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A bloody note.",
	'"Tell my wife I am sorry..."',
	'"Tell her I was desperate for us. For the family."',
	'"Please do t turn m nt o a MoN tR..."'
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
