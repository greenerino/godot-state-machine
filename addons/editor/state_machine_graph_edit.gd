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
		draw_current_sm_graph_nodes()

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

func draw_current_sm_graph_nodes() -> void:
	# Add GraphNode children based on state machine children
	for child_idx in curr_state_machine.get_children().size():
		var child: Node = curr_state_machine.get_child(child_idx)
		if child is State:
			var graph_node: StateGraphNode = StateGraphNodeScene.instantiate()
			graph_node.title = child.name
			if curr_state_machine.delta_func.graph_coords.has(graph_node.title):
				graph_node.position_offset = curr_state_machine.delta_func.graph_coords[graph_node.title]
			else:
				graph_node.position_offset = Vector2.RIGHT.rotated((TAU / curr_state_machine.get_child_count()) * child_idx) * 50 * curr_state_machine.get_children().size()
				curr_state_machine.delta_func.graph_coords[graph_node.title] = graph_node.position_offset
			add_child(graph_node)
			graph_node.owner = self
	# Connect nodes based on existing connections
	# TODO will need to do some lookups to figure out which ports to connect to based on the signal name
	for transition in curr_state_machine.delta_func.transitions:
		var from_graph_node: GraphNode = find_graph_node_by_title(transition.from)
		var to_graph_node: GraphNode = find_graph_node_by_title(transition.to)
		connect_node(from_graph_node.name, 0, to_graph_node.name, 0)

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
	var to_graph_node: GraphNode = find_child(to_node)
	var to_state_name: String = to_graph_node.title
	if curr_state_machine.delta_func.has_transition(from_state_name, "state_finished", to_state_name):
		_on_disconnection_request(from_node, from_port, to_node, to_port)
	else:
		curr_state_machine.delta_func.add_transition(from_state_name, "state_finished", to_state_name)
		# TODO add history
		EditorInterface.mark_scene_as_unsaved()
		connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node)
	var from_state_name: String = from_graph_node.title
	var to_graph_node: GraphNode = find_child(to_node)
	var to_state_name: String = to_graph_node.title
	curr_state_machine.delta_func.remove_transition(from_state_name, "state_finished", to_state_name)
	# TODO add history
	EditorInterface.mark_scene_as_unsaved()
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_end_node_move() -> void:
	if not curr_state_machine.delta_func.graph_coords:
		curr_state_machine.delta_func.graph_coords = {}
	for child in get_children():
		if child is GraphNode:
			curr_state_machine.delta_func.graph_coords[child.title] = child.position_offset
