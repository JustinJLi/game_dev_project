extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = get_parent().get_node("CanvasLayer/HUD/HealthBar")

const lines: Array[String] = [
	"You are at full health.",
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if (player.health != 100):
		if player.health < 50:
			player.health += 50
		else:
			player.health += player.max_health - player.health
		healthbar._set_health(player.health)
		$Heal.play()
		await $Heal.finished
		queue_free()
	else:
		get_tree().paused = true
		DialogueManager.start_dialog(global_position, lines)
		await DialogueManager.dialog_finished
		get_tree().paused = false
