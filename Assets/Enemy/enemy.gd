extends CharacterBody2D
class_name enemy

@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
static var enemies_cleared = 0
static var enemies_killed_score = 0
@onready var healthbar = get_node("HealthBar")
var max_health = 100
var health = max_health
static var total_enemies = 0
var ammo_pickup = preload("res://Assets/Environment/Notes/ammo_pickup.tscn")
var ammo_spawn_chance = 0.1
@onready var hostage: hostage = $"../Hostage"

@onready var player: CharacterBody2D = $"../Player"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")
	$AnimatedSprite2D.animation = "move"
	#healthbar.light_mask = 2
	#healthbar.visibility_layer = 1
	healthbar.hide()
	
	# Increase total enemies count when spawned
	total_enemies += 1
	#enemies_cleared = 0
	#enemies_killed_score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#var player = get_parent().get_node("Pl+ayer")
	
	#position += (Player.position - position) / 100
	#look_at(player.position)
	if player.level_completed:
		return
	move_and_slide()
	$AnimatedSprite2D.play()
	
func take_damage(damage_amount):
	health -= damage_amount
	healthbar._set_health(health)
	print("Enemy took ", damage_amount, " damage. Health: ", health)

	if health <= 0:
		total_enemies -= 1  # Decrease enemy count when defeated
		enemies_cleared += 1
		enemies_killed_score += 100
		hud.update_enemies_cleared_label(enemies_cleared)
		level_complete_screen.update_enemies_killed_score(enemies_cleared, enemies_killed_score)
		
		if ammo_pickup and randf() < ammo_spawn_chance:
			var ammo_instance = ammo_pickup.instantiate()
			ammo_instance.position = global_position
			get_parent().call_deferred("add_child", ammo_instance)
			print("Ammo spawned at:", ammo_instance.position)

		if hostage != null:
			if hostage.total_hostages <= 0:
				player.level_completed = true
				level_complete_screen.show()
		else:
			print("Warning: Hostage object was freed before accessing total_hostages!")
			
		queue_free()

	
func kill():
	get_tree().call_deferred("reload_current_scene")

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	if player.level_completed:
		return
		
	if area.name == "bullet_hitbox":
		take_damage(50)
		
		
	if area.name == "player_hitbox":
		$AnimatedSprite2D.animation = "attack"
		$AnimatedSprite2D.play()


func _on_enemy_hitbox_area_exited(area: Area2D) -> void:
	if player.level_completed:
		return
	$AnimatedSprite2D.animation = "move"
	$AnimatedSprite2D.play()
