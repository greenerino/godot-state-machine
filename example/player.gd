class_name Player
extends CharacterBody3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var camera: Camera3D = null
@export var speed: float = 8.5

@onready var anim_tree: AnimationTree = %AnimationTree

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized().rotated(Vector3.UP, camera.rotation.y)
	if direction:
		velocity.x = direction.x
		velocity.z = direction.z
		velocity = velocity.normalized() * speed
		rotation.y = atan2(velocity.x, velocity.z)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	anim_tree["parameters/blend_position"] = velocity.length() / speed
