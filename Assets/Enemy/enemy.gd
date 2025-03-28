extends CharacterBody2D
class_name enemy

#Variables for enemy vision cone visualization
@export var vision_renderer: Polygon2D
@export var alert_color: Color

#Group of variables used to adjust the vision cone of an enemy (including rotation speed/angle and debug colors)
@export_group("Rotation")
@export var is_rotating = false
@export var rotation_speed = 0.1
@export var rotation_angle = 90
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE

#variables that represent the main functionality of an enemy. includes references to level screens, animations, etc. as well as enemy stats like damage/health
@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
@onready var healthbar = get_node("HealthBar")
@export var max_health = 100
@export var damage_dealt = 30
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var flash_animation = $AnimatedSprite2D/HitFlash
@onready var death_animation = $AnimatedSprite2D/DeathFlash
var damage
var health
var ammo_pickup = preload("res://Assets/Environment/Notes/ammo_pickup.tscn")
var enemy_dying = false
var player_spotted = false
var player_lost = false
@export var ammo_spawn_chance = 0.1

#References to hostage/player instances
@onready var hostage: hostage = $"../Hostage"
@onready var player: CharacterBody2D = $"../Player"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Enable collision
	set_collision_layer_value(2, true)
	health = max_health #set health
	hud = get_tree().get_first_node_in_group("hud") #setup hud 
	$AnimatedSprite2D.animation = "move" #default animation for enemy
	healthbar.hide() #hide healthbar
	
	# Increase total enemies count when spawned
	EnemyStats.total_enemies += 1

func _physics_process(delta: float) -> void:
	damage = damage_dealt #set damage values against player
	
	#Stop movement/damage if the player has died or won
	if player != null: 
		if player.level_completed or enemy_dying:
			return
			
	#Trigger movement 
	move_and_slide()
	$AnimatedSprite2D.play() #play walking animation
	
	#If the player lost, reset the enemy stats
	if (player.game_over):
		EnemyStats.reset()

#Function that lowers the enemy health if they are found taking damage
func take_damage(damage_amount):
	if enemy_dying: #Disable damage if the enemy is already dead
		return
	health -= damage_amount #lower health based on the damage taken
	healthbar._set_health(health) #Set healthbar to new value
	print("Enemy took ", damage_amount, " damage. Health: ", health)
	
	#If the enemy still has health, play the flash animation and hit bark
	if health > 0:
		$EnemyHit.play()
		flash_animation.play("flash")
	else: #Otherwise, the enemy has been killed
		enemy_dying = true #Set boolean to true
		EnemyStats.total_enemies -= 1  # Decrease enemy count when defeated
		EnemyStats.enemies_cleared += 1 #Incrase # of enemies killed
		EnemyStats.enemies_killed_score += 100 #Give player score
		
		#Update screens to show enemy killed progress
		hud.update_enemies_cleared_label(EnemyStats.enemies_cleared) 
		level_complete_screen.update_enemies_killed_score(EnemyStats.enemies_cleared, EnemyStats.enemies_killed_score)
		
		#Spawn an ammo pickup if a random number is lower than the spawn change (10% chance of spawning)
		if ammo_pickup and randf() < ammo_spawn_chance:
			var ammo_instance = ammo_pickup.instantiate()
			ammo_instance.position = global_position
			get_parent().call_deferred("add_child", ammo_instance)
			print("Ammo spawned at:", ammo_instance.position)
		
		#Disable collision and play death animation before removing 
		set_collision_layer_value(2, false)
		$EnemyDeath.play()
		death_animation.play("death")
		await $EnemyDeath.finished
			
		queue_free() #remove enemy from the scene

#Tracks when an object enters an enemy hitbox
func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	#Stop hitbox tracking if the player is dead or finished the level
	if player.level_completed or enemy_dying:
		$AnimatedSprite2D.stop()
		return
	
	#If the enemy was hit by a player bullet or their knife, deal damage to the enemy
	if area.name == "bullet_hitbox":
		take_damage(PlayerData.gun_damage)
	if area.name == "knife_hitbox":
		take_damage(PlayerData.knife_damage)
	
	#If the player themself has entered the enemy hitbox, begin attacking the player
	if player.level_completed:
		return
	elif area.name == "player_hitbox":
		$Attack.play()
		$AnimatedSprite2D.animation = "attack"
		$AnimatedSprite2D.play()

#When an object leaves the enemy hitbox, stop attacking and play the walking animation
func _on_enemy_hitbox_area_exited(area: Area2D) -> void:
	if player.level_completed or enemy_dying:
		$AnimatedSprite2D.stop()
		return
	
	$Attack.stop()
	$AnimatedSprite2D.animation = "move"
	$AnimatedSprite2D.play()

#Function for if an object enters the vision cone of the enemy
func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	#Set boolean to true for FSM
	print("%s is seeing %s" % [self, body])
	if body.name == "Player":
		player_spotted = true
	vision_renderer.color = alert_color

#When an object leaves the vision cone
func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	#Set boolean to false for FSM
	print("%s stopped seeing %s" % [self, body])
	if body.name == "Player":
		player_spotted = false
	vision_renderer.color = original_color

#When the player gets too close to an enemy from behind, mark them as spotted for the FSM
func _on_detection_box_area_entered(area: Area2D) -> void:
	if area.name == "player_hitbox":
		player_spotted = true
