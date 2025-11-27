extends CharacterBody2D
class_name Enemy

@export var speed: float = 80.0
@export var gravity: float = 980.0
@export var max_hp: int = 3  # ← 3 HP
@onready var player: CharacterBody2D = null  # будем хранить ссылку на игрока

@onready var left_ray: RayCast2D = $GroundCheck/RightRayCast
@onready var right_ray: RayCast2D = $GroundCheck/RightRayCast
@onready var sprite: Sprite2D = $EnemyAnimator/Sprite2D        
@onready var weapon: Sprite2D = $EnemyAnimator/weapon_rifle/Sprite2D
@onready var weapon_node: Node2D = $EnemyAnimator/weapon_rifle
@onready var HurtBox: Area2D = $HurtBox

@onready var player_check: Node2D = $PlayerCheck
@onready var front_ray: RayCast2D = $PlayerCheck/Front
@onready var upper_front_ray: RayCast2D = $PlayerCheck/UpperFront
@onready var back_ray: RayCast2D = $PlayerCheck/Back
@onready var upper_back_ray: RayCast2D = $PlayerCheck/UpperBack
@onready var wall_check_ray: RayCast2D = $PlayerCheck/WallCheck/FrontCheck

var current_hp: int = 3      # ← текущее HP
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
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	# ←←← ПОВОРАЧИВАЕМ ВСЮ ГРУППУ ЛУЧЕЙ ПО НАПРАВЛЕНИЮ!
	player_check.scale.x = -direction   # ← ВОТ ЭТО ВСЁ!
	look_at_player_if_seen() 
	# ←←← ПОВОРОТ СПРАЙТА И ОРУЖИЯ (как было, но чище)
	if sprite:
		sprite.flip_h = direction > 0

	if weapon_node:
		weapon_node.position.x = 4 * direction   # -4 или +4
		weapon.flip_h = direction > 0

	if wall_check_ray.is_colliding():
		direction *= -1  # мгновенный разворот при виде стены
		state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
	
	# ПРОВЕРКА КРАЯ ПЛАТФОРМЫ (как было)
	elif direction > 0 and not right_ray.is_colliding():
		direction = -1
		state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
	elif direction < 0 and not left_ray.is_colliding():
		direction = 1
		state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)

	# ←←← ДВИЖЕНИЕ
	if current_state == "walking":
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2)

	move_and_slide()

func look_at_player_if_seen():
	# Проверяем, видит ли хотя бы один луч игрока
	var sees_player = (
		front_ray.is_colliding() or 
		upper_front_ray.is_colliding() or 
		back_ray.is_colliding() or 
		upper_back_ray.is_colliding()
	)
	
	if sees_player:
		# Находим игрока (один раз)
		if player == null:
			var collider = front_ray.get_collider() or upper_front_ray.get_collider() or back_ray.get_collider() or upper_back_ray.get_collider()
			if collider and collider is PlayerController:
				player = collider
		
		# Поворачиваем оружие НА ИГРОКА
		if player != null:
			var direction_to_player = (player.global_position - weapon_node.global_position).normalized()
			# Поворачиваем ноду оружия (лучше, чем sprite.look_at)
			weapon_node.look_at(player.global_position)
			
			# Исправляем поворот вверх/вниз (чтобы не переворачивалось)
			if direction_to_player.x < 0:
				weapon_node.scale.y = -1  # переворачиваем вверх ногами, если слева
			else:
				weapon_node.scale.y = 1
			
			return true  # видит
	else:
		# Игрок пропал из виду — возвращаем оружие в исходное положение
		player = null
		weapon_node.rotation = 0
		weapon_node.scale.y = 1
		return false
		
func can_see_player() -> bool:
	return front_ray.is_colliding() or upper_front_ray.is_colliding()

func start_walking():
	current_state = "walking"
	direction = [-1.0, 1.0].pick_random()
	state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)

func start_idling():
	current_state = "idling"
	state_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
