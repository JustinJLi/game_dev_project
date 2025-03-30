extends Node2D

# Cost per upgrade level for each category (modify as needed)
var upgrade_costs = {
	"MaxHealth": 2000,  # Cost for upgrading MaxHealth
	"GunDmg": 1500,     # Cost for upgrading GunDmg
	"KnifeDmg": 1000,   # Cost for upgrading KnifeDmg
	"Map": 1500          # Cost for upgrading Map
}

# Stores upgrade level multipliers for each category
var stored_upgrade_multipliers = {
	"MaxHealth": 0,
	"GunDmg": 0,
	"KnifeDmg": 0,
	"Map": 0
}

# Maximum upgrade levels (3 bars max)
const MAX_LEVEL = 3

# List of level paths in the game
var levels = [
	"res://Assets/Environment/world.tscn",
	"res://Assets/Environment/level_2.tscn",
	"res://Assets/Environment/level_3.tscn",
	"res://Assets/Environment/level_4.tscn",
	"res://Assets/Environment/level_5.tscn"
]

# onready variables to reference UI elements
var current_level_index = 0  # Track which level the player is on
@onready var total_points_label: Label = $TotalPointsLabel
@onready var total_cost_label: Label = $TotalCostLabel
var total_cost = 0
@onready var level_complete_screen: Node2D = $"../../CanvasLayer2/LevelCompleteScreen"
@onready var max_health_points_label: Label = $MaxHealthPointsLabel
@onready var gun_dmg_points_label: Label = $GunDmgPointsLabel
@onready var knife_dmg_points_label: Label = $KnifeDmgPointsLabel
@onready var map_points_label: Label = $MapPointsLabel
@onready var not_enough_points_popup: AcceptDialog = $NotEnoughPointsPopup
@onready var plus_buttons = {}  # Store plus buttons to disable them later
@onready var max_health_upgrade_bar_container: HBoxContainer = $MaxHealthUpgradeBarContainer
@onready var gun_dmg_upgrade_bar_container: HBoxContainer = $GunDmgUpgradeBarContainer
@onready var knife_dmg_upgrade_bar_container: HBoxContainer = $KnifeDmgUpgradeBarContainer
@onready var map_upgrade_bar_container: HBoxContainer = $MapUpgradeBarContainer



# Called when the node enters the scene tree for the first time
func _ready():
	# Update the UI labels with total points and cost on startup
	update_total_points_label(Global.total_score_points)
	update_total_cost_label(total_cost)

	# Connect the upgrade buttons dynamically for each category
	_connect_buttons("MaxHealthPlusButton", "MaxHealthMinusButton", "MaxHealth")
	_connect_buttons("GunDmgPlusButton", "GunDmgMinusButton", "GunDmg")
	_connect_buttons("KnifeDmgPlusButton", "KnifeDmgMinusButton", "KnifeDmg")
	_connect_buttons("MapPlusButton", "MapMinusButton", "Map")
	#$ConfirmButton.connect("pressed", Callable(self, "_confirm_purchase"))

	# Update progress bars based on global upgrade positions
	for category in Global.upgrade_bars_position:
		_update_progress_bars(category)
	
	# Disable upgrade buttons for categories that are at max upgrade level
	for category in Global.has_max_upgrades:
		if Global.has_max_upgrades[category] == true:
			var plus_button = $PlusButtonsContainer.find_child(category + "PlusButton")
			var minus_button = $MinusButtonsContainer.find_child(category + "MinusButton")
			plus_button.disabled = true
			minus_button.disabled = true
		
		# Set a new lowest postion for upgrade bar position to avoid going back on upgrades
		if Global.upgrade_bars_position[category] >= 1:
			Global.upgrade_bars_new_lowest_position[category] = Global.upgrade_bars_position[category]


# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	# Continuously update the points and total cost display
	update_total_points_label(Global.total_score_points)
	update_total_cost_label(total_cost)

	# Disable minus buttons if the category is at its lowest level
	for category in Global.upgrade_bars_position:
		if Global.upgrade_bars_position[category] == Global.upgrade_bars_new_lowest_position[category]:
			var minus_button = $MinusButtonsContainer.find_child(category + "MinusButton")
			minus_button.disabled = true
		else:
			var minus_button = $MinusButtonsContainer.find_child(category + "MinusButton")
			minus_button.disabled = false


