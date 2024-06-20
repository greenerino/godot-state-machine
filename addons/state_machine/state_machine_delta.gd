@tool
class_name StateMachineDelta
extends Resource

signal transition_added(transition: Transition)
signal transition_removed(transition: Transition)

@export var transitions: Array[Transition] = []
@export var graph_coords: Dictionary = {}

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

## Like find_transition, but only checks the from and signal name of the transition
func find_outgoing_transition(from: String, signal_name: StringName) -> int:
	var target := Transition.new(from, signal_name)
	var idx := 0
	var found := false
	while idx < transitions.size() and not found:
		var actual_transition := transitions[idx]
		var candidate := Transition.new(actual_transition.from, actual_transition.signal_name)
		if candidate.equals(target):
			found = true
		else:
			idx += 1
	return idx if found else -1

func has_transition(from: String, signal_name: StringName, to: String) -> bool:
	return find_transition(from, signal_name, to) > -1

## Returns true if there exists any transition coming from the given state with the given signal
func has_outgoing_transition(from: String, signal_name: StringName) -> bool:
	return find_outgoing_transition(from, signal_name) > -1

func add_transition(from: String, signal_name: StringName, to: String) -> void:
	remove_outgoing_transition(from, signal_name)
	if not has_transition(from, signal_name, to): # Just in case. We really don't want duplicates
		var t: Transition = Transition.new(from, signal_name, to)
		transitions.append(t)
		emit_transition_added(t)

func remove_outgoing_transition(from: String, signal_name: StringName) -> void:
	var idx := find_outgoing_transition(from, signal_name)
	remove_transition_at_idx(idx)

func remove_transition(from: String, signal_name: StringName, to: String) -> void:
	var idx := find_transition(from, signal_name, to)
	remove_transition_at_idx(idx)

func remove_transition_at_idx(idx: int) -> void:
	if idx > -1:
		var t := transitions[idx]
		transitions.remove_at(idx)
		emit_transition_removed(t)

func emit_transition_added(t: Transition) -> void:
	emit_changed()
	transition_added.emit(t)

func emit_transition_removed(t: Transition) -> void:
	emit_changed()
	transition_removed.emit(t)

func inspect() -> void:
	print("Inspecting %s" %[self])
	for t in transitions:
		if t is Transition:
			print("Transition: %s" %[t.props()])
		else:
			print("Unknown: %s" %[t])
