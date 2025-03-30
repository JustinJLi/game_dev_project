extends CharacterBody2D

var speed = 100.0 #Player speed
var dialog_close_delay = 0.0 #Delay for closing dialogue 
var screen_size #Size of screen
var bullet_speed = 1000 #Bullet velocity for player gun
var bullet = preload("res://Assets/Environment/bullet.tscn") #Preload bullet scene for instantiation upon firing
var crosshair = load("res://Assets/Art/crosshair.png") #preload crosshair to replace mouse cursor
var ammo = 8 #Max ammo in player magazine
var total_ammo = 24 #Initial ammo reserve
var max_health = 100 #Maximum player health
var health = max_health  # Player starts with full health
var player_move_animation = "move" #initial player animation

# Boolean variables, all representing specific states of certain events in game
var is_flashlight_on = true 
var is_reloading = false
var is_knifing = false
var is_mouse = true
var last_look_direction = Vector2.ZERO  # Store last direction from controller
var look_smoothness: float = 0.5 # Smoothness for controller look sensitivity
var player_damage = 0 #Represents damage done to the player

# Initializes several HUD components for the player
@onready var hud = get_parent().get_node("HUD") #General HUD scene
@onready var healthbar = get_parent().get_node("CanvasLayer/HUD/HealthBar") #Player healthvar
@onready var damagebar = get_parent().get_node("CanvasLayer/HUD/HealthBar/DamageBar") #Player healthvar
@onready var pause_menu = $CanvasLayer/PauseMenu #Pause menu
@onready var options_menu: Control = $CanvasLayer/PauseMenu/CanvasLayer/OptionsMenu #options menu
@onready var game_over_screen: Node2D = $CanvasLayer3/GameOverScreen #Game over screen
@onready var fullscreen_map: Node2D = $CanvasLayer5/FullScreenMap

var paused = false #Determines if player paused the game
var level_completed = false #Determines if a level is complete
var game_over = false #Determines if the player has lost (game over)

enum Weapon { GUN, KNIFE } #Dictionary for player weapons 
var current_weapon = Weapon.GUN #Current weapon held by the player
var weapon_name = "" #Stores weapon name
#var levels = [
	#"world",
	#"level_2",
	#"level_3",
	#"level_4",
	#"level_5"
#]
#var current_scene = ""


func _ready() -> void:
	#Initialize player hud with their persistent stats including health and ammo counts
	call_deferred("_initialize_hud")
	max_health = PlayerData.max_health
	healthbar.size.x = max_health
	damagebar.size.x = max_health
	healthbar.max_value = max_health
	damagebar.max_value = max_health
	#healthbar.value = max_health
	#damagebar.value = max_health
	health = PlayerData.health
	ammo = PlayerData.ammo
	total_ammo = PlayerData.total_ammo
	is_flashlight_on = PlayerData.is_flashlight_on
	
	#current_scene = get_tree().current_scene.to_string()

	#Initialize interaction with objects, screen, and mouse cursor
	InteractionManager.player = self
	Input.set_custom_mouse_cursor(crosshair)
	hud = get_tree().get_first_node_in_group("hud")
	screen_size = get_viewport_rect().size
	pause_menu.visible = false

	# Ensure default weapon and animations are set correctly
	$Flashlight.show()
	current_weapon = Weapon.GUN
	player_move_animation = "move"
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	
	print("Ammo in Magazine: " + str(ammo))
	print("Player Health: " + str(health))
	print("Total enemies in level: " + str(EnemyStats.total_enemies))
	print("Health: " + str(PlayerData.max_health))
	print("Gun Damage: " + str(PlayerData.gun_damage))
	print("Knife Damage: " + str(PlayerData.knife_damage))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Check for pause menu input
	if Input.is_action_just_pressed("pause"):
		pauseMenu() #Pause the game

func pauseMenu():
	#If paused, show pause menu and stop game timer, otherwise continue the game
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else: 
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

