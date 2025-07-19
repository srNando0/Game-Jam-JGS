class_name State extends Node

@onready var state_machine: StateMachine = get_parent()


func enter() -> void:
	pass


func exit() -> void:
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func change_state(state: State) -> void:
	exit()
	state_machine.state = state
	state.enter()
