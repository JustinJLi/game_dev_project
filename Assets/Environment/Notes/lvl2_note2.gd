extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A hostage journal.",
	'"Whatever is going on here needs to stop."',
	'"Poor families are volunteering for experimental studies thinking they are getting paid to help."',
	'"From what I can tell, these people are turning them into monsters!"',
	'"I hope I can make it out alive..."',
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
