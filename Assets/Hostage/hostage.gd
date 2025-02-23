extends CharacterBody2D
class_name hostage

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
@onready var enemy: enemy = $"../Enemy"
@onready var player: CharacterBody2D = $"../Player"


static var hostages_rescued = 0
static var hostages_killed = 0
static var total_hostages_cleared = 0
var rescued = false  # Flag to track if the hostage has already been rescued
var killed = false  # Flag to track if the hostage has already been rescued

static var hostages_rescued_score = 0
static var hostages_killed_score = 0
static var total_hostages = 0


const lines: Array[String] = [
	"Thank you for saving me!",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("walk")
	hud = get_tree().get_first_node_in_group("hud")
	interaction_area.interact = Callable(self, "_on_interact")
	total_hostages += 1
	#hostages_rescued = 0
	#hostages_rescued_score = 0

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	
func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
	_rescue_hostage()

		
func _on_hostage_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "bullet_hitbox":
		_killed_hostage()  # Ensures only one subtraction occurs		

func _on_hostage_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_on_interact()
		$AnimatedSprite2D.stop()
			
func _rescue_hostage():
	if rescued:
		return  # Prevent multiple subtractions
	
	rescued = true
	total_hostages -= 1
	hostages_rescued += 1
	total_hostages_cleared += 1
	hostages_rescued_score += 150

	hud.update_hostages_cleared_label(total_hostages_cleared)
	level_complete_screen.update_hostages_rescued_score(hostages_rescued, hostages_rescued_score)
	print(total_hostages)
	if total_hostages <= 0:
		player.level_completed = true
		level_complete_screen.show()

	queue_free()
	
func _killed_hostage():
	if killed:
		return  # Prevent multiple subtractions
	
	killed = true
	total_hostages -= 1
	hostages_killed += 1
	total_hostages_cleared += 1
	hostages_killed_score -= 150
	
	hud.update_hostages_cleared_label(total_hostages_cleared)
	level_complete_screen.update_hostages_killed_score(hostages_killed, hostages_killed_score)
	print(total_hostages)
	if total_hostages <= 0:
		player.level_completed = true
		level_complete_screen.show()

	queue_free()


func _on_hostage_hitbox_area_exited(area: Area2D) -> void:
	$AnimatedSprite2D.play("walk")
