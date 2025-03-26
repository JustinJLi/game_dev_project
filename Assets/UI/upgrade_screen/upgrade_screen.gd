extends Node2D



# Cost per upgrade level (this is an example; modify as needed)
var upgrade_costs = {
	"MaxHealth": 200,  # Example cost for MaxHealth upgrade
	"GunDmg": 150,     # Example cost for GunDmg upgrade
	"KnifeDmg": 100,   # Example cost for KnifeDmg upgrade
	"Map": 1000          # Example cost for Map upgrade
}

# Stores upgrade levels for each category
var stored_upgrade_multipliers = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}


# Maximum upgrade levels (3 bars)
const MAX_LEVEL = 3

var levels = [
	"res://Assets/Environment/world.tscn",
	"res://Assets/Environment/level_2.tscn",
	"res://Assets/Environment/level_3.tscn",
	"res://Assets/Environment/level_4.tscn",
	"res://Assets/Environment/level_5.tscn"

]

@onready var upgrade_screen: Node2D = $"."

var current_level_index = 0  # Track which level the player is on
#@onready var level_complete_screen = get_parent().get_node("CanvasLayer2/LevelCompleteScreen")  
@onready var total_points_label: Label = $TotalPointsLabel
@onready var total_cost_label: Label = $TotalCostLabel
var total_cost = 0
@onready var level_complete_screen: Node2D = $"../../CanvasLayer2/LevelCompleteScreen"
@onready var max_health_points_label: Label = $MaxHealthPointsLabel
@onready var gun_dmg_points_label: Label = $GunDmgPointsLabel
@onready var knife_dmg_points_label: Label = $KnifeDmgPointsLabel
@onready var map_points_label: Label = $MapPointsLabel



func _ready():
	#upgrade_screen.hide()

	update_total_points_label(Global.total_score_points)
	update_total_cost_label(total_cost)

	
	# Connect buttons dynamically
	_connect_buttons("MaxHealthPlusButton", "MaxHealthMinusButton", "MaxHealth")
	_connect_buttons("GunDamagePlusButton", "GunDamageMinusButton", "GunDmg")
	_connect_buttons("KnifeDamagePlusButton", "KnifeDamageMinusButton", "KnifeDmg")
	_connect_buttons("MapPlusButton", "MapMinusButton", "Map")
	#$ConfirmButton.connect("pressed", Callable(self, "_confirm_purchase"))


func _process(delta: float) -> void:
	update_total_points_label(Global.total_score_points)
	update_total_cost_label(total_cost)

func _connect_buttons(plus_name, minus_name, category):
	var plus_button = $PlusButtonsContainer.find_child(plus_name)
	var minus_button = $MinusButtonsContainer.find_child(minus_name)
	
	plus_button.connect("pressed", Callable(self, "_upgrade").bind(category, 1))
	minus_button.connect("pressed", Callable(self, "_upgrade").bind(category, -1))

func _upgrade(category, change):
	if category == "Map":
		Global.upgrade_bars_position[category] = clamp(Global.upgrade_bars_position[category] + change, 0, 1)
		stored_upgrade_multipliers[category] = clamp(stored_upgrade_multipliers[category] + change, 0, 1)
		_update_progress_bars(category)
	
	elif category in Global.upgrade_bars_position:
		Global.upgrade_bars_position[category] = clamp(Global.upgrade_bars_position[category] + change, 0, MAX_LEVEL)
		stored_upgrade_multipliers[category] = clamp(stored_upgrade_multipliers[category] + change, 0, MAX_LEVEL)
		_update_progress_bars(category)
	
	update_total_cost()



func update_total_cost():
	# Calculate the total cost based on upgrades
	total_cost = 0
	for category in Global.upgrade_bars_position.keys():
		total_cost += stored_upgrade_multipliers[category] * upgrade_costs[category]
		


