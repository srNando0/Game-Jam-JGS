extends CharacterBody2D

@export var speed: float = 400.0
@export var gravity: float = 2000.0
@export var jump_height: float = 160.0
@export var max_fall_speed: float = 800.0
@export var dash_length: float = 400.0
@export var dash_time: float = 1.0/3.0
@export var dash_time_window: float = 1.0/12.0

var motion: Vector2 = Vector2.ZERO
var jump_pass: bool = true
var prev_on_floor: bool = is_on_floor()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func rot_right(v: Vector2) -> Vector2:
	return Vector2(-v.y, v.x)


func _physics_process(delta: float) -> void:
	move_platform_mode(delta)
	
	var line: Line2D = $Line2D
	if is_on_floor():
		line.default_color = Color(1.0, 1.0, 0.0)
	else:
		line.default_color = Color(0.0, 0.0, 1.0)


func move_platform_mode(delta: float) -> void:
	# Before motion
	play_floor()
	
	# Motion on floor
	motion.x = speed * Input.get_axis("left", "right")
	
	# Jump
	if Input.is_action_pressed("jump") and is_on_floor() and jump_pass:
		start_jump(jump_height)
		var sound_effect: SoundEffect2D = $Audios/Jump
		sound_effect.play_random(rng, 0.1)
	# Cancel jump
	if Input.is_action_just_released("jump"):
		stop_jump()
	
	# Move
	compute_velocity_on_fall(delta)
	move_and_slide()


func move_dash_mode(delta: float) -> void:
	pass


func start_jump(height: float) -> void:
	# v^2 = v_0^2 + 2aDs
	motion.y = sqrt(2.0 * gravity * height)
	jump_pass = false


func stop_jump() -> void:
	if not is_on_floor() and motion.y > 0.0:
		motion.y = 0.0


func compute_velocity_on_fall(delta: float) -> void:
	# Construct displacement vector
	var displacement: Vector2 = Vector2.ZERO
	# Horizontal component
	displacement += motion.x * delta * rot_right(up_direction)
	# Vertical component
	if is_on_floor():
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


func play_floor() -> void:
	if is_on_floor() and not prev_on_floor:
		var sound_effect: SoundEffect2D = $Audios/Fall
		sound_effect.volume_linear = -motion.y/2000.0
		sound_effect.play_random(rng, 0.1)
	prev_on_floor = is_on_floor()
