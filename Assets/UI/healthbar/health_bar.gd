extends ProgressBar

@onready var timer = $Timer  # Timer to delay the update of the damage bar
@onready var damage_bar = get_node("DamageBar")  # Reference to the secondary damage bar

# Health variable with a setter function
var health = 0 : set = _set_health

# Setter function for health
func _set_health(new_health):
	var prev_health = health  # Store previous health value
	health = min(max_value, new_health)  # Ensure health doesn't exceed max_value
	value = health  # Update the progress bar value

	# If health reaches zero, remove this node from the scene
	if health <= 0:
		queue_free()

	# If health decreases, start the timer for delayed damage bar update
	if health < prev_health:
		timer.start()
	else:
		# Instantly update the damage bar if health increases
		damage_bar.value = health

# Initializes the health values
func init_health(_health):
	health = _health
	max_value = health  # Set the max value of the progress bar
	value = health  # Set the initial value of the progress bar
	damage_bar.max_value = health  # Ensure damage bar also matches max health
	damage_bar.value = health  # Set damage bar to the correct initial value

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	pass

# Called every frame
func _process(delta: float) -> void:
	pass  

# Updates the damage bar when the timer times out (delays visual update)
func _on_timer_timeout() -> void:
	damage_bar.value = health  # Sync the damage bar with the actual health
