extends Node2D
class_name EnemyAnimator

# Ссылки на нужные ноды
@onready var animation_player: AnimationPlayer = $".."/EnemyAnimator/AnimationEnemy
@onready var sprite: Sprite2D = $Sprite2D

# Ссылка на CharacterBody2D — чтобы читать velocity и состояние
@onready var enemy_body: CharacterBody2D = get_parent() as CharacterBody2D

# Небольшой порог, чтобы не дёргался на микродвижениях
const MOVEMENT_THRESHOLD: float = 5.0

func _physics_process(_delta):
	if not animation_player or not enemy_body:
		return
	
	var vel = enemy_body.velocity
	var on_floor = enemy_body.is_on_floor()
	
	# Определяем, двигается ли враг по горизонтали
	var is_moving = abs(vel.x) > MOVEMENT_THRESHOLD and on_floor
	
	# === ВЫБОР АНИМАЦИИ ===
	if not on_floor:
		# Если в воздухе — можно добавить "fall" или "jump", но пока просто idle
		animation_player.play("idle")
	else:
		if is_moving:
			animation_player.play("movement")
		else:
			animation_player.play("idle")
