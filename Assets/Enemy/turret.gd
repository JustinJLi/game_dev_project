extends CharacterBody2D
class_name turret

#Variables for enemy vision cone visualization
@export var vision_renderer: Polygon2D
@export var alert_color: Color

#Group of variables used to adjust the vision cone of an enemy (including rotation speed/angle and debug colors)
@export_group("Rotation")
@export var is_rotating = false
@export var rotation_speed = 0.1
@export var rotation_angle = 90
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var rot_start = rotation

#variables that represent the main functionality of a turret. includes references to level screens, animations, etc. as well as stats like bullet damage/speed
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
@onready var healthbar = get_node("HealthBar")
@onready var hit_animation = $Sprite2D/HitFlash
@export var max_health = 300
var health
var ammo_pickup = preload("res://Assets/Environment/Notes/ammo_pickup.tscn")
var turret_dying = false
var bullet_speed = 800
var bullet = preload("res://Assets/Enemy/turret_bullet.tscn")

#References to hostage/player instances
@onready var player: CharacterBody2D = $"../Player"
@onready var enemy: enemy = $"../Enemy"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Get the player in the scene, and initialize interaction area for disarm
	player = get_tree().get_first_node_in_group("Player")
	interaction_area.interact = Callable(self, "_on_interact")
	
	#Enable collision and set health + hud
	set_collision_layer_value(2, true)
	health = max_health
	hud = get_tree().get_first_node_in_group("hud")
	
	# Increase total enemies count when spawned
	EnemyStats.total_enemies += 1

func _physics_process(delta: float) -> void:
	
	#Stop movement/damage if the player/turret has died
	if player != null:
		if player.level_completed or turret_dying:
			return

	#If the player won, reset enemy stats
	if (player.game_over):
		EnemyStats.reset()

	#Enable turret rotation if it hasn't spotted anyone
	if is_rotating:
		rotation = rot_start + sin(Time.get_ticks_msec()/1000. * rotation_speed) * deg_to_rad(rotation_angle/2.)

#Function to take damage from objects
func take_damage(damage_amount):
	#Prevent taking damage if the turret is destroyed
	if turret_dying:
		return
	health -= damage_amount #lower health based on damage
	hit_animation.play("flash") #Play hit flash animation
	print("Enemy took ", damage_amount, " damage. Health: ", health)
	
	#If the turret still has health, play hit bark
	if health > 0:
		$TurretHit.play()
	else: #Otherwise, the turret is destroyed
		kill(200) #Kill the turret and give 200 points
		
		#Play death bark before removing turret from scene
		$TurretDeath.play()
		await $TurretDeath.finished
		queue_free()

#Function to fire a bullet
func fire():
	#Instantiate the turret bullet and add a velocity from the muzzle
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = $Marker2D.global_position
	bullet_instance.rotation = $Marker2D.global_rotation  
	bullet_instance.linear_velocity = Vector2(0, -bullet_speed).rotated($Marker2D.global_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)

#Function that helps remove the turret from the scene and give the player their points
func kill(points):
	turret_dying = true #Set bool to true
	EnemyStats.total_enemies -= 1  # Decrease enemy count when defeated
	EnemyStats.enemies_cleared += 1 #Incrase # of enemies killed 
	EnemyStats.enemies_killed_score += points #Give player score
	
	#Update hud elements to reference turret destruction
	hud.update_enemies_cleared_label(EnemyStats.enemies_cleared)
	level_complete_screen.update_enemies_killed_score(EnemyStats.enemies_cleared, EnemyStats.enemies_killed_score)
	set_collision_layer_value(2, false) #disable collision

#Function that is called when the turret is interacted with by the player
func _on_interact():
	#Get slightly less points for a disarm, but play the bark and remove the turret from the scene
	if !turret_dying:
		kill(150)
		$TurretDisarm.play()
		await $TurretDisarm.finished
		queue_free()

#When a player is in sight of the turret and the turret cooldown is over, shoot a bullet
func _on_turret_timer_timeout() -> void:
	if !turret_dying:
		fire()
		$TurretShoot.play()

#If the player shot a bullet at the turret, take 50 damage
func _on_turret_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "bullet_hitbox":
		take_damage(PlayerData.gun_damage)

#Start timer once the player is in sight of the turret
func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	$TurretTimer.start()
	is_rotating = false
	print("Entered")

#Stop the timer once the player leaves the turret cone of vision
func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	$TurretTimer.stop()
	is_rotating = true
	print("Exited")
