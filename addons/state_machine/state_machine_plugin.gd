@tool
extends EditorPlugin

const MainPanel = preload("res://addons/editor/main.tscn")
var main_panel_instance : Control = null

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "State Machine"

func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

	# TODO: May be able to use EditorInterface.....get_icon() and remove the Node.svg from source
	add_custom_type(
		"StateMachine",
		"Node",
		preload("res://addons/state_machine/state_machine.gd"),
		preload("res://addons/state_machine/Node.svg")
	)
	add_custom_type(
		"State",
		"Node",
		preload("res://addons/state_machine/state.gd"),
		preload("res://addons/state_machine/Node.svg")
	)

func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()
	main_panel_instance = null

	remove_custom_type("StateMachine")
	remove_custom_type("State")

func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _handles(object: Object) -> bool:
	return object is StateMachine