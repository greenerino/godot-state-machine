extends State

signal timer_finished(data: Dictionary)

@export var actor: Node3D = null

@onready var timer: Timer = %Timer

func _ready() -> void:
	super()

func _exit_state() -> void:
	super()

func _enter_state(_data: Dictionary = {}) -> void:
	timer.start()
	super()

func _physics_process(delta: float) -> void:
	if actor:
		actor.position.y += 2 * delta

func _on_timer_timeout() -> void:
	var data := {
		"speed": randi_range(1, 4)
	}
	timer_finished.emit(data)
