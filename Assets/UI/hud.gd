extends Control

# Exported variables for UI labels, which can be set in the editor
#@export var bullet_label : Label
@onready var bullet_label: Label = $Pistol/BulletLabel
@export var hostages_cleared_label : Label
@export var enemies_cleared_label : Label
@export var map_label : Label

# Nodes for ammo container and bullets
@onready var ammo_container = $Pistol/PistolAmmoContainer
@onready var bullets = ammo_container.get_children()  # Get the children of the ammo container (bullets)

# Nodes for weapons (Pistol, Knife) and player
@onready var pistol: CanvasLayer = $Pistol
@onready var knife: CanvasLayer = $Knife
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

# Updates the bullet label to show current and total ammo
func update_bullet_label(current_ammo: int, total_ammo: int):
	bullet_label.text = str(current_ammo) + " / " + str(total_ammo)

	# Change color based on ammo count
	if current_ammo == 0:
		bullet_label.modulate = Color(1,0,0)
	else:
		bullet_label.modulate = Color(1,1,1)

	update_bullet_graphics(current_ammo)  # Update the visual representation of the bullets


# Updates the bullet graphics based on the current ammo count
func update_bullet_graphics(current_ammo: int):
	# Loop through all bullet icons and set their visibility depending on the current ammo
	for i in range(len(bullets)):
		bullets[i].visible = i < current_ammo  # Only show the number of bullets remaining

# Updates the label showing the number of hostages cleared
func update_hostages_cleared_label(num_hostages : int):
	hostages_cleared_label.text = "Hostages Cleared x " + str(num_hostages)

# Updates the label showing the number of enemies cleared
func update_enemies_cleared_label(num_enemies : int):
	enemies_cleared_label.text = "Enemies Cleared x " + str(num_enemies)

# Switches between showing the current weapon (either Knife or Pistol)
func update_on_screen_weapon(weapon_name : String):
	if weapon_name == "Knife":
		pistol.hide()  # Hide pistol
		knife.show()   # Show knife
	elif weapon_name == "Pistol":
		pistol.show()  # Show pistol
		knife.hide()   # Hide knife

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# By default, show the pistol and hide the knife
	pistol.show()
	knife.hide()
	# Show the map if the player has the map upgrade, otherwise hide it
	if PlayerData.has_map_upgrade:
		$MapTexture.show()
		$MapTexture/MapLabel.show()
	else:
		$MapTexture.hide()
		$MapTexture/MapLabel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	# Updates the map label text based on whether the player is using mouse or controller
	if player.is_mouse:
		$MapTexture/MapLabel.text = "[m]"  # If mouse and keyboard is being used
	else:
		$MapTexture/MapLabel.text = "[select]"  # If controller is being used