func _physics_process(delta):
	#Stop movement when game over, level complete, or paused
	if paused or level_completed or game_over:
		return  # Stop player movement when paused
		
	self.velocity = Vector2.ZERO # Initial player's movement vector.
	
	#Player movement + animation in all 4 directions
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

	#Shooting input reading
	if Input.is_action_just_pressed("shoot") and !is_reloading:
		weapon_handler()

	#Reloading input reading
	if Input.is_action_just_pressed("reload"):
		reload()
		
	#Sprint input reading
	if Input.is_action_pressed("sprint"):
		speed = 150.0
		
	if Input.is_action_just_released("sprint"):
		speed = 100.0
		
	#Flashlight toggle input reading
	if Input.is_action_just_pressed("toggle_flashlight") and current_weapon == Weapon.GUN:
		toggle_flashlight()
		
	if Input.is_action_just_released("toggle_map"):
		if PlayerData.has_map_upgrade:
			toggle_map()
		else:
			print("Need to purchase map")
	
	#Allow movement if velocity it > 0 (moving)
	if self.velocity.length() > 0:
		self.velocity = self.velocity.normalized() * speed
		
		if !$Walking.playing:
			$Walking.play()
	else:
		#Allow weapon swap while idle
		switch_weapon_animation()
		$Walking.stop()
		
	#Position normalization
	position += self.velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	#Controller player rotation
	if last_look_direction.length() > 0.1 and !is_mouse:
		look_at(global_position + last_look_direction * 10)
	
	#Allow player movement
	move_and_slide()

#Function for acquiring different inputs
func _input(event):
	# Acquire direction of right stick for player rotation
	var right_stick = Vector2(
		Input.get_action_strength("look_right") - Input.get_action_strength("look_left"),
		Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	)

	#If mouse input is read, use mouse for player rotation
	if event is InputEventMouseMotion or event is InputEventMouse:
		is_mouse = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		look_at(get_global_mouse_position())
	#Otherwise, hide mouse cursor and use controller input
	elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and right_stick.length() > 0.1):
		is_mouse = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		last_look_direction = last_look_direction.lerp(right_stick.normalized(), look_smoothness)

# Toggles map with specific image based on the level the player is on
func toggle_map():
	var map_images = fullscreen_map.get_children()
	
	if get_tree().current_scene.scene_file_path == "res://Assets/Environment/world.tscn":
		fullscreen_map.visible = !fullscreen_map.visible  # Toggle visibility
		map_images[1].visible = !map_images[1].visible
	elif get_tree().current_scene.scene_file_path == "res://Assets/Environment/level_2.tscn":
		fullscreen_map.visible = !fullscreen_map.visible  # Toggle visibility
		map_images[2].visible = !map_images[2].visible
	elif get_tree().current_scene.scene_file_path == "res://Assets/Environment/level_3.tscn":
		fullscreen_map.visible = !fullscreen_map.visible  # Toggle visibility
		map_images[3].visible = !map_images[3].visible
	elif get_tree().current_scene.scene_file_path == "res://Assets/Environment/level_4.tscn":
		fullscreen_map.visible = !fullscreen_map.visible  # Toggle visibility
		map_images[4].visible = !map_images[4].visible
	elif get_tree().current_scene.scene_file_path == "res://Assets/Environment/level_5.tscn":
		fullscreen_map.visible = !fullscreen_map.visible  # Toggle visibility
		map_images[5].visible = !map_images[5].visible
		
#Function for handling weapon switching/attacking
func weapon_handler():
	
	#Prevent weapon swapping after just closing dialog
	if Time.get_ticks_msec() < DialogueManager.dialog_close_delay:
		return
		
	#If the player is holding their gun and has ammo, allow firing
	if current_weapon == Weapon.GUN && ammo > 0:
		fire()
		print("Ammo in Magazine: " + str(ammo))
	#If the player is holding their knife and is stationary, allow stabbing
	elif current_weapon == Weapon.KNIFE && !is_knifing && self.velocity.length() == 0:
		attack_knife()
	
	#If the player is out of ammo, play bark to acknowledge empty
	if current_weapon == Weapon.GUN && ammo == 0:
		$EmptyClick.play()
		print("Out of Ammo! Reload!")

#Function to toggle player flashligh on their gun
func toggle_flashlight():
	if is_flashlight_on:
		#If the player is holding their gun, turn flashlight off
		if current_weapon == Weapon.GUN:
			$FlashlightToggle.play()
		$Flashlight.hide()
		is_flashlight_on = false
	else: #Otherwise turn it on
		if current_weapon == Weapon.GUN:
			$FlashlightToggle.play()
		$Flashlight.show()
		is_flashlight_on = true

#Function to switch weapons and player animation
func switch_weapon_animation():
	#If the player wants to switch weapons,
	if Input.is_action_just_pressed("switch_weapon"):
		#Turn off flashlight if applicable and switch to knife (including animations)
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
			#Update hud with knife as weapon
			hud.update_on_screen_weapon(weapon_name)
		else: #Otherwise turn on flashlight for gun, and switch to it
			if !is_flashlight_on:
				toggle_flashlight()
			current_weapon = Weapon.GUN
			player_move_animation = "move"
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.play()
			$Walking.stop()
			print("Switched to Gun")
			weapon_name = "Pistol"
			#Update hud with pistol as weapon
			hud.update_on_screen_weapon(weapon_name)

