extends Node2D

@onready var SceneTransitionAnimation = $SceneTransition/AnimationPlayer
#@onready var pause_menu = $PauseMenu
#var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneTransitionAnimation.play("fade_out")
	#pause_menu.visible = false


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("pause"):
		#pauseMenu()
		#
#func pauseMenu():
	#if paused:
		#pause_menu.hide()
		#Engine.time_scale = 1
	#else: 
		#pause_menu.show()
		#Engine.time_scale = 0
	#paused = !paused



func _on_tutorial_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneTransitionAnimation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		call_deferred("change_scene")

func change_scene() -> void:
	get_tree().change_scene_to_file("res://Assets/Environment/world.tscn")
