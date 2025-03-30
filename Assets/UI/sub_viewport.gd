extends SubViewport
# Code used for subviewport of scrapped minimap idea

@onready var camera = $Camera2D
@onready var player = get_tree().get_first_node_in_group("Player")  # Find player globally



func _physics_process(delta):
	camera.position = player.position  # Follow the player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
