@tool
class_name StateMachine
extends Node

@export var initial_state: State = null:
	set(value):
		initial_state = value
		update_configuration_warnings()
var curr_state: State = null

@export_group("Internal")
@export var delta_func: StateMachineDelta
@export var editor_scroll_offset: Vector2
@export var editor_zoom: float = 1.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		apply_transitions()
		change_state(initial_state)

func _get_configuration_warnings() -> PackedStringArray:
	var warns: PackedStringArray = []
	if initial_state == null:
		warns.append("Initial state is not set.")
	elif not is_ancestor_of(initial_state):
		warns.append("Initial state is not a child of this State Machine.")
	return warns

func apply_transitions() -> void:
	for transition in delta_func.transitions:
		var from_state: State = find_child(transition.from)
		var to_state: State = find_child(transition.to)
		if not from_state:
			push_error("Source state %s not found in State Machine children. Aborting transition %s." %[from_state, transition.props()])
		if not to_state:
			push_error("Target state %s not found in State Machine children. Aborting transition %s." %[to_state, transition.props()])
		if from_state and to_state:
			var sig: Dictionary = find_signal_by_name(from_state, transition.signal_name)
			if sig.has("args"):
				var args: Array[Dictionary] = sig["args"]
				if args.size() == 1 and args[0]["type"] == TYPE_DICTIONARY:
					from_state.connect(transition.signal_name, change_state_with_data.bind(to_state))
				elif args.size() == 0:
					from_state.connect(transition.signal_name, change_state.bind(to_state))
				else:
					push_error("Signal %s must either pass no arguments or a Dictionary argument. Aborting transition %s." %[transition.signal_name, transition.props()])

func find_signal_by_name(state: State, sig_name: StringName) -> Dictionary:
	var sig_list: Array[Dictionary] = state.get_signal_list()
	for sig in sig_list:
		if sig["name"] == sig_name:
			return sig
	push_error("Signal %s not found in State %s." %[sig_name, state])
	return {}

func change_state(next_state: State) -> void:
	change_state_with_data({}, next_state)

func change_state_with_data(data: Dictionary, next_state: State) -> void:
	if curr_state is State:
		curr_state._exit_state()
	curr_state = next_state
	next_state._enter_state(data)