# Dynamically connect plus and minus buttons to the upgrade system
func _connect_buttons(plus_name, minus_name, category):
	var plus_button = $PlusButtonsContainer.find_child(plus_name)
	var minus_button = $MinusButtonsContainer.find_child(minus_name)
	
	plus_button.connect("pressed", Callable(self, "_upgrade").bind(category, 1))  # Connect to upgrade function
	minus_button.connect("pressed", Callable(self, "_upgrade").bind(category, -1))  # Connect to upgrade function
	
	# Store plus buttons to disable them when max level is reached
	plus_buttons[category] = plus_button

# Handle upgrade logic for each category
func _upgrade(category, change):
	if category == "Map":
		# Handle map upgrade (only one level)
		Global.upgrade_bars_position[category] = clamp(Global.upgrade_bars_position[category] + change, 0, 1)
		stored_upgrade_multipliers[category] = clamp(stored_upgrade_multipliers[category] + change, 0, 1)
		_update_progress_bars(category)
	else:
		# Handle other categories with 3 as max level (MaxHealth, GunDmg, KnifeDmg)
		Global.upgrade_bars_position[category] = clamp(Global.upgrade_bars_position[category] + change, 0, MAX_LEVEL)
		stored_upgrade_multipliers[category] = clamp(stored_upgrade_multipliers[category] + change, 0, MAX_LEVEL)
		_update_progress_bars(category)
	
	# Disable plus button if the maximum level is reached
	if category == "Map":
		if category in plus_buttons:
			plus_buttons[category].disabled = Global.upgrade_bars_position[category] >= 1
	elif category in plus_buttons:
		plus_buttons[category].disabled = Global.upgrade_bars_position[category] >= MAX_LEVEL
	
	# Update total cost after the upgrade
	update_total_cost()



# Calculate the total cost of all upgrades based on their positions
func update_total_cost():
	total_cost = 0
	# Loop through all categories and calculate their total upgrade cost
	for category in Global.upgrade_bars_position.keys():
		total_cost += stored_upgrade_multipliers[category] * upgrade_costs[category]
		


# Update the progress bars based on the current level of each category
func _update_progress_bars(category):
	if category == "Map":
		# Special handling for the Map upgrade (only one progress bar)
		var bar = $MapUpgradeBarContainer.get_child(0) 
		var fill_stylebox = StyleBoxFlat.new()

		# Set rounded corners for the progress bar
		fill_stylebox.corner_radius_top_left = 10
		fill_stylebox.corner_radius_top_right = 10
		fill_stylebox.corner_radius_bottom_left = 10
		fill_stylebox.corner_radius_bottom_right = 10
		
		# Update bar color and value based on upgrade status
		if Global.upgrade_bars_position[category] == 1:
			fill_stylebox.bg_color = Color(255, 255, 255)  # White for upgrade
			bar.value = 100
		else:
			fill_stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Black for no upgrade
			bar.value = 0
		bar.add_theme_stylebox_override("fill", fill_stylebox)
	else:
		# Handle other categories (MaxHealth, GunDmg, KnifeDmg)
		var bars_container = find_child(category + "UpgradeBarContainer")
		if bars_container == null:
			print("Error: Could not find container for", category)
			return
		
		var bars = bars_container.get_children()
		
		# Update each bar based on the current upgrade level
		for i in range(MAX_LEVEL):
			var bar = bars[i]
			var fill_stylebox = StyleBoxFlat.new()
			
			# Set rounded corners for each progress bar
			fill_stylebox.corner_radius_top_left = 10
			fill_stylebox.corner_radius_top_right = 10
			fill_stylebox.corner_radius_bottom_left = 10
			fill_stylebox.corner_radius_bottom_right = 10
			
			# Update color and progress based on the upgrade level
			if i < Global.upgrade_bars_position[category]: 
				fill_stylebox.bg_color = Color(255, 255, 255)  # White when filled
				bar.value = 100
			else:
				fill_stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Black when empty
				bar.value = 0
			
			bar.add_theme_stylebox_override("fill", fill_stylebox)

