class_name StateMachine extends Node

@export var state: State


func _ready() -> void:
	# Initial state
	state.enter()


func process(delta: float) -> void:
	state.process(delta)


func physics_process(delta: float) -> void:
	state.physics_process(delta)


func handle_input(event: InputEvent) -> void:
	state.handle_input(event)
