extends Node

#Default player stat values
var health = 100
var max_health = 100
var ammo = 8
var total_ammo = 24
var is_flashlight_on = true
var current_weapon = "GUN"
var gun_damage = 50
var knife_damage = 25 
var has_map_upgrade = false

# Call this to reset stats if needed
func reset():
	health = max_health
	ammo = 8
	total_ammo = 24
	is_flashlight_on = true
	current_weapon = "GUN"
	gun_damage = 50
	knife_damage = 25
	has_map_upgrade = false
