# Godot State Machine
A simple state machine plugin for Godot with a visual editor. This plugin allows for:
- Visual building and understanding of transitions in your state machines
- Fast and organized prototyping of scene behaviors

Originally based on [Heartbeast's Finite State Machine](https://www.youtube.com/watch?v=qwOM3v8T33Q) ([GitHub](https://github.com/uheartbeast/FSM-Tutorial))

![state_machine_demo](https://github.com/greenerino/godot-state-machine/assets/30224113/4457920f-d5d8-4181-b865-aeb553188b29)

## Installation
Copy the `addons/state_machine` directory into the `addons` directory at the root of your Godot project, then enable the plugin via `Project Settings > Plugins` in the Godot editor.

If you'd like, you can also add the script template for `State` to your project by similarly copying the `script_templates` directory to the root of your Godot project.

## Getting Started
Take a look at the example project to get a general idea of the usage of this plugin. It contains a simple combat system and uses the State Machine to organize the behaviors of the player and the enemy.

Use WASD/Left Analog to move and Left Click/RB to attack.

Credit to [Kay Lousberg](https://kaylousberg.itch.io/kaykit-skeletons) for the skeleton and weapon assets in the example project!

![godot-state-machine-example](https://github.com/greenerino/godot-state-machine/assets/30224113/fbe94e80-2163-4f4d-b979-2c1c4c3fe645)

### Overview

<img align="right" src="https://github.com/greenerino/godot-state-machine/assets/30224113/58f98f2b-2dd8-4883-a02d-5b3059efdc44">

You will find two entities in the example project: `Player` and `Skeleton Warrior`. They each have their own `StateMachine` scene, each of which has its own `State` scenes.

On `Skeleton Warrior`, the `SearchState` is the initial state, as configured in the node settings. The warrior will cycle between `SearchState` and `ChaseState` depending on how close the player gets. However, if the warrior gets hit with an attack, the `HitState` will be activated. This is a unique case in the example because we have a manual connection to that state in `skeleton_warrior.gd`, making it a "spontaneous transition."

After `HitState`, we conditionally change states via the different signals. If there is health remaining, the state machine eventually travels back to the `SearchState`. Otherwise, we enter the `DeathState` and free the node.

![image](https://github.com/greenerino/godot-state-machine/assets/30224113/2f9c3bdd-e432-40ab-9eb1-e71ad1e7687e)

#### `StateMachine`
The `StateMachine` simply keeps track of the current active state and handles the transitions between those states. It keeps track of the transitions set by the visual editor (the "delta function"), and sets up the signal connections between the states.

#### `State`
The `State` scenes are usually extended scenes and contain your custom behavior. They have `_enter_state` and `_exit_state` callback functions which are overriden by you and called by the `StateMachine` upon transition. 

`State`s can also emit signals that can be automatically routed to other states by the `StateMachine`. Each `State` by default has a `state_finished` signal.

The base `State` node has built-in common applications that you can opt into by enabling them in the editor and calling `super()` in the callback functions and `_ready()`. These include:
- Enabling physics processing - common when a state has to directly take responsibility of your scene's `_physics_process()` function only when it is the current state
- Animation handling - allows you to automatically play an animation, travel to an animation tree state, and/or end a state when an animation finishes

### The Visual Editor
Clicking on a `StateMachine` node in the scene tree will focus your main editor window on the State Machine Editor, displaying all the `State` children and transitions for that `StateMachine`.

Each signal a `State` has can be hooked up (from the right side) to the input (left side) of another state by clicking and dragging between the endpoints. Click and drag again to remove a connection.

![godot-state-machine-connection](https://github.com/greenerino/godot-state-machine/assets/30224113/73662326-17c0-46ca-9294-b19d567b361b)

A signal must either pass no arguments, or a single `Dictionary` argument. The `Dictionary` can contain any arbitrary data to send to the receiving `State`. 

Under the hood, the editor just records which states should be activated by which signals. If you need to activate a state from outside the state machine, or if you just don't want to use the editor, you can simply set up your transitions manually:
```GDScript
class_name Player

@onready var sm: StateMachine = %StateMachine
@onready var s1: State = StateOne
@onready var s2: State = StateTwo

func _ready() -> void:
  s1.state_finished.connect(sm.change_state.bind(s2))

  # Or if s1 has a signal that passes a Dictionary...
  s1.damaged.connect(sm.change_state_with_data.bind(s2))
```
