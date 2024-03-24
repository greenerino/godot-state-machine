class_name StateMachineDelta
extends Object

class Transition:
	extends Object
	var from: State
	var signal_name: StringName
	var to: State

	func _init(f: State, sig: StringName, t: State) -> void:
		from = f
		signal_name = sig
		to = t
	
	func props() -> Array:
		return [from, signal_name, to]

	func equals(t: Transition) -> bool:
		return props() == t.props()
	
var transitions: Array[Transition] = []

func add_transition(from: State, signal_name: StringName, to: State) -> void:
	transitions.append(Transition.new(from, signal_name, to))

func remove_transition(from: State, signal_name: StringName, to: State) -> void:
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
