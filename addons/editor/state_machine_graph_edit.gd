@tool
class_name StateMachineGraphEdit
extends GraphEdit

const StateGraphNodeScene = preload("res://addons/editor/nodes/state_graph_node.tscn")

var curr_state_machine: StateMachine = null

func _ready() -> void:
	EditorInterface.get_inspector().edited_object_changed.connect(_on_edited_object_changed)

func _on_edited_object_changed() -> void:
	var selections: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	var state_machine: StateMachine = find_first_state_machine(selections)
	if state_machine:
	# if state_machine and state_machine != curr_state_machine:
		curr_state_machine = state_machine
		clear_graph_nodes()
		for child in state_machine.get_children():
			if child is State:
				var state_node: StateGraphNode = StateGraphNodeScene.instantiate()
				state_node.title = child.name
				add_child(state_node)

func find_first_state_machine(nodes: Array[Node]) -> StateMachine:
	var found: Node = nodes.reduce(
		func(accum: Node, n: Node) -> Node:
			if accum:
				return accum
			elif n is StateMachine:
				return n
			else:
				return null
	)
	return found if found is StateMachine else null

func clear_graph_nodes() -> void:
	for child in get_children():
		if child is GraphNode:
			child.queue_free()

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print([from_node, from_port, to_node, to_port])
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)