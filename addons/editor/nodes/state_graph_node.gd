@tool
class_name StateGraphNode
extends GraphNode

@export var state_scene : State = null

func _on_clear_button_pressed() -> void:
	pass

func _on_add_button_pressed() -> void:
	var child: Label = Label.new()
	child.text = "another"
	add_child(child)
