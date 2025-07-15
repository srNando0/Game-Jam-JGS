extends CharacterBody2D

enum MoveMode {
	Platform,
	Dash,
}

@export_group("Platform mode")
@export var walk_speed: float = 400.0
@export var gravity: float = 2000.0
@export var jump_height: float = 160.0
@export var max_fall_speed: float = 800.0

@export_group("Dash mode")
@export var dash_length: float = 200.0
@export var dash_time_window: float = 0.075

var move_mode: MoveMode = MoveMode.Platform
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Platform mode
var motion: Vector2 = Vector2.ZERO
var jump_action: bool = false
var previously_on_floor: bool = is_on_floor()

# Dash mode
var dash_direction: Vector2:
	set(value):
		if not value.is_zero_approx():
			dash_direction = value.normalized()
var dash_pass: bool = true
var dash_previous_time: float = 0.0


static func rot_right(v: Vector2) -> Vector2:
	return Vector2(-v.y, v.x)


func _ready() -> void:
	# Define initial dash_direction
	var image: Node2D = $Images
	dash_direction = (
			Vector2.LEFT if image.scale.x < 0.0
			else Vector2.RIGHT
	)


func _physics_process(delta: float) -> void:
	define_jump_action()
	define_dash_direction()
	
	# Move
	if move_mode == MoveMode.Platform:
		move_platform_mode(delta)
	elif move_mode == MoveMode.Dash:
		move_dash_mode(delta)
	
	# Image
	define_image_direction()


#========
# Platform Mode
#========
func move_platform_mode(delta: float) -> void:
	# Horizontal motion
	motion.x = walk_speed * Input.get_axis("left", "right")
	
	# Jump
	if is_on_floor():
		dash_pass = true
		
		if jump_action:
			start_jump(jump_height)
			var sfx: SoundEffect2D = $Audios/JumpSFX
			sfx.play_random(rng, 0.1)
	
	# Move
	compute_velocity_on_fall(delta)
	move_and_slide()
	
	play_floor_sfx()
	
	# Dash
	var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
	if (
			Input.is_action_just_pressed("dash")
			and dash_cooldown_timer.is_stopped()
			and dash_pass
	):
		dash_start()


func start_jump(height: float) -> void:
	# v^2 = v_0^2 + 2aDs
	motion.y = sqrt(2.0 * gravity * height)
	jump_action = false


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


func define_jump_action() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_action = true
	if Input.is_action_just_released("jump"):
		jump_action = false
		# Cancel jump
		if move_mode == MoveMode.Platform:
			stop_jump()


#========
# Dash Mode
#========
func move_dash_mode(delta: float) -> void:
	var dash_timer: Timer = $Timers/DashTimer
	
	# Dash chain
	if Input.is_action_just_pressed("dash"):
		if dash_timer.time_left <= dash_time_window and dash_pass:
			dash_start()
		else:
			dash_pass = false
	if Input.is_action_just_released("dash"):
		dash_stop()
	
	# Move
	compute_velocity_on_dash(delta)
	move_and_slide()


func dash_start() -> void:
	move_mode = MoveMode.Dash
	motion = dash_direction
	
	var dash_timer: Timer = $Timers/DashTimer
	var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
	dash_timer.start()
	dash_cooldown_timer.start()
	
	var sfx: SoundEffect2D = $Audios/DashSFX
	sfx.play_random(rng, 0.1)


func dash_stop() -> void:
	motion = Vector2.ZERO


func compute_velocity_on_dash(delta: float) -> void:
	var dash_timer: Timer = $Timers/DashTimer
	
	var t_0: float = dash_timer.wait_time - dash_timer.time_left
	var t: float = t_0 + delta
	var s_0: float = dash_length * dash_function(t_0 / dash_timer.wait_time)
	var s: float = dash_length * dash_function(t / dash_timer.wait_time)
	var v: float = (s - s_0)/delta
	
	velocity = v * motion


func _on_dash_timer_timeout() -> void:
	dash_pass = false
	move_mode = MoveMode.Platform
	motion = Vector2.ZERO


func define_dash_direction() -> void:
	dash_direction = Input.get_vector("left", "right", "up", "down", 0.2)


func dash_function(x: float, order: float = 3.0) -> float:
	var f: float = 1.0 - pow(1.0 - x, order)
	return clamp(f, 0.0, 1.0)



#========
# Image
#========
func define_image_direction() -> void:
	var image: Node2D = $Images
	
	if motion.x > 0.0:
		image.scale.x = 1.0
	if motion.x < 0.0:
		image.scale.x = -1.0


#========
# Sound
#========
func play_floor_sfx() -> void:
	if is_on_floor() and not previously_on_floor:
		var sfx: SoundEffect2D = $Audios/FallSFX
		sfx.volume_linear = -motion.y/1000.0
		sfx.play_random(rng, 0.1)
	previously_on_floor = is_on_floor()
