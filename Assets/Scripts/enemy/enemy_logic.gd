extends CharacterBody2D
class_name Enemy

@export var speed: float = 80.0
@export var gravity: float = 980.0
@export var max_hp: int = 3  # ← 3 HP

var current_hp: int = 3      # ← текущее HP
@onready var left_ray: RayCast2D = $LeftRayCast
@onready var right_ray: RayCast2D = $RightRayCast
@onready var sprite: Sprite2D = $EnemyAnimator/Sprite2D        
@onready var weapon: Sprite2D = $EnemyAnimator/weapon_rifle/Sprite2D
@onready var weapon_node: Node2D = $EnemyAnimator/weapon_rifle
@onready var HurtBox: Area2D = $HurtBox

var direction: float = 1.0
var state_timer: float = 0.0
var current_state: String = "walking"
const MIN_WALK_TIME: float = 1.0
const MAX_WALK_TIME: float = 4.0
const MIN_IDLE_TIME: float = 1.5
const MAX_IDLE_TIME: float = 2.5

func _ready():
	current_hp = max_hp  # ← инициализация HP

# ←←← ОБРАБОТКА УРОНА ОТ ХИТБОКСА ИГРОКА (главное!)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Универсальная проверка: ищем метод take_damage у родителя area
	var potential_player = area.get_parent().get_parent()
	if potential_player and potential_player is PlayerController:
		take_damage(1)
		print("Враг получил урон от игрока!")

# ←←← В take_damage() добавь вызов аниматора
func take_damage(amount: int = 1):
	current_hp -= amount
	print("Враг получил урон! HP: ", current_hp)
	
	# ←←← АНИМАЦИЯ FLASH ПРИ УРОНЕ!
	$EnemyAnimator.play_hit()  # вызов аниматора
	
	if current_hp <= 0:
		die()
	else:
		velocity.x = -direction * 250
		state_timer = 0.4

# ←←← die() теперь только флаг — удаление делает аниматор
func die():
	print("Враг мёртв!")
	$EnemyAnimator.play_death()  # запускаем анимацию смерти

# Твой _physics_process без изменений
func _physics_process(delta: float):
	if $EnemyAnimator.is_dead:
		velocity = Vector2.ZERO  # мгновенная остановка
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	state_timer -= delta
	if state_timer <= 0.0:
		if current_state == "walking":
			start_idling()
		else:
			start_walking()

	if is_on_floor():
		if direction > 0 and not right_ray.is_colliding():
			direction = -1
			state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
		elif direction < 0 and not left_ray.is_colliding():
			direction = 1
			state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)

	if current_state == "walking":
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2)

	if sprite:
		sprite.flip_h = (direction > 0)

	if weapon and weapon_node:
		if direction == -1:
			weapon.flip_h = false
			weapon_node.position.x = -4
		else:
			weapon.flip_h = true
			weapon_node.position.x = 4

	move_and_slide()

func start_walking():
	current_state = "walking"
	direction = [-1.0, 1.0].pick_random()
	state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)

func start_idling():
	current_state = "idling"
	state_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
