extends Node

@export var initial_state : State

var current_state : State
var states : Dictionary = {}


func _ready() -> void:
	#Get all th states that the child has and enter the initial state given to them
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			
	if initial_state:
		initial_state.Enter()
		current_state = initial_state


#Making the Update function apply to _process
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

#Making the Physics_Update function apply to _physics_process
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

#Transition into new states, if required
func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	
	current_state = new_state
