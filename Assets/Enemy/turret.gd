extends CharacterBody2D
class_name turret

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var hud = get_parent().get_node("HUD")  
@onready var level_complete_screen = get_parent().get_node("Player/CanvasLayer2/LevelCompleteScreen")  
static var enemies_cleared = 0
static var enemies_killed_score = 0
@onready var healthbar = get_node("HealthBar")
@export var max_health = 300
var damage
static var total_enemies = 0
var health
var ammo_pickup = preload("res://Assets/Environment/Notes/ammo_pickup.tscn")
var enemy_dying = false
@onready var hostage: hostage = $"../Hostage"
var bullet_speed = 500
var bullet = preload("res://Assets/Enemy/turret_bullet.tscn")
@onready var player: CharacterBody2D = $"../Player"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	set_collision_layer_value(2, true)
	health = max_health
	hud = get_tree().get_first_node_in_group("hud")
	#healthbar.light_mask = 2
	#healthbar.visibility_layer = 1=
	
	# Increase total enemies count when spawned
	total_enemies += 1
	#enemies_cleared = 0
	#enemies_killed_score = 0




func _physics_process(delta: float) -> void:
	if player != null:
		if player.level_completed or enemy_dying:
			return

func take_damage(damage_amount):
	health -= damage_amount
	print("Enemy took ", damage_amount, " damage. Health: ", health)
	if health <= 0:
		total_enemies -= 1  # Decrease enemy count when defeated
		enemies_cleared += 1
		enemies_killed_score += 200
		hud.update_enemies_cleared_label(enemies_cleared)
		level_complete_screen.update_enemies_killed_score(enemies_cleared, enemies_killed_score)
		queue_free()
	
func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = $Marker2D.global_position
	bullet_instance.rotation = $Marker2D.global_rotation  
	bullet_instance.linear_velocity = Vector2(0, -bullet_speed).rotated($Marker2D.global_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)


func kill():
	get_tree().call_deferred("reload_current_scene")

func _on_interact():
	queue_free()

func _on_turret_timer_timeout() -> void:
	fire()


func _on_turret_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "bullet_hitbox":
		take_damage(50)
