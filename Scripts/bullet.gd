extends Area2D

@export var speed: float = 520.0
@export var lifetime: float = 1.8
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT   # Player sets this

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()
