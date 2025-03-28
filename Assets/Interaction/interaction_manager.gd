extends Node2D

#get the player and the label used in the interaction
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var label: Label = $Label

#Default text and variables used to determine access to interaction
const keyboard_text = "[E] to "
const controller_text = "[X] to "
var active_areas: Array[InteractionArea] = []
var can_interact: bool = true

#Function to add an area for interaction
func register_area(area: InteractionArea) -> void:
	active_areas.push_back(area)
	
#Function to remove an area for interaction
func unregister_area(area: InteractionArea) -> void:
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Display label above object if player is within distance
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		#Display text based on input device
		if player.is_mouse:
			label.text = keyboard_text + active_areas[0].action_name
		else:
			label.text = controller_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position - Vector2(label.size.x / 2, 36)
		label.show()
	else:
		label.hide()
		
#Function to calculate the distance between the player and an interactable object
func _sort_by_distance_to_player(area1: InteractionArea, area2: InteractionArea) -> int:
	if player == null:
		print("Warning: Player instance is null!")
		return 0
	var dist1 = player.global_position.distance_to(area1.global_position)
	var dist2 = player.global_position.distance_to(area2.global_position)
	return -1 if dist1 < dist2 else 1

#Allow interaction with object IF the player is within proximity and is within an interactable area
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			if active_areas[0].interact != null:
				await active_areas[0].interact.call()
			
			can_interact = true
