extends CharacterBody2D
class_name enemy

@onready var hud = get_parent().get_node("HUD")  
var enemies_cleared = 0
@onready var healthbar = get_node("HealthBar")
var max_health = 100
var health = max_health





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")

	#healthbar.light_mask = 2
	#healthbar.visibility_layer = 1
	healthbar.hide()




func _physics_process(delta: float) -> void:
	#var player = get_parent().get_node("Pl+ayer")
	
	#position += (Player.position - position) / 100
	#look_at(player.position)
	move_and_slide()
	
func take_damage(damage_amount):
	health -= damage_amount
	healthbar._set_health(health)
	print("Enemy took ", damage_amount, " damage. Health: ", health)

	if health <= 0:
		enemies_cleared += 1
		hud.update_enemies_cleared_label(enemies_cleared)
		queue_free()
	
func kill():
	get_tree().call_deferred("reload_current_scene")

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	if area.name == "bullet_hitbox":
		take_damage(50)
		
		
	#if area.name == "player_hitbox":
		#kill()
