class_name DeathState
extends State

@export var actor: CharacterBody3D = null
@export var despawn_time: float = 4.0

@onready var despawn_timer: Timer = %DespawnTimer

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()
	despawn_timer.timeout.disconnect(_on_despawn_timer_timeout)

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(_data: Dictionary = {}) -> void:
	super()
	despawn_timer.timeout.connect(_on_despawn_timer_timeout)
	despawn_timer.start(despawn_time)

func _on_despawn_timer_timeout() -> void:
	actor.queue_free()
