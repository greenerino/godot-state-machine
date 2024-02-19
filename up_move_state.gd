extends State

@export var actor: Node3D = null

@onready var timer: Timer = %Timer

func _ready() -> void:
	set_physics_process(false)

func _exit_state() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	timer.start()
	super()

func _physics_process(delta: float) -> void:
	if actor:
		actor.position.y += 2 * delta

func _on_timer_timeout() -> void:
	state_finished.emit()