# Update the label displaying total points
func update_total_points_label(player_points : int):
	total_points_label.text = "Total Points:                 " + str(player_points) + " Points"

# Update the label displaying the total cost of upgrades
func update_total_cost_label(total_cost : int):
	total_cost_label.text = "Total Cost:                 " + str(total_cost) + " Points"

		
func _on_confirm_button_pressed() -> void:
	# Check if the player has enough points to confirm the purchase
	if total_cost > Global.total_score_points:
		print("Not enough cash stranger")
		# Show popup when not enough points
		not_enough_points_popup.show()
		not_enough_points_popup.popup_centered()
	elif total_cost <= Global.total_score_points:
		# Deduct points from the player's total if they can afford the upgrades
		Global.total_score_points -= total_cost

		# Apply upgrades to the player data based on their current upgrade levels
		for category in Global.upgrade_bars_position.keys():
			# Check if the player has reached max upgrades for a category
			if Global.upgrade_bars_position[category] >= MAX_LEVEL:
				Global.has_max_upgrades[category] = true

			# Apply the upgrades based on the category
			if category == "GunDmg":
				# Apply the gun damage upgrade
				if Global.upgrade_bars_position[category] > Global.upgrade_bars_new_lowest_position[category]:
					# Save the temporary position for gun damage upgrade
					Global.upgrade_bars_position_temp[category] = Global.upgrade_bars_position[category]
					# Increase gun damage based on the upgrade level
					PlayerData.gun_damage += Global.upgrade_bars_position_temp[category] * 20  # Example: Each level adds 20 to gun damage

			elif category == "KnifeDmg":
				# Apply the knife damage upgrade
				if Global.upgrade_bars_position[category] > Global.upgrade_bars_new_lowest_position[category]:
					# Save the temporary position for knife damage upgrade
					Global.upgrade_bars_position_temp[category] = Global.upgrade_bars_position[category]
					# Increase knife damage based on the upgrade level
					PlayerData.knife_damage += Global.upgrade_bars_position_temp[category] * 20  # Example: Each level adds 20 to knife damage

			elif category == "MaxHealth":
				# Apply the max health upgrade
				if Global.upgrade_bars_position[category] > Global.upgrade_bars_new_lowest_position[category]:
					# Save the temporary position for max health upgrade
					Global.upgrade_bars_position_temp[category] = Global.upgrade_bars_position[category]
					# Increase max health based on the upgrade level
					PlayerData.max_health += Global.upgrade_bars_position_temp[category] * 50  # Example: Each level adds 50 to max health

			elif category == "Map":
				# Check if the player has already purchased the map upgrade
				if Global.upgrade_bars_position["Map"] >= 1:
					# If the map is purchased, mark it as fully upgraded
					Global.has_max_upgrades[category] = true

				# Apply the map upgrade if applicable
				if Global.upgrade_bars_position[category] > 0:
					PlayerData.has_map_upgrade = true  # Set map upgrade to true when the player purchases the map upgrade

		# After the purchase, reset the temporary upgrade levels
		for category in Global.upgrade_bars_position_temp.keys():
			Global.upgrade_bars_position_temp[category] = 0  # Reset temporary upgrade bars position

		# After confirming the purchase, reset the total cost and update the UI labels
		total_cost = 0
		update_total_points_label(Global.total_score_points)  # Update points label
		update_total_cost_label(total_cost)  # Reset cost label to 0

		# Transition to the next level or return to main menu if no more levels
		_load_next_level()

# Function to load the next level or go to the main menu if there are no more levels
func _load_next_level():
	# Get the current scene's file path to determine the current level
	var current_scene_path = get_tree().current_scene.scene_file_path
	# Find the current level index in the levels list
	var index = levels.find(current_scene_path)

	# If there is a next level, change to it, otherwise go back to the main menu
	if index != -1 and index < levels.size() - 1:
		# Increment to the next level
		current_level_index = index + 1
		get_tree().change_scene_to_file(levels[current_level_index])  # Transition to the next level
	else:
		print("No more levels! Returning to main menu.")
		# If no more levels, load the main menu scene
		get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")
