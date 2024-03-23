extends Node3D

@onready var sm: StateMachine = %StateMachine
@onready var u_state: State = %UpMoveState
@onready var d_state: State = %DownMoveState
@onready var g_state: State = %GrowState

func _ready() -> void:
	u_state.state_finished.connect(sm.change_state.bind(g_state))
	g_state.state_finished.connect(sm.change_state.bind(d_state))
	d_state.state_finished.connect(sm.change_state.bind(u_state))
