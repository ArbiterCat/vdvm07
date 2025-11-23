extends CharacterBody2D
class_name Enemy

@export var speed: float = 80.0
@export var gravity: float = 980.0

@onready var left_ray: RayCast2D = $LeftRayCast
@onready var right_ray: RayCast2D = $RightRayCast
@onready var sprite: Sprite2D = $EnemyAnimator/Sprite2D        
@onready var weapon: Sprite2D = $EnemyAnimator/weapon_rifle/Sprite2D
@onready var weapon_node: Node2D = $EnemyAnimator/weapon_rifle

# ... твои переменные для рандома ...
var direction: float = 1.0
var state_timer: float = 0.0
var current_state: String = "walking"
const MIN_WALK_TIME: float = 1.0
const MAX_WALK_TIME: float = 4.0
const MIN_IDLE_TIME: float = 1.5
const MAX_IDLE_TIME: float = 2.5

# Твой _physics_process остаётся ТАКИМ ЖЕ (ничего не меняем!)
func _physics_process(delta: float):
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

# Твои функции состояний остаются без изменений
func start_walking():
	current_state = "walking"
	direction = [-1.0, 1.0].pick_random()
	state_timer = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)

func start_idling():
	current_state = "idling"
	state_timer = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
