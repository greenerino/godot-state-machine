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
		curr_state_machine = state_machine
		if not curr_state_machine.delta_func is StateMachineDelta:
			curr_state_machine.delta_func = StateMachineDelta.new()
			EditorInterface.mark_scene_as_unsaved()
		clear_graph_nodes()
		draw_current_sm_graph_nodes()

func find_first_state_machine(nodes: Array[Node]) -> StateMachine:
	for node in nodes:
		if node is StateMachine:
			return node
	return null

func draw_current_sm_graph_nodes() -> void:
	# Add GraphNode children based on state machine children
	for child_idx in curr_state_machine.get_children().size():
		var child: Node = curr_state_machine.get_child(child_idx)
		if child is State:
			var graph_node: StateGraphNode = StateGraphNodeScene.instantiate()
			graph_node.title = child.name
			graph_node.state_scene = child
			if curr_state_machine.delta_func.graph_coords.has(graph_node.title):
				graph_node.position_offset = curr_state_machine.delta_func.graph_coords[graph_node.title]
			else:
				graph_node.position_offset = Vector2.RIGHT.rotated((TAU / curr_state_machine.get_child_count()) * child_idx) * 50 * curr_state_machine.get_children().size()
				curr_state_machine.delta_func.graph_coords[graph_node.title] = graph_node.position_offset
			add_child(graph_node)
			graph_node.owner = self

	# Connect nodes based on existing connections
	for transition in curr_state_machine.delta_func.transitions:
		var from_graph_node: GraphNode = find_graph_node_by_title(transition.from)
		var from_graph_port: int = from_graph_node.find_port_for_signal(transition.signal_name)
		var to_graph_node: GraphNode = find_graph_node_by_title(transition.to)

		if from_graph_port < 0:
			push_error("Signal %s not found on node %s" %[transition.signal_name, from_graph_node])
		connect_node(from_graph_node.name, from_graph_port, to_graph_node.name, 0)

func find_graph_node_by_title(title: String) -> GraphNode:
	for child in get_children():
		if child is GraphNode and child.title == title:
			return child
	return null

func clear_graph_nodes() -> void:
	clear_connections()
	for child in get_children():
		if child is GraphNode:
			child.free()

## Since there doesn't seem to be an explicit "disconnect" request from the Editor, we interpret
## a double connection as a disconnect. Thus, if the connection already exists, we delegate to
## _on_disconnection_request(). Otherwise, we continue with adding the transition and connecting
## the node.
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node)
	var from_state_name: String = from_graph_node.title
	var from_state_signal: String = from_graph_node.find_signal_for_port(from_port)
	var to_graph_node: GraphNode = find_child(to_node)
	var to_state_name: String = to_graph_node.title
	if curr_state_machine.delta_func.has_transition(from_state_name, from_state_signal, to_state_name):
		_on_disconnection_request(from_node, from_port, to_node, to_port)
	else:
		curr_state_machine.delta_func.add_transition(from_state_name, from_state_signal, to_state_name)
		EditorInterface.mark_scene_as_unsaved()
		connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node)
	var from_state_name: String = from_graph_node.title
	var from_state_signal: String = from_graph_node.find_signal_for_port(from_port)
	var to_graph_node: GraphNode = find_child(to_node)
	var to_state_name: String = to_graph_node.title
	curr_state_machine.delta_func.remove_transition(from_state_name, from_state_signal, to_state_name)
	EditorInterface.mark_scene_as_unsaved()
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_end_node_move() -> void:
	if not curr_state_machine.delta_func.graph_coords:
		curr_state_machine.delta_func.graph_coords = {}
	for child in get_children():
		if child is GraphNode:
			curr_state_machine.delta_func.graph_coords[child.title] = child.position_offset
