extends CharacterBody2D

const SPEED = 100.0
var dialog_close_delay = 0.0
var screen_size
var bullet_speed = 1000
var bullet = preload("res://Assets/Environment/bullet.tscn")
var ammo = 8
var total_ammo = 24
var max_health = 100
var health = max_health  # Player starts with full health
var is_flashlight_on = true
var is_reloading = false
var is_knifing = false
var player_damage = 0
@onready var hud = get_parent().get_node("HUD")  
@onready var healthbar = get_parent().get_node("CanvasLayer/HUD/HealthBar")
#@onready var healthbar = $HealthBar

@onready var pause_menu = $CanvasLayer/PauseMenu
#@onready var flashlight = $Flashlight
@onready var options_menu: Control = $CanvasLayer/PauseMenu/CanvasLayer/OptionsMenu
@onready var game_over_screen: Node2D = $CanvasLayer3/GameOverScreen

var paused = false
var level_completed = false
var game_over = false

enum Weapon { GUN, KNIFE }
var current_weapon = Weapon.GUN
var weapon_name = ""

var player_move_animation = "move"


func _ready() -> void:
	InteractionManager.player = self
	hud = get_tree().get_first_node_in_group("hud")
	screen_size = get_viewport_rect().size
	pause_menu.visible = false
	$Flashlight.show()
	# Ensure default weapon and animations are set correctly
	current_weapon = Weapon.GUN
	player_move_animation = "move"
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

	
	### Initialize the health bar with full health
	#healthbar.init_health(max_health)
	#healthbar.health = health
	
	print("Ammo in Magazine: " + str(ammo))
	print("Player Health: " + str(health))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else: 
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

func _physics_process(delta):
	if paused or level_completed or game_over:
		return  # Stop player movement when paused
	self.velocity = Vector2.ZERO # The player's movement vector.
	
	if Input.is_action_pressed("up"):
		self.velocity.y -= 1
		$AnimatedSprite2D.animation = player_move_animation
	if Input.is_action_pressed("down"):
		self.velocity.y += 1
		$AnimatedSprite2D.animation = player_move_animation
	if Input.is_action_pressed("right"):
		self.velocity.x += 1
		$AnimatedSprite2D.animation = player_move_animation
	if Input.is_action_pressed("left"):
		self.velocity.x -= 1
		$AnimatedSprite2D.animation = player_move_animation

	if Input.is_action_just_pressed("shoot") and !is_reloading:
		weapon_handler()

	if Input.is_action_just_pressed("reload"):
		reload()
		
	if Input.is_action_just_pressed("toggle_flashlight"):
		toggle_flashlight()
			
	if self.velocity.length() > 0:
		self.velocity = self.velocity.normalized() * SPEED
		#$AnimatedSprite2D.play(player_move_animation)
		
		if !$Walking.playing:
			$Walking.play()
	else:
		switch_weapon_animation()
			#$AnimatedSprite2D.play("idle")
		$Walking.stop()
		
	position += self.velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
		
	look_at(get_global_mouse_position())
	
	move_and_slide()
	
	
func weapon_handler():
	if Time.get_ticks_msec() < DialogueManager.dialog_close_delay:
		return
		
	#$AnimatedSprite2D.animation = "shoot"
	if current_weapon == Weapon.GUN && ammo > 0:
		fire()
		print("Ammo in Magazine: " + str(ammo))
	elif current_weapon == Weapon.KNIFE && !is_knifing && self.velocity.length() == 0:
		attack_knife()
	
	if current_weapon == Weapon.GUN && ammo == 0:
		$EmptyClick.play()
		print("Out of Ammo! Reload!")

func toggle_flashlight():
	if is_flashlight_on:
		$FlashlightToggle.play()
		$Flashlight.hide()
		is_flashlight_on = false
	else:
		$FlashlightToggle.play()
		$Flashlight.show()
		is_flashlight_on = true

