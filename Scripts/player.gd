extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle

# --------------- MOVEMENT ----------------
const SPEED: float = 130.0
const JUMP_VELOCITY: float = -300.0

# --------------- DOUBLE JUMP -------------
const EXTRA_JUMPS: int = 1
var air_jumps_left: int = EXTRA_JUMPS

# --------------- DASH --------------------
const DASH_SPEED: float = 600.0
const DASH_TIME: float = 0.18
const DASH_COOLDOWN: float = 0.5
const DASH_CANCELS_VERTICAL: bool = true
const DASH_KEEP_MOMENTUM: bool = true

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_dir: int = 0  # -1 left, 1 right

# --------------- SHOOTING ----------------
@export var fire_cooldown: float = 0.25        # seconds between shots
@export var bullet_scene: PackedScene = preload("res://The_Repository/Scenes/bullet.tscn")
var _fire_timer: float = 0.0

# --------------- MAIN LOOP ---------------
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause and Exit"):
		get_tree().change_scene_to_file("res://The_Repository/Scenes/main_menu.tscn")

	update_dash_timers(delta)
	update_fire_timer(delta)

	# Shooting input
	if Input.is_action_pressed("shoot"):
		try_shoot()

	# Dash input
	if Input.is_action_just_pressed("dash"):
		try_start_dash()

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	handle_jump_input()

	if is_dashing:
		perform_dash_motion()
	else:
		handle_horizontal_movement(delta)

	move_and_slide()
	post_move_updates()

# --------------- JUMP LOGIC --------------
func handle_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			perform_jump(true)
		elif air_jumps_left > 0:
			perform_jump(false)
			air_jumps_left -= 1

func perform_jump(reset_air_jumps: bool) -> void:
	velocity.y = JUMP_VELOCITY
	if reset_air_jumps:
		air_jumps_left = EXTRA_JUMPS

# --------------- HORIZONTAL MOVEMENT -----
func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# (Optional) Mirror muzzle x if you want it to always be at gun tip:
	# if animated_sprite.flip_h:
	# 	muzzle.position.x = -abs(muzzle.position.x)
	# else:
	# 	muzzle.position.x = abs(muzzle.position.x)

	# Apply velocity
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

# --------------- DASH --------------------
func try_start_dash() -> void:
	if is_dashing or dash_cooldown_timer > 0.0:
		return

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		if animated_sprite.flip_h:
			dash_dir = -1
		else:
			dash_dir = 1
	else:
		dash_dir = sign(input_dir)

	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN

	if DASH_CANCELS_VERTICAL:
		velocity.y = 0.0
	velocity.x = dash_dir * DASH_SPEED

func perform_dash_motion() -> void:
	animated_sprite.play("roll")
	velocity.x = dash_dir * DASH_SPEED

func end_dash() -> void:
	is_dashing = false
	if not DASH_KEEP_MOMENTUM:
		velocity.x = 0.0

func update_dash_timers(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			end_dash()

# --------------- SHOOTING ----------------
func update_fire_timer(delta: float) -> void:
	if _fire_timer > 0.0:
		_fire_timer -= delta

func try_shoot() -> void:
	if _fire_timer > 0.0:
		return
	shoot()
	_fire_timer = fire_cooldown

func shoot() -> void:
	if bullet_scene == null:
		push_warning("No bullet_scene set on player.")
		return

	var bullet: Area2D = bullet_scene.instantiate()

	# Determine direction from facing
	var dir: Vector2 = Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT

	# Require bullet.gd to have 'var direction'
	# (Alternatively use bullet.set_direction(dir) if you add that method.)
	bullet.direction = dir

	# Spawn at muzzle
	bullet.global_position = muzzle.global_position
	bullet.rotation = dir.angle()

	get_tree().current_scene.add_child(bullet)

# --------------- AFTER MOVE --------------
func post_move_updates() -> void:
	if is_on_floor() and not is_dashing:
		air_jumps_left = EXTRA_JUMPS
	if is_dashing:
		animated_sprite.play("run")  # or a dedicated dash anim

func _input(event: InputEvent) -> void:
	pass
