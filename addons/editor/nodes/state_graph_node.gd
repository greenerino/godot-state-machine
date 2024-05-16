@tool
class_name StateGraphNode
extends GraphNode

const output_color: Color = Color.RED

@export var state_scene: State = null:
	set(value):
		state_scene = value
		signals = build_signal_names()

@onready var signals: Array[String] = build_signal_names():
	set(value):
		signals = value
		draw_signal_names()

var signal_elements: Array[Control] = []

## Using the current state_scene, builds a list of all available signal names that
## exist on top of the base State class, including the `state_finished` signal.
func build_signal_names() -> Array[String]:
	if state_scene is State:
		var base_signals: Array[String] = signal_names(State.new().get_signal_list())
		var state_signals: Array[String] = signal_names(state_scene.get_signal_list())
		for sig: String in base_signals:
			if sig != "state_finished":
				state_signals.erase(sig)
		return state_signals
	else:
		return []

func signal_names(sigs: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	var sig_names: Array[Variant] = sigs.map(
		func(sig: Dictionary) -> String:
			return sig["name"]
	)
	result.assign(sig_names)
	return result

func draw_signal_names() -> void:
	for s in signals:
		var idx: int = add_signal_label(s)
		set_slot_enabled_right(idx + 1, true)
		set_slot_color_right(idx + 1, output_color)

## Adds a label corresponding to the given signal name, returns the index of that
## label in the signal_elements array.
func add_signal_label(sig_name: String) -> int:
	var label: Label = Label.new()
	label.text = sig_name
	add_child(label)
	label.owner = self
	signal_elements.append(label)
	return signal_elements.size() - 1

func free_signal_elements() -> void:
	for child in signal_elements:
		child.free()

func find_port_for_signal(s: String) -> int:
	var result := -1
	for idx in signal_elements.size():
		if signal_elements[idx].text == s:
			result = idx
	return result

func find_signal_for_port(p: int) -> String:
	return signal_elements[p].text
