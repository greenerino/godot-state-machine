extends State

@export var actor: Node3D = null

@onready var timer: Timer = %Timer

var speed: int = 4

func _ready() -> void:
	super()

func _exit_state() -> void:
	super()

func _enter_state(data: Dictionary = {}) -> void:
	timer.start()
	speed = data.get("speed", speed)
	super()

func _physics_process(delta: float) -> void:
	if actor:
		actor.position.y += -speed * delta

func _on_timer_timeout() -> void:
	state_finished.emit()
