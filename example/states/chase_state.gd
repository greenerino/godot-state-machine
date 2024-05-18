class_name ChaseState
extends State

signal player_lost

@export var actor: CharacterBody3D = null
@export var player_chase_area: Area3D = null
@export var chase_speed: float = 5.0

var player: Player = null

# Calling super() will provide built in functionality such as
# automatic animation playing and enabling/disabling physics processing
func _ready() -> void:
	super()

# Handle cleanup here.
# If you called super() from _enter_state, be sure to call it in _exit_state as well.
func _exit_state() -> void:
	super()
	player = null
	player_chase_area.body_exited.disconnect(_on_player_chase_area_body_exited)

# If you pass a Dictionary as a single argument in a signal from another State,
# that data will be passed to _enter_state.
func _enter_state(data: Dictionary = {}) -> void:
	super()
	if data.has("player"):
		player = data["player"]
	else:
		push_warning("Player not provided to ChaseState. Data: ", data)
		player = null
	if not player:
		# it is ok to immediately emit a signal that exits the state
		player_lost.emit()
	player_chase_area.body_exited.connect(_on_player_chase_area_body_exited)

func _on_player_chase_area_body_exited(_body: Node3D) -> void:
	player_lost.emit()

func _physics_process(_delta: float) -> void:
	var to_player := player.global_position - actor.global_position
	to_player.y = 0
	actor.velocity = to_player.normalized() * chase_speed
	actor.move_and_slide()
