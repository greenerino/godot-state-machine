extends State

@export var actor: CharacterBody3D = null
@export var speed: float = 8.5

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(_data: Dictionary = {}) -> void:
	super()

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized().rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)
	if direction:
		actor.velocity.x = direction.x
		actor.velocity.z = direction.z
		actor.velocity = actor.velocity.normalized() * speed
		actor.rotation.y = atan2(actor.velocity.x, actor.velocity.z)
	else:
		actor.velocity.x = 0
		actor.velocity.z = 0
	actor.move_and_slide()
