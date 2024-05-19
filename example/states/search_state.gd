class_name SearchState
extends State

signal player_detected(data: Dictionary)

@export var actor: CharacterBody3D = null
@export var player_detection_area: Area3D = null
@export var speed: float = 1.0
@export var wander_time: float = 1.5
@export var pause_time: float = 3.0

@onready var wander_timer: Timer = %WanderTimer
@onready var pause_timer: Timer = %PauseTimer

var direction: Vector3 = rand_direction()
var wandering: bool = false

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()
	player_detection_area.body_entered.disconnect(_on_player_detection_area_body_entered)
	pause_timer.timeout.disconnect(_on_pause_timer_timeout)
	wander_timer.timeout.disconnect(_on_wander_timer_timeout)
	pause_timer.stop()
	wander_timer.stop()
	player_detection_area.set_deferred("monitoring", false)

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(_data: Dictionary = {}) -> void:
	super()
	player_detection_area.body_entered.connect(_on_player_detection_area_body_entered)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	wander_timer.timeout.connect(_on_wander_timer_timeout)
	wandering = false
	pause_timer.start(pause_time)
	player_detection_area.set_deferred("monitoring", true)

func _on_wander_timer_timeout() -> void:
	wandering = false
	pause_timer.start(pause_time)

func _on_pause_timer_timeout() -> void:
	direction = rand_direction()
	wandering = true
	wander_timer.start(wander_time)

func _on_player_detection_area_body_entered(player: Node3D) -> void:
	player_detected.emit({ "player": player })

func rand_direction() -> Vector3:
	return Vector3.FORWARD.rotated(Vector3.UP, randf_range(0, TAU))

func _physics_process(_delta: float) -> void:
	if wandering:
		actor.velocity = direction * speed
	else:
		actor.velocity = Vector3.ZERO
	actor.move_and_slide()
