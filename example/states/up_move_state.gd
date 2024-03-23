extends State

@export var actor: Node3D = null

@onready var timer: Timer = %Timer

func _ready() -> void:
	super()

func _exit_state() -> void:
	super()

func _enter_state() -> void:
	timer.start()
	super()

func _physics_process(delta: float) -> void:
	if actor:
		actor.position.y += 2 * delta

func _on_timer_timeout() -> void:
	state_finished.emit()
