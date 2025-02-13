extends Node2D

@onready var SceneTransitionAnimation = $SceneTransition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneTransitionAnimation.play("fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tutorial_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneTransitionAnimation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://Assets/Environment/world.tscn")
