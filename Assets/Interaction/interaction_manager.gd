extends Node2D

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var label: Label = $Label

const base_text = "[E] to "

var active_areas: Array[InteractionArea] = []
var can_interact: bool = true

func register_area(area: InteractionArea) -> void:
	active_areas.push_back(area)
	
func unregister_area(area: InteractionArea) -> void:
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position - Vector2(label.size.x / 2, 36)
		label.show()
	else:
		label.hide()
		
func _sort_by_distance_to_player(area1: InteractionArea, area2: InteractionArea) -> int:
	if player == null:
		print("Warning: Player instance is null!")
		return 0
	var dist1 = player.global_position.distance_to(area1.global_position)
	var dist2 = player.global_position.distance_to(area2.global_position)
	return -1 if dist1 < dist2 else 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			if active_areas[0].interact != null:
				await active_areas[0].interact.call()
			
			can_interact = true
