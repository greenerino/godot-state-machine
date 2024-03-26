class_name StateMachine
extends Node

@export var initial_state: State = null
var curr_state: State = null

@export var delta_func: StateMachineDelta

func _ready() -> void:
	change_state(initial_state)

func change_state(next_state: State) -> void:
	if curr_state is State:
		curr_state._exit_state()
	curr_state = next_state
	next_state._enter_state()
