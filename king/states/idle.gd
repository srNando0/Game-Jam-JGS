extends State

@export var king: King
@export var punch_state: State
@export var idle_timer: Timer
@export var cloth: Polygon2D


func enter() -> void:
	cloth.color = Color(1.0, 1.0, 1.0)
	idle_timer.wait_time = king.rng.randf_range(0.4, 0.8)
	idle_timer.start()


func physics_process(_delta: float) -> void:
	var distance: float = king.player.position.x - king.position.x
	
	if distance < 0.0:
		king.images.scale.x = -1.0
	if distance > 0.0:
		king.images.scale.x = 1.0


func _on_idle_timer_timeout() -> void:
	change_state(punch_state)
