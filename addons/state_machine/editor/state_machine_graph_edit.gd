@tool
class_name StateMachineGraphEdit
extends GraphEdit

const StateGraphNodeScene = preload("res://addons/state_machine/editor/nodes/state_graph_node.tscn")

var curr_state_machine: StateMachine = null

func _ready() -> void:
	EditorInterface.get_inspector().edited_object_changed.connect(_on_edited_object_changed)
	scroll_offset_changed.connect(_on_scroll_offset_changed)

func _on_edited_object_changed() -> void:
	var selections: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	var new_state_machine: StateMachine = find_first_state_machine(selections)
	if new_state_machine:
		if is_instance_valid(curr_state_machine):
			disconnect_sm_delta_signals(curr_state_machine)
		curr_state_machine = new_state_machine
		if not new_state_machine.delta_func is StateMachineDelta:
			new_state_machine.delta_func = StateMachineDelta.new()
			EditorInterface.mark_scene_as_unsaved()
		connect_sm_delta_signals(new_state_machine)
		clear_graph_nodes()
		draw_current_sm_graph_nodes()
		if new_state_machine.editor_scroll_offset:
			# Assignment order matters here. Changing zoom also changes the offset, so we need
			# to overwrite that automatic change.
			zoom = new_state_machine.editor_zoom
			scroll_offset = new_state_machine.editor_scroll_offset
		else:
			zoom = 1.0
			scroll_offset = midpoint() - (size / 2)

## Returns the center relative to the existing graph nodes
func midpoint() -> Vector2:
	var min_x: float = INF
	var max_x: float = -INF
	var min_y: float = INF
	var max_y: float = -INF
	for child in get_children():
		if child is GraphNode:
			min_x = min(min_x, child.position_offset.x)
			max_x = max(max_x, child.position_offset.x + child.size.x)
			min_y = min(min_y, child.position_offset.y)
			max_y = max(max_y, child.position_offset.y + child.size.y)
	return Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)

func _on_scroll_offset_changed(offset: Vector2) -> void:
	if curr_state_machine:
		curr_state_machine.editor_scroll_offset = offset
		curr_state_machine.editor_zoom = zoom

func find_first_state_machine(nodes: Array[Node]) -> StateMachine:
	for node in nodes:
		if node is StateMachine:
			return node
	return null

func disconnect_sm_delta_signals(sm: StateMachine) -> void:
	if sm and sm.delta_func:
		var d := sm.delta_func
		if d.transition_added.is_connected(_on_delta_transition_added):
			d.transition_added.disconnect(_on_delta_transition_added)
		if d.transition_removed.is_connected(_on_delta_transition_removed):
			d.transition_removed.disconnect(_on_delta_transition_removed)

func connect_sm_delta_signals(sm: StateMachine) -> void:
	if sm and sm.delta_func:
		var d := sm.delta_func
		d.transition_added.connect(_on_delta_transition_added)
		d.transition_removed.connect(_on_delta_transition_removed)

func _on_delta_transition_added(t: Transition) -> void:
	draw_transition(t)

func _on_delta_transition_removed(t: Transition) -> void:
	erase_transition(t)

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
		draw_transition(transition)

func draw_transition(t: Transition) -> void:
	draw_or_erase_transition(t, connect_node)

func erase_transition(t: Transition) -> void:
	draw_or_erase_transition(t, disconnect_node)

func draw_or_erase_transition(t: Transition, callback: Callable) -> void:
	var from_graph_node: GraphNode = find_graph_node_by_title(t.from)
	var from_graph_port: int = from_graph_node.find_port_for_signal(t.signal_name)
	var to_graph_node: GraphNode = find_graph_node_by_title(t.to)

	if from_graph_port < 0:
		push_error("Signal %s not found on node %s" %[t.signal_name, from_graph_node])

	callback.call(from_graph_node.name, from_graph_port, to_graph_node.name, 0)

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
##
## We want to rely on the sm.delta_func as a source of truth, so we only add/remove transitions to that
## structure in these functions. We then listen to signals on the StateMachineDelta in order to draw them.
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

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, _to_port: int) -> void:
	var from_graph_node: GraphNode = find_child(from_node)
	var from_state_name: String = from_graph_node.title
	var from_state_signal: String = from_graph_node.find_signal_for_port(from_port)
	var to_graph_node: GraphNode = find_child(to_node)
	var to_state_name: String = to_graph_node.title
	curr_state_machine.delta_func.remove_transition(from_state_name, from_state_signal, to_state_name)
	EditorInterface.mark_scene_as_unsaved()

func _on_end_node_move() -> void:
	if not curr_state_machine.delta_func.graph_coords:
		curr_state_machine.delta_func.graph_coords = {}
	for child in get_children():
		if child is GraphNode:
			curr_state_machine.delta_func.graph_coords[child.title] = child.position_offset
