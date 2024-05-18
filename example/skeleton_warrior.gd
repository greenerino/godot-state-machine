extends CharacterBody3D

@onready var anim_tree: AnimationTree = %AnimationTree

const RUN_SPEED = 5.0

func _physics_process(_delta: float) -> void:
	if velocity.length() > 0:
		rotation.y = atan2(velocity.x, velocity.z)
	anim_tree["parameters/blend_position"] = velocity.length() / RUN_SPEED
