extends CharacterBody2D

@export var speed: float = 400
@export var gravity: float = 2000
@export var jump_height: float = 160
@export var max_fall_speed: float = 800

var motion: Vector2 = Vector2.ZERO

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func rot_right(v: Vector2) -> Vector2:
	return Vector2(-v.y, v.x)


func _physics_process(delta: float) -> void:
	# Horizontal movement
	motion.x = speed * Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		start_jump(jump_height)
		$Audios/Jump.play_random(rng, 0.1)
	if Input.is_action_just_released("jump"):
		stop_jump()
	
	compute_velocity(delta)
	move_and_slide()
	
	var line: Line2D = $Line2D
	if is_on_floor():
		line.default_color = Color(1.0, 1.0, 0.0)
	else:
		line.default_color = Color(0.0, 0.0, 1.0)


func start_jump(height: float) -> void:
	# v^2 = v_0^2 + 2aDs
	motion.y = sqrt(2.0 * gravity * height)


func stop_jump() -> void:
	if not is_on_floor() and motion.y > 0.0:
		motion.y = 0.0


func compute_velocity(delta: float) -> void:
	# Construct displacement vector
	var displacement: Vector2 = Vector2.ZERO
	# Horizontal component
	displacement += motion.x * delta * rot_right(up_direction)
	# Vertical component
	if is_on_floor():
		if motion.y < 0.0:
			$Audios/Fall.volume_linear = -motion.y/2000
			$Audios/Fall.play_random(rng, 0.1)
		motion.y = max(0.0, motion.y)
		displacement += motion.y * delta * up_direction
	else:
		displacement += max(
				# s = s_0 + v_0 Dt
				-max_fall_speed,
				# s = s_0 + v_0 Dt + (a/2)Dt^2
				motion.y - 0.5 * gravity * delta,
		) * delta * up_direction
		
		# Limit fall speed
		# v = v_0 + a Dt
		motion.y = max(motion.y - gravity * delta, -max_fall_speed)
	
	velocity = displacement/delta
