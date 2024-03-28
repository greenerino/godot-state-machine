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
		if not curr_state_machine.delta_func is StateMachineDelta:
			curr_state_machine.delta_func = StateMachineDelta.new()
			EditorInterface.mark_scene_as_unsaved()
		clear_graph_nodes()
		for child_idx in state_machine.get_children().size():
			var child: Node = state_machine.get_child(child_idx)
			if child is State:
				var graph_node: StateGraphNode = StateGraphNodeScene.instantiate()
				graph_node.title = child.name
				if curr_state_machine.delta_func.graph_coords.has(graph_node.title):
					graph_node.position_offset = curr_state_machine.delta_func.graph_coords[graph_node.title]
				else:
					graph_node.position_offset = Vector2.RIGHT.rotated((TAU / state_machine.get_child_count()) * child_idx) * 50 * state_machine.get_children().size()
					curr_state_machine.delta_func.graph_coords[graph_node.title] = graph_node.position_offset
				add_child(graph_node)

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

## Since there doesn't seem to be an explicit "disconnect" request from the Editor, we interpret
## a double connection as a disconnect. Thus, if the connection already exists, we delegate to
## _on_disconnection_request(). Otherwise, we continue with adding the transition and connecting
## the node.
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node, false, false)
	var from_state_name: String = from_graph_node.title
	var to_graph_node: GraphNode = find_child(to_node, false, false)
	var to_state_name: String = to_graph_node.title
	if curr_state_machine.delta_func.has_transition(from_state_name, "state_finished", to_state_name):
		_on_disconnection_request(from_node, from_port, to_node, to_port)
	else:
		curr_state_machine.delta_func.add_transition(from_state_name, "state_finished", to_state_name)
		EditorInterface.mark_scene_as_unsaved()
		connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node, false, false)
	var from_state_name: String = from_graph_node.title
	var to_graph_node: GraphNode = find_child(to_node, false, false)
	var to_state_name: String = to_graph_node.title
	curr_state_machine.delta_func.remove_transition(from_state_name, "state_finished", to_state_name)
	EditorInterface.mark_scene_as_unsaved()
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_end_node_move() -> void:
	if not curr_state_machine.delta_func.graph_coords:
		curr_state_machine.delta_func.graph_coords = {}
	for child in get_children():
		if child is GraphNode:
			curr_state_machine.delta_func.graph_coords[child.title] = child.position_offset
