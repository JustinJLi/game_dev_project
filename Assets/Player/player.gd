extends CharacterBody2D

const SPEED = 300.0
var screen_size
var bullet_speed = 1000
var bullet = preload("res://Assets/Environment/bullet.tscn")
var ammo = 8

func _ready() -> void:
	screen_size = get_viewport_rect().size
	print("Ammo in Magazine: " + str(ammo))

func _physics_process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		$AnimatedSprite2D.animation = "move"
	if Input.is_action_pressed("down"):
		velocity.y += 1
		$AnimatedSprite2D.animation = "move"
	if Input.is_action_pressed("right"):
		velocity.x += 1
		$AnimatedSprite2D.animation = "move"
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		$AnimatedSprite2D.animation = "move"
	if Input.is_action_just_pressed("shoot"):
		if ammo > 0:
			fire()
			print("Ammo in Magazine: " + str(ammo))
		else:
			print("Out of Ammo! Reload!")
	if Input.is_action_just_pressed("reload"):
		reload()
			
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
		
	look_at(get_global_mouse_position())
	
	move_and_slide()

func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = $Marker2D.global_position
	bullet_instance.rotation_degrees = $Marker2D.global_rotation_degrees + 90
	bullet_instance.linear_velocity = Vector2(bullet_speed,0).rotated(rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
	if ammo > 0:
		ammo -= 1
	else:
		print("Out of Ammo! Reload!")

func kill():
	get_tree().call_deferred("reload_current_scene")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name + " entered player.")
	
	

func reload():
	if ammo < 8:
		print("Reloading...")
		$reload.start()
	else:
		print("Magazine is Full!")

func _on_reload_timeout() -> void:
	ammo = 8
	print("Reloaded!")
