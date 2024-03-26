@tool
class_name StateMachineDelta
extends Resource

@export var transitions: Array[Transition] = []

func _init() -> void:
	changed.connect(_on_changed)

func _on_changed() -> void:
	inspect()

func add_transition(from: String, signal_name: StringName, to: String) -> void:
	transitions.append(Transition.new(from, signal_name, to))
	emit_changed()

func remove_transition(from: String, signal_name: StringName, to: String) -> void:
	var target := Transition.new(from, signal_name, to)
	var idx := 0
	var found := false
	while idx < transitions.size() and not found:
		if transitions[idx].equals(target):
			found = true
		else:
			idx += 1
	if found:
		transitions.remove_at(idx)
		emit_changed()

func inspect() -> void:
	print("Inspecting %s" %[self])
	for t in transitions:
		if t is Transition:
			print("Transition: %s" %[t.props()])
		else:
			print("Unknown: %s" %[t])