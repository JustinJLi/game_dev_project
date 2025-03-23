extends Node2D

@onready var SceneTransitionAnimation = $SceneTransition/AnimationPlayer
@onready var level_complete_screen = get_node("Player/CanvasLayer2/LevelCompleteScreen")  
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneTransitionAnimation.play("fade_out")
	print(hostage.total_hostages)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_5_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneTransitionAnimation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		call_deferred("change_scene")


func change_scene() -> void:
	level_complete_screen.show()
	player.velocity = Vector2.ZERO  # Stop movement
	player.set_physics_process(false)  # Disable physics updates
	#get_tree().change_scene_to_file("res://Assets/UI/level_complete_screen/level_complete_screen.tscn")
