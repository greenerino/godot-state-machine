class_name State
extends Node

signal state_finished

@export_group("Animation")
@export var animation_player: AnimationPlayer = null
@export var animation_name: StringName = ""
@export_group("")

func _exit_state() -> void:
	pass

func _enter_state() -> void:
	if animation_player and not animation_name.is_empty():
		animation_player.play(animation_name)
