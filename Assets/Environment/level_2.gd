extends Node2D

@onready var SceneTransitionAnimation = $SceneTransition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTransitionAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneTransitionAnimation.play("fade_out")
	print(hostage.total_hostages)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
