extends Node

var total_score_points = 0
var total_player_points = 0
var enemies_killed_points = 0
var hostages_rescued_points = 0
var hostages_killed_points = 0

# Stores upgrade levels for each category
var upgrade_bars_position = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}

var upgrade_bars_new_lowest_position = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}

var has_max_upgrades = {
	"MaxHealth": false,
	"GunDmg": false,
	"KnifeDmg": false,
	"Map": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
