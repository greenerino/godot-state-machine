class_name State
extends Node

signal state_finished

@export_group("Physics", "physics")
## When enabled, physics processing will be enabled and disabled
## upon entering and exiting the state, respectively.
##
## When disabled, set_physics_process() will not be called at all.
## This gives you the option to handle this on your own.
@export var physics_enabled: bool = false


# TODO: Animation documentation
@export_group("Animation")
@export var animation_name: StringName = ""
@export var end_state_on_animation_end: bool = false

@export_subgroup("Animation Player")
@export var animation_player: AnimationPlayer = null

@export_subgroup("Animation Tree")
@export var animation_tree: AnimationTree = null
@export var anim_tree_state_name: StringName = ""
@export var anim_tree_state_machine_playback_path: StringName = "parameters/playback"

@export_group("")

func _ready() -> void:
	if physics_enabled:
		set_physics_process(false)

func _exit_state() -> void:
	if physics_enabled:
		set_physics_process(false)
	
	if animation_player and animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)
	if animation_tree and animation_tree.animation_finished.is_connected(_on_animation_finished):
		animation_tree.animation_finished.disconnect(_on_animation_finished)

func _enter_state(_data: Dictionary = {}) -> void:
	if physics_enabled:
		set_physics_process(true)

	if animation_player and not animation_name.is_empty():
		animation_player.animation_finished.connect(_on_animation_finished)
		animation_player.play(animation_name)
	elif animation_tree and not anim_tree_state_name.is_empty():
		var anim_sm: AnimationNodeStateMachinePlayback = animation_tree[anim_tree_state_machine_playback_path]
		anim_sm.travel(anim_tree_state_name)
		animation_tree.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(n: StringName) -> void:
	if end_state_on_animation_end and n == animation_name:
		state_finished.emit()
