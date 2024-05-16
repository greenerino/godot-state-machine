@tool
class_name StateMachineDelta
extends Resource

@export var transitions: Array[Transition] = []
@export var graph_coords: Dictionary = {}

func _init() -> void:
	changed.connect(_on_changed)

func _on_changed() -> void:
	inspect()

## Returns the first index of the matching Transition, otherwise -1
func find_transition(from: String, signal_name: StringName, to: String) -> int:
	var target := Transition.new(from, signal_name, to)
	var idx := 0
	var found := false
	while idx < transitions.size() and not found:
		if transitions[idx].equals(target):
			found = true
		else:
			idx += 1
	return idx if found else -1

func has_transition(from: String, signal_name: StringName, to: String) -> bool:
	return find_transition(from, signal_name, to) > -1

func add_transition(from: String, signal_name: StringName, to: String) -> void:
	if not has_transition(from, signal_name, to):
		transitions.append(Transition.new(from, signal_name, to))
		emit_changed()

func remove_transition(from: String, signal_name: StringName, to: String) -> void:
	var idx := find_transition(from, signal_name, to)
	if idx > -1:
		transitions.remove_at(idx)
		emit_changed()

func inspect() -> void:
	print("Inspecting %s" %[self])
	for t in transitions:
		if t is Transition:
			print("Transition: %s" %[t.props()])
		else:
			print("Unknown: %s" %[t])
