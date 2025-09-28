extends Area2D


const SPEED = 60

@export var max_health: int = 3
var health: int = 3

var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	# (Optional) ensure in group
	if not is_in_group("Enemy"):
		add_to_group("Enemy")

func take_damage(amount: int) -> void:
	health -= amount
	animated_sprite.play("death")
	if health <= 0:
		die()
func die():
	# play animation / spawn particles
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta
