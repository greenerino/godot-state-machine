# State Machine
A simple state machine plugin for Godot based on [Heartbeast's Finite State Machine](https://www.youtube.com/watch?v=qwOM3v8T33Q) ([GitHub](https://github.com/uheartbeast/FSM-Tutorial)). I just found myself rewriting it so often in my own projects that I extracted it as a plugin.

## Installation
Copy the `addons/state_machine` directory into the `addons` directory at the root of your Godot project, then enable the plugin via `Project Settings > Plugins` in the Godot editor.

If you'd like, you can also add the script template for `State` to your project by similarly copying the `script_templates` directory to the root of your Godot project.

## What even does this do?
Out of the box, this plugin is very generic and barebones. It only provides the following:
- The `StateMachine` node, which simply keeps track of the current active `State` node, as well as calls the `State`s' `_enter_state` and `_exit_state` function hooks during state transitions.
- The `State` node, which is a base node to be extended by you. You can attach behaviors for each state via the aforementioned hooks.
  - You can opt in to some built-in `State` behaviors if you call `super()` from your own `_enter_state`, `_exit_state`, and `_ready` hooks and set the correct parameters via the editor:
    - Simple automatic animation playing upon state enter
    - Automatic handling of enabling/disabling physics processing

Your state machine's delta function can be defined by a series of signal connections in your base node's `_ready` function, connecting the `State`'s `state_finished` signal directly to the `StateMachine`'s `change_state` function. See `Sphere.gd` for an example of this. For states with multiple transitions, you can connect it to your own function that conditionally calls `change_state` with a certain `State`.

Since this is so generic, it keeps the state machine flexible. You could interact with the `StateMachine` in different ways:
- Simply query the `StateMachine` for the current state, and maybe query that state for information all from your base node
- Have `State`s actually implement `_process` or `_physics_process` functions with references to your base node, then enable and disable processing upon entering and exiting that state. This is what the example project does.