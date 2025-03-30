extends Node 

# Stores the player's total points accumulated across levels
var total_score_points = 0

# Score breakdown for different actions
var enemies_killed_points = 0
var hostages_rescued_points = 0
var hostages_killed_points = 0

# Dictionary to track the positions of the upgrade level bars for each category
var upgrade_bars_position = {
	"MaxHealth": 0,  # Upgrade level for maximum health
	"GunDmg": 0,     # Upgrade level for gun damage
	"KnifeDmg": 0,   # Upgrade level for knife damage
	"Map": 0         # Upgrade level for map-related enhancements
}

# Temporary storage for upgrade bar positions (used for calculating cost of upgrade based on position)
var upgrade_bars_position_temp = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}

# Tracks the new lowest position for each upgrade (prevents downgrading below a certain level)
var upgrade_bars_new_lowest_position = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}

# Boolean dictionary to track whether a category has reached its max upgrade level
var has_max_upgrades = {
	"MaxHealth": false,
	"GunDmg": false,
	"KnifeDmg": false,
	"Map": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
