@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type(
		"StateMachine",
		"Node",
		preload("res://addons/state_machine/state_machine.gd"),
		preload("res://addons/state_machine/Node.svg")
	)
	add_custom_type(
		"State",
		"Node",
		preload("res://addons/state_machine/state.gd"),
		preload("res://addons/state_machine/Node.svg")
	)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("StateMachine")
	remove_custom_type("State")
