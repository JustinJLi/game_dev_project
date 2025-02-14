extends CharacterBody2D
class_name hostage

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D

const lines: Array[String] = [
	"Thank you for saving me!",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _physics_process(delta: float) -> void:
	move_and_slide()
	
func _on_interact():
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	queue_free()

func _on_hostage_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "bullet_hitbox":
			queue_free()
		

func _on_hostage_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
			_on_interact()
