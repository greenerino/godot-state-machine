class_name State
extends Node

signal state_finished

@export_group("Physics", "physics")
## When enabled, physics processing will be enabled and disabled
## upon entering and exiting the state, respectively.
@export var physics_enabled: bool = false

@export_group("Animation")
## When set along with animation_name, the corresponding animation
## will automatically be played upon state enter.
@export var animation_player: AnimationPlayer = null
@export var animation_name: StringName = ""

@export_group("")

func _ready() -> void:
	if physics_enabled:
		set_physics_process(false)

func _exit_state() -> void:
	# If physics_enabled is false, we still don't want to mess with this since
	# the extended state may have decided to delegate this to itself
	if physics_enabled:
		set_physics_process(false)

func _enter_state() -> void:
	if physics_enabled:
		set_physics_process(true)

	if animation_player and not animation_name.is_empty():
		animation_player.play(animation_name)
