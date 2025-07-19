extends Node2D

# Camera2D properties
@export var left: int = -10000000:
	set(value):
		left = value
		($Camera2D as Camera2D).limit_left = left
@export var top: int = -10000000:
	set(value):
		top = value
		($Camera2D as Camera2D).limit_top = top
@export var right: int = 10000000:
	set(value):
		right = value
		($Camera2D as Camera2D).limit_right = right
@export var bottom: int = 10000000:
	set(value):
		bottom = value
		($Camera2D as Camera2D).limit_bottom = bottom

# SmoothCamera properties
@export var margin: float = 40.0
@export var speed: float = 1.0

@onready var target_position: Vector2 = get_parent_position()
@onready var camera_position: Vector2 = get_parent_position()
var target_velocity: Vector2 = Vector2.ZERO
var camera_velocity: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	update_camera(delta)
	limit_position()


func update_camera(delta: float) -> void:
	# Old values
	var y: Vector2 = target_position - camera_position
	var dy: Vector2 = target_velocity - camera_velocity
	
	var c_0: Vector2 = y
	var c_1: Vector2 = speed * y + dy
	
	var p_0: Vector2 = c_0 + c_1 * delta
	var p_1: Vector2 = c_1
	
	y = exp(-speed * delta) * p_0
	dy = exp(-speed * delta) * (p_1 - speed * p_0)
	
	# New values
	camera_position = (target_position + target_velocity * delta) - y
	camera_velocity = target_velocity - dy
	
	target_velocity = (get_parent_position() - target_position) / delta
	target_position = get_parent_position()


func limit_position() -> void:
	var compressed_position: Vector2 = camera_position
	var half_sizes: Vector2 = 0.5 * get_viewport().get_visible_rect().size
	
	var soft_limit: Vector2
	var hard_limit: Vector2
	
	# Right and bottom
	hard_limit = Vector2(right, bottom) - half_sizes
	soft_limit = hard_limit - margin * Vector2.ONE
	compressed_position = compress_space(
			compressed_position,
			soft_limit,
			hard_limit,
	)
	
	# Left and top
	hard_limit = Vector2(left, top) + half_sizes
	soft_limit = hard_limit + margin * Vector2.ONE
	compressed_position = -compress_space(
			-compressed_position,
			-soft_limit,
			-hard_limit,
	)
	
	position = compressed_position - get_parent_position()


func compress_space(v: Vector2, soft_limit: Vector2, hard_limit: Vector2) -> Vector2:
	var delta: Vector2 = hard_limit - soft_limit
	
	var x: float = v.x
	var y: float = v.y
	
	if x > soft_limit.x:
		x = soft_limit.x + delta.x * (1.0 - exp((soft_limit.x - x) / delta.x))

	if y > soft_limit.y:
		y = soft_limit.y + delta.y * (1.0 - exp((soft_limit.y - y) / delta.y))
	
	return Vector2(x, y)


func get_parent_position() -> Vector2:
	var target: Node2D = get_parent()
	if target:
		return target.position
	else:
		return target_position
