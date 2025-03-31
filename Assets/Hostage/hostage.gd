extends CharacterBody2D
class_name hostage

#Variables pertaining to hostage functionality (sprites, interaction area, animations, etc.)
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
@onready var death_animation = $AnimatedSprite2D/DeathFlash

#Variables used to represent counts of killed/rescued hostages
static var hostages_rescued = 0
static var hostages_killed = 0
static var total_hostages_cleared = 0
var rescued = false  # Flag to track if the hostage has already been rescued
var killed = false  # Flag to track if the hostage has already been rescued
static var hostages_rescued_score = 0
static var hostages_killed_score = 0
static var total_hostages = 0

#References to enemy and player instances
@onready var enemy: enemy = $"../Enemy"
@onready var player: CharacterBody2D = $"../Player"

#Set of dialog lines that will be read upon interaction
const lines: Array[String] = [
	"Thank you for saving me!",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Enable collision and initialize animations, hud, and interaction area
	set_collision_layer_value(2, true)
	$AnimatedSprite2D.animation = "walk"
	hud = get_tree().get_first_node_in_group("hud")
	interaction_area.interact = Callable(self, "_on_interact")
	total_hostages += 1 #Increase count for every hostage on the level

	print("Total Hostages: " + str(total_hostages))

func _physics_process(delta: float) -> void:
	if killed: #Stop sprite animation if the hostage is killed
		$AnimatedSprite2D.stop()
		return
	else: #Otherwise enable movement around the level
		move_and_slide()
		$AnimatedSprite2D.play()
	
	#Reset hostage stats if the player dies
	if (player.game_over):
		reset()
	
#Function that will be called upon player interaction
func _on_interact():
	#Play a bark, start the dialog, and pause the game until dialog is finished
	$Rescue.play()
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
	_rescue_hostage() #Call the rescue hostage function

#Function that tracks objects entering the hostage hitbox
func _on_hostage_hitbox_area_entered(area: Area2D) -> void:
	#Kill the hostage if the player's bullet enters their hitbox
	if area.name == "bullet_hitbox":
		_killed_hostage()

#Function that tracks objects entering the body of the hostage
func _on_hostage_hitbox_body_entered(body: Node2D) -> void:
	#If the player enters the hostage hitbox area, automatically engage in dialog conversation
	if body.name == "Player" and !killed:
		_on_interact()
		$AnimatedSprite2D.stop()

#Function called when the hostage is rescued
func _rescue_hostage():
	if rescued:
		return  # Prevent multiple subtractions of hostages
	
	#Set flag to true and adjust count + score from rescuing a hostage
	rescued = true
	total_hostages -= 1
	hostages_rescued += 1
	total_hostages_cleared += 1
	hostages_rescued_score += 150
	
	#Update HUD and level complete screens to acknowledge hostage save
	hud.update_hostages_cleared_label(total_hostages_cleared)
	level_complete_screen.update_hostages_rescued_score(hostages_rescued, hostages_rescued_score)
	
	print(total_hostages)
	#If there are no more hostages, then the player has won the game
	if total_hostages <= 0:
		player.level_completed = true
		level_complete_screen.show()
		level_complete_screen.update_total_score()

	queue_free() #Remove hostage from the scene
	
#Function for if a hostage is killed
func _killed_hostage():
	if killed:
		return  # Prevent multiple subtractions
	
	#Set flag to true and adjust count + score from rescuing a hostage
	killed = true
	total_hostages -= 1
	hostages_killed += 1
	total_hostages_cleared += 1
	hostages_killed_score -= 150
	
	#Update HUD and level complete screens to acknowledge hostage death
	hud.update_hostages_cleared_label(total_hostages_cleared)
	level_complete_screen.update_hostages_killed_score(hostages_killed, hostages_killed_score)
	print(total_hostages)
	
	#If there are no more hostages, then the player has won the game
	if total_hostages <= 0:
		player.level_completed = true
		level_complete_screen.show()
		level_complete_screen.update_total_score()
	
	#Disable collision, play bark and remove from scene
	set_collision_layer_value(2, false)
	$Shot.play()
	death_animation.play("death")
	await $Shot.finished
	queue_free()

#Play walking animation when hitbox area is left
func _on_hostage_hitbox_area_exited(area: Area2D) -> void:
	$AnimatedSprite2D.play("walk")
	
#Reset function for all hostage stats
func reset():
	hostages_rescued = 0
	hostages_killed = 0
	total_hostages_cleared = 0
	rescued = false  # Flag to track if the hostage has already been rescued
	killed = false  # Flag to track if the hostage has already been rescued

	var hostages_rescued_score = 0
	var hostages_killed_score = 0
	total_hostages = 0