func _update_progress_bars(category):
	# Handle progress bars differently based on category
	if category == "Map":
		# Handle Map upgrade with a single progress bar
		var bar = $MapUpgradeBarContainer.get_child(0)  # Assuming it's the first child (ProgressBar)
		var fill_stylebox = StyleBoxFlat.new()

		# Set the border radius to maintain rounded corners
		fill_stylebox.corner_radius_top_left = 10  # Adjust based on your design
		fill_stylebox.corner_radius_top_right = 10
		fill_stylebox.corner_radius_bottom_left = 10
		fill_stylebox.corner_radius_bottom_right = 10

		
		if Global.upgrade_bars_position[category] == 1:
			fill_stylebox.bg_color = Color(255, 255, 255)  # Green for upgrade
			bar.value = 100
		else:
			fill_stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Gray for no upgrade
			bar.value = 0
		bar.add_theme_stylebox_override("fill", fill_stylebox)

	
	else:
		# Handle other categories (MaxHealth, GunDmg, KnifeDmg) as before
		var bars_container = find_child(category + "UpgradeBarContainer")
		if bars_container == null:
			print("Error: Could not find container for", category)
			return
		
		var bars = bars_container.get_children()
		
		for i in range(MAX_LEVEL):
			var bar = bars[i]
			var fill_stylebox = StyleBoxFlat.new()
			
			# Set the border radius to maintain rounded corners
			fill_stylebox.corner_radius_top_left = 10  # Adjust based on your design
			fill_stylebox.corner_radius_top_right = 10
			fill_stylebox.corner_radius_bottom_left = 10
			fill_stylebox.corner_radius_bottom_right = 10
			
			
			if i < Global.upgrade_bars_position[category]: 
				fill_stylebox.bg_color = Color(255, 255, 255)  # Green when filled
				bar.value = 100
			else:
				fill_stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Gray when empty
				bar.value = 0
			
			bar.add_theme_stylebox_override("fill", fill_stylebox)

			
func update_total_points_label(player_points : int):
	total_points_label.text = "Total Points:                 " + str(player_points) + " Points"
	
func update_total_cost_label(total_cost : int):
	total_cost_label.text = "Total Cost:                 " + str(total_cost) + " Points"

		
func _on_confirm_button_pressed() -> void:
	if total_cost > Global.total_score_points:
		print("Not enough cash, stranger")
	elif total_cost <= Global.total_score_points:
		# Deduct points and apply the upgrades
		Global.total_score_points -= total_cost

		# Apply upgrades and update PlayerData
		for category in Global.upgrade_bars_position.keys():
			if category == "GunDmg":
				# Apply the gun damage upgrade
				if Global.upgrade_bars_position[category] > 0:
					PlayerData.gun_damage += Global.upgrade_bars_position[category] * 20  # Example: Each level adds 2 to gun damage
			elif category == "KnifeDmg":
				# Apply the knife damage upgrade
				if Global.upgrade_bars_position[category] > 0:
					PlayerData.knife_damage += Global.upgrade_bars_position[category] * 20  # Example: Each level adds 2 to knife damage
			elif category == "MaxHealth":
				# Apply the max health upgrade
				if Global.upgrade_bars_position[category] > 0:
					PlayerData.max_health += Global.upgrade_bars_position[category] * 200  # Example: Each level adds 20 to max health

		# Reset upgrade levels after confirmation
		for category in Global.upgrade_bars_position.keys():
			Global.upgrade_bars_position[category] = 0  # Reset upgrade bars position

		# After confirming, update the labels
		total_cost = 0
		update_total_points_label(Global.total_score_points)
		update_total_cost_label(total_cost)
		
	# Transition to next level
	_load_next_level()

# Load the next level
func _load_next_level():
	var current_scene_path = get_tree().current_scene.scene_file_path
	var index = levels.find(current_scene_path)

	if index != -1 and index < levels.size() - 1:
		current_level_index = index + 1
		get_tree().change_scene_to_file(levels[current_level_index])
	else:
		print("No more levels! Returning to main menu.")
		get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")
