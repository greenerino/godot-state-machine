class_name SkeletonWarrior
extends CharacterBody3D

@onready var anim_tree: AnimationTree = %AnimationTree
@onready var sm: StateMachine = %StateMachine
@onready var hit_state: HitState = %StateMachine/HitState

const RUN_SPEED := 5.0
const BLEND_POSITION_PATH := "parameters/IdleRun/blend_position"

func _physics_process(_delta: float) -> void:
	if sm.curr_state is KnockbackState or velocity.length() == 0:
		anim_tree[BLEND_POSITION_PATH] = 0
	elif velocity.length() > 0:
		rotation.y = atan2(velocity.x, velocity.z)
		anim_tree[BLEND_POSITION_PATH] = velocity.length() / RUN_SPEED

func _on_hurt_box_area_entered(area: Area3D) -> void:
	sm.change_state_with_data(
		{
			"damage": 1,
			"source_location": area.global_position
		},
	hit_state)
