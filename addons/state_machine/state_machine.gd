class_name StateMachine
extends Node

@export var initial_state: State = null
var curr_state: State = null

@export var delta_func: StateMachineDelta

func _ready() -> void:
	apply_transitions()
	change_state(initial_state)

func apply_transitions() -> void:
	for transition in delta_func.transitions:
		var from_state: State = find_child(transition.from)
		var to_state: State = find_child(transition.to)
		if not from_state:
			push_warning("Source state %s not found in State Machine children" %[from_state])
		if not to_state:
			push_warning("Target state %s not found in State Machine children" %[to_state])
		if from_state and to_state:
			from_state.connect(transition.signal_name, change_state.bind(to_state))

func change_state(next_state: State) -> void:
	if curr_state is State:
		curr_state._exit_state()
	curr_state = next_state
	next_state._enter_state()
