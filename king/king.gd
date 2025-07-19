class_name King extends CharacterBody2D

@export var player: Player

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var moveset: StateMachine = $Moveset
@onready var images: Node2D = $Images


func _init() -> void:
	rng.randomize()


func _physics_process(delta: float) -> void:
	moveset.physics_process(delta)
