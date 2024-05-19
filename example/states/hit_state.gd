class_name HitState
extends State

signal hit(data: Dictionary)
signal death

@export var stats: Stats = null

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
func _enter_state(data: Dictionary = {}) -> void:
	super()
	if not data.has("damage"):
		push_error("HitState called without damage: ", data)
		state_finished.emit()
	
	var source: Variant = data.get("source_location")
	var dmg: int = data["damage"]
	stats.health -= dmg
	if stats.health > 0:
		hit.emit({ "source_location": source })
	else:
		death.emit()
