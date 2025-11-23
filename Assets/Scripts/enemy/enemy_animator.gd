extends Node2D
class_name EnemyAnimator

@onready var animation_player: AnimationPlayer = $".."/EnemyAnimator/AnimationEnemy
@onready var sprite: Sprite2D = $Sprite2D

@onready var enemy_body: CharacterBody2D = get_parent() as CharacterBody2D

const MOVEMENT_THRESHOLD: float = 5.0

var is_dead: bool = false
var is_hit: bool = false
var flash_played: bool = false  # ←← ФЛЕШ ТОЛЬКО ОДИН РАЗ!

func _physics_process(_delta):
	if not animation_player or not enemy_body:
		return
	
	# === ПРИОРИТЕТ 1: СМЕРТЬ — ЗАМРАЗКА ВСЕГО ===
	if is_dead:
		animation_player.play("die")
		return
	
	# === ПРИОРИТЕТ 2: FLASH HIT — ТОЛЬКО 1 РАЗ ===
	if is_hit and not flash_played:
		animation_player.play("flash")
		flash_played = true  # ← БЛОКИРУЕМ ПОВТОРЫ!
		return
	
	# === ОБЫЧНЫЕ АНИМАЦИИ ===
	var vel = enemy_body.velocity
	var on_floor = enemy_body.is_on_floor()
	
	var is_moving = abs(vel.x) > MOVEMENT_THRESHOLD and on_floor
	
	if not on_floor:
		animation_player.play("idle")
	else:
		if is_moving:
			animation_player.play("movement")
		else:
			animation_player.play("idle")

# ←←← play_hit() — сбрасывает flash_played после анимации
func play_hit():
	is_hit = true
	flash_played = false  # ← разрешаем играть flash заново

# ←←← play_death() — без изменений
func play_death():
	is_dead = true
	animation_player.play("die")
	
	if not animation_player.is_connected("animation_finished", _on_death_finished):
		animation_player.animation_finished.connect(_on_death_finished)

# ←←← УДАЛЕНИЕ ПОСЛЕ АНИМАЦИИ СМЕРТИ
func _on_death_finished(anim_name: String):
	if anim_name == "die":
		enemy_body.queue_free()
		animation_player.animation_finished.disconnect(_on_death_finished)
