class_name PlayerSwingState
extends State

@export var hitbox: Area3D = null
@export var anticipate: float = 0.5
@export var contact: float = 0.1

@onready var anticipate_timer: Timer = %AnticipateTimer
@onready var contact_timer: Timer = %ContactTimer

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()
	anticipate_timer.timeout.connect(_on_anticipate_timer_timeout)
	contact_timer.timeout.connect(_on_contact_timer_timeout)

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()
	set_hitbox_status(false)
	anticipate_timer.stop()
	contact_timer.stop()

func _on_anticipate_timer_timeout() -> void:
	set_hitbox_status(true)
	contact_timer.start(contact)

func _on_contact_timer_timeout() -> void:
	set_hitbox_status(false)

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(_data: Dictionary = {}) -> void:
	super()
	anticipate_timer.start(anticipate)

func set_hitbox_status(status := false) -> void:
	if hitbox:
		hitbox.monitorable = status
		for child in hitbox.get_children():
			if child is CollisionShape3D:
				child.disabled = not status
