class_name StateMachine
extends Node

@export var initial_state: State = null
var curr_state: State = null

# TODO: having difficulty accessing this via the GraphEdit, probably due to misunderstanding
# between tool scripts and runtime scripts. Might need the Delta type to be an exported resource,
# so we can actually save it to this scene?
var delta_func: StateMachineDelta = StateMachineDelta.new()

func _ready() -> void:
	change_state(initial_state)

func change_state(next_state: State) -> void:
	if curr_state is State:
		curr_state._exit_state()
	curr_state = next_state
	next_state._enter_state()
