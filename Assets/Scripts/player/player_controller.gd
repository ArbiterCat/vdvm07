extends CharacterBody2D
class_name PlayerController

@export var speed: float = 6.5
@export var jump_power: float = 10.0

var speed_multiplier: float = 30.0
var jump_multiplier: float = -30.0
var move_direction: float = 0.0

var max_jumps: int = 10
var jumps_made: int = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var attack_timer: float = 0.0          
var attack_cooldown: float = 0.0       
var attack_duration: float = 0.3       
var attack_cooldown_duration: float = 0.3 

@onready var sprite: Sprite2D = $PlayerAnimator/Sprite2D 
@onready var sword: Node2D = $PlayerAnimator/Sword     
@onready var sword_sprite: Sprite2D = $PlayerAnimator/Sword/SwordSprite
@onready var Hitbox: Area2D = $PlayerAnimator/Sword/Hitbox
@onready var HitboxShape: CollisionShape2D = $PlayerAnimator/Sword/Hitbox/HitboxShape
@onready var sword_anim: Sprite2D = $PlayerAnimator/Sword/KatanaAnimator/KatanaAnim
@onready var RightRayCast: RayCast2D = $RightRayCast2D
@onready var LeftRayCast: RayCast2D = $LeftRayCast2D

func _input(event):
	# Только включаем/выключаем лучи и маску по действиям
	if event.is_action_pressed("attack") and attack_cooldown <= 0:
		HitboxShape.disabled = false
		attack_timer = attack_duration
		attack_cooldown = attack_cooldown_duration

	if event.is_action_pressed("jump"):
		RightRayCast.enabled = true
		LeftRayCast.enabled = true
		# НЕ включаем маску здесь — она включится сама в _physics_process

		if is_on_floor():
			jumps_made = 1
			velocity.y = jump_power * jump_multiplier
		elif jumps_made < max_jumps:
			jumps_made += 1
			velocity.y = jump_power * jump_multiplier
	
	if event.is_action_pressed("move_down"):
		RightRayCast.enabled = false
		LeftRayCast.enabled = false
		set_collision_mask_value(10, false)
	if event.is_action_released("move_down"):
		RightRayCast.enabled = true
		LeftRayCast.enabled = true


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		jumps_made = 0

	move_direction = Input.get_axis("move_left", "move_right")
	if move_direction != 0:
		velocity.x = move_direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	if sprite:
		sprite.flip_h = get_global_mouse_position().x < global_position.x

	if sword:
		var target_pos = get_global_mouse_position()
		sword.look_at(target_pos)
	
	if position > get_global_mouse_position():
		sword_sprite.flip_v = true
		sword_sprite.offset = Vector2(0,-15)
		sword_anim.flip_v = true
		sword_anim.offset = Vector2(0,-5)
	else:
		sword_sprite.flip_v = false
		sword_sprite.offset = Vector2.ZERO 
		sword_anim.flip_v = false
		sword_anim.offset = Vector2.ZERO

	# Таймер хитбокса
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			HitboxShape.disabled = true

	# Кулдаун атаки
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if RightRayCast.is_colliding() or LeftRayCast.is_colliding():
		set_collision_mask_value(10, true)
		# Лучи уже включены — не трогаем
	else:
		if not Input.is_action_pressed("move_down"):  # если не зажат "вниз"
			set_collision_mask_value(10, false)

	move_and_slide()
