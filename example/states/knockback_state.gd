class_name KnockbackState
extends State

@export var actor: CharacterBody3D = null
@export var knockback_speed: float = 5.0
@export var knockback_time: float = 1.0

@onready var timer: Timer = %Timer

var has_source := false
var source_location := Vector3.ZERO

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()
	timer.one_shot = true

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()
	has_source = false
	source_location = Vector3.ZERO
	timer.timeout.disconnect(_on_timer_timeout)

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(data: Dictionary = {}) -> void:
	super()
	timer.timeout.connect(_on_timer_timeout)
	if data.has("source_location"):
		has_source = true
		source_location = data["source_location"]
	timer.start(knockback_time)

func _physics_process(_delta: float) -> void:
	if has_source:
		var direction := actor.global_position - source_location
		direction.y = 0
		direction = direction.normalized()
		actor.velocity = direction * knockback_speed
	else:
		actor.velocity = Vector3.ZERO
	actor.move_and_slide()

func _on_timer_timeout() -> void:
	state_finished.emit()