#Function for firing the player's gun
func fire():
	#Prevent firing if the game is over, player is dead, or the game is paused
	if paused || level_completed || game_over:
		return 
	
	#Instantiate and position bullet relative to gun on player model and apply velocity in direction of aim
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = $Marker2D.global_position
	bullet_instance.rotation_degrees = $Marker2D.global_rotation_degrees + 90
	bullet_instance.linear_velocity = Vector2(bullet_speed,0).rotated(rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
	#Prevent firing if the player is out of ammo
	if total_ammo && ammo == 0:
		print("Out of ammo")
	else: #otherwise, deplete ammo from player hud and update labels
		$Shoot.play()
		ammo -= 1
		PlayerData.ammo = ammo
		hud.update_bullet_label(ammo, total_ammo)
		
#Function for attacking with the knife
func attack_knife():
	is_knifing = true
	$AnimatedSprite2D/knife_hitbox.position = Vector2(150, 0)  # Move knife hitbox forward
	
	#Play knife attack animation + sounds
	$AnimatedSprite2D.animation = "knife_attack"
	$AnimatedSprite2D.play() 
	$KnifeAttack.play()
		
	await get_tree().create_timer(0.4).timeout  # Short attack animation
	is_knifing = false

	$AnimatedSprite2D/knife_hitbox.position = Vector2.ZERO  # Reset knife hitbox position
	
	#Stop animations
	$AnimatedSprite2D.stop()
	$KnifeAttack.stop()
	$AnimatedSprite2D.animation = "idle_knife"
	$AnimatedSprite2D.play()

#Function for taking damage from enemies
func take_damage(damage_amount):
	#If the player is dead, prevent additional damage from being taken
	if healthbar == null:
		print("Warning: HealthBar is null, skipping _set_health()")
		return

	#Deplete player health based on damage from attack, and deplete healthbar accordingly
	health -= damage_amount
	PlayerData.health = health
	healthbar._set_health(health)
	print("Player took ", damage_amount, "damage. Health: ", health)

	#If the player health is 0, game over
	if health <= 0:
		game_over = true
		kill()

#Function that occurs when the player dies
func kill():
	game_over_screen.show() #Show game over screen

#Checking for objects that enter player hitbox
func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name + " entered player.")
	
	#Prevent check if the level is complete
	if level_completed:
		return
	
	#If any enemies enter the player hitbox
	if body.is_in_group("Enemies"): 
		#If an enemy is dying, prevent damage
		if body.has_method("enemy_dying") and body.enemy_dying:
			$damage_buffer.stop()
			return
		else: #Otherwise, damage player and start a timer buffer to attack again if the player doesnt move
			player_damage = body.damage
			take_damage(body.damage)
			$damage_buffer.start()
			
#Once the player leaves the area of the attacker, stop the damage buffer
func _on_player_hitbox_body_exited(body: Node2D) -> void:
	$damage_buffer.stop()

# Function for reloading player weapon
func reload():
	#If the player is holding their gun
	if current_weapon == Weapon.GUN:
		if total_ammo == 0: #If player is out of reserve ammo, don't allow reloading
			print("Can't reload, out of ammo")
		elif ammo < 8: #If the player still has a few rounds in their magazine, allow reload
			print("Reloading...")
			is_reloading = true
			$Reload.play()
			$reload.start()
		else: #Otherwise, magazine is full and reload is not necessary
			print("Magazine is Full!")

#Once reload period is done
func _on_reload_timeout() -> void:
	var needed_ammo = 8 - ammo  # Find how much ammo we need to fill the magazine
	if total_ammo >= needed_ammo: #Deplete reserve ammo
		total_ammo -= needed_ammo
		ammo = 8 
	else: #Otherwise, perform a full reload
		ammo += total_ammo
		total_ammo = 0  # No more ammo left outside
	
	#Update hud and player data elements
	hud.update_bullet_label(ammo, total_ammo)
	PlayerData.ammo = ammo
	PlayerData.total_ammo = total_ammo
	is_reloading = false
	print("Reloaded!")

#Upon the buffer period if the player is still in contact with an enemy, take damage again
func _on_damage_buffer_timeout() -> void:
	if (!level_completed):
		take_damage(player_damage)  # Take damage if hit by an enemy

#Function for hud initialization between scenes
func _initialize_hud():
	#Initialize hud with player data
	if hud:
		hud.update_bullet_label(ammo, total_ammo)
		hud.update_on_screen_weapon(weapon_name)
		healthbar._set_health(health)
		print("HUD Initialized - Ammo:", ammo, "/", total_ammo, "| Health:", health)
	else:
		print("Error: HUD not found!")
