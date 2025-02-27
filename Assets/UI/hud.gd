extends Control

@export var bullet_label : Label
@export var hostages_cleared_label : Label
@export var enemies_cleared_label : Label

@onready var ammo_container = $Pistol/PistolAmmoContainer
@onready var bullets = ammo_container.get_children()
# Called when the node enters the scene tree for the first time.
#var weapons_array = ["Knife", "Pistol"]
@onready var pistol: CanvasLayer = $Pistol
@onready var knife: CanvasLayer = $Knife


func update_bullet_label(current_ammo: int, total_ammo: int):
		bullet_label.text = str(current_ammo) + " / " + str(total_ammo)
		update_bullet_graphics(current_ammo)

# Updates bullet icons based on current ammo
func update_bullet_graphics(current_ammo: int):
	for i in range(len(bullets)):
		bullets[i].visible = i < current_ammo  # Show only the number of bullets left

func update_hostages_cleared_label(num_hostages : int):
	hostages_cleared_label.text = "Hostages Cleared x " + str(num_hostages)

func update_enemies_cleared_label(num_enemies : int):
	enemies_cleared_label.text = "Enemies Cleared x " + str(num_enemies)
	

func update_on_screen_weapon(weapon_name : String):
	if weapon_name == "Knife":
		pistol.hide()
		knife.show()
	elif weapon_name == "Pistol":
		pistol.show()
		knife.hide()

func _ready() -> void:
	pistol.show()
	knife.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
