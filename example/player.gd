class_name Player
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var anim_tree: AnimationTree = %AnimationTree
const RUN_SPEED = 5.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	anim_tree["parameters/IdleRun/blend_position"] = velocity.length() / RUN_SPEED
