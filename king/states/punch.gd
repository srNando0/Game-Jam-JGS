extends State

@export var king: King
@export var idle_state: State
@export var hold_timer: Timer
@export var dash_timer: Timer
@export var cloth: Polygon2D

@export var dash_extra_length: float = 100.0

var dashing: bool = false
var dash_length: float = 0.0
var distance: Vector2 = Vector2.ZERO


func enter() -> void:
	dashing = false
	cloth.color = Color(1.0, 1.0, 0.0)
	hold_timer.start()


func physics_process(delta: float) -> void:
	if dashing:
		compute_velocity_on_dash(delta)
		king.move_and_slide()
	else:
		distance = king.player.position - king.position


func _on_hold_timer_timeout() -> void:
	dashing = true
	
	if distance.x < 0.0:
		king.images.scale.x = -1.0
	if distance.x > 0.0:
		king.images.scale.x = 1.0
	
	distance.y = 0.0
	distance.x += dash_extra_length * king.images.scale.x
	
	cloth.color = Color(1.0, 0.0, 0.0)
	dash_timer.start()


func _on_dash_timer_timeout() -> void:
	change_state(idle_state)


func compute_velocity_on_dash(delta: float) -> void:
	var t_0: float = dash_timer.wait_time - dash_timer.time_left
	var t: float = t_0 + delta
	var s_0: float = distance.length() * dash_function(t_0 / dash_timer.wait_time)
	var s: float = distance.length() * dash_function(t / dash_timer.wait_time)
	var v: float = (s - s_0)/delta
	
	king.velocity = v * distance.normalized()


func dash_function(x: float, order: float = 3.0) -> float:
	var f: float = 1.0 - pow(1.0 - x, order)
	return clamp(f, 0.0, 1.0)