func switch_weapon_animation():
	if Input.is_action_just_pressed("switch_weapon"):
		if current_weapon == Weapon.GUN:
			if is_flashlight_on:
				toggle_flashlight()
			current_weapon = Weapon.KNIFE
			player_move_animation = "move_knife"
			$AnimatedSprite2D.animation = "idle_knife"
			$AnimatedSprite2D.play()
			$Walking.stop()
			print("Switched to Knife")
			weapon_name = "Knife"
			hud.update_on_screen_weapon(weapon_name)
		else:
			if !is_flashlight_on:
				toggle_flashlight()
			current_weapon = Weapon.GUN
			player_move_animation = "move"
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.play()
			$Walking.stop()
			print("Switched to Gun")
			weapon_name = "Pistol"
			hud.update_on_screen_weapon(weapon_name)

func fire():
	if paused || level_completed || game_over:
		return  # Stop player movement when paused
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = $Marker2D.global_position
	bullet_instance.rotation_degrees = $Marker2D.global_rotation_degrees + 90
	bullet_instance.linear_velocity = Vector2(bullet_speed,0).rotated(rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
	if total_ammo && ammo == 0:
		print("Out of ammo")
	else:
		$Shoot.play()
		ammo -= 1
		hud.update_bullet_label(ammo, total_ammo)
		
func attack_knife():
	is_knifing = true
	$AnimatedSprite2D/knife_hitbox.position = Vector2(150, 0)  # Move knife forward
	
	$AnimatedSprite2D.animation = "knife_attack"
	$AnimatedSprite2D.play() 
	$KnifeAttack.play()
		
	await get_tree().create_timer(0.4).timeout  # Short attack duration
	is_knifing = false

	$AnimatedSprite2D/knife_hitbox.position = Vector2.ZERO  # Reset position
	
	$AnimatedSprite2D.stop()
	$KnifeAttack.stop()
	$AnimatedSprite2D.animation = "idle_knife"
	$AnimatedSprite2D.play()

func take_damage(damage_amount):
	if healthbar == null:
		print("Warning: HealthBar is null, skipping _set_health()")
		return

	health -= damage_amount
	healthbar._set_health(health)
	print("Player took ", damage_amount, "damage. Health: ", health)

	if health <= 0:
		game_over = true
		kill()


func kill():
	game_over_screen.show()
	#get_tree().call_deferred("reload_current_scene")

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print(body.name + " entered player.")
	
	if body.is_in_group("Enemies"):  
		if body.has_method("enemy_dying") and body.enemy_dying:
			$damage_buffer.stop()
			return
		else:
			player_damage = body.damage
			take_damage(body.damage)
			$damage_buffer.start()
			
func _on_player_hitbox_body_exited(body: Node2D) -> void:
	$damage_buffer.stop()

#func _on_KnifeHitbox_area_entered(area: Area2D):
	#if area.is_in_group("Enemies"):
		#var enemy = area.get_parent()
		#enemy.take_damage(25)  # Knife deals 25 damage
		#print("Enemy hit with knife!")

func reload():
	if current_weapon == Weapon.GUN:
		if total_ammo == 0:
			print("Can't reload, out of ammo")
		#elif total_ammo < 8:
			#ammo = total_ammo
			
		elif ammo < 8:
			print("Reloading...")
			is_reloading = true
			$Reload.play()
			$reload.start()
		else:
			print("Magazine is Full!")

func _on_reload_timeout() -> void:
	var needed_ammo = 8 - ammo  # How much ammo we need to fill the magazine
	if total_ammo >= needed_ammo:
		total_ammo -= needed_ammo
		ammo = 8  # Full reload
	else:
		ammo += total_ammo
		total_ammo = 0  # No more ammo left outside
	hud.update_bullet_label(ammo, total_ammo)
	is_reloading = false
	print("Reloaded!")


func _on_damage_buffer_timeout() -> void:
	take_damage(player_damage)  # Take damage if hit by an enemy
