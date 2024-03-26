@tool
class_name Transition
extends Resource
@export var from: String
@export var signal_name: StringName
@export var to: String

func _init(f: String = "", sig: StringName = "", t: String = "") -> void:
	from = f
	signal_name = sig
	to = t

func props() -> Array:
	return [from, signal_name, to]

func equals(t: Transition) -> bool:
	return props() == t.props()

