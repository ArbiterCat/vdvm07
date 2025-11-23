extends Node2D

@export var player_controller: PlayerController
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D

# Если что-то не подключено в инспекторе — попробуем найти автоматически
@onready var _player: PlayerController = player_controller if player_controller else get_parent() as PlayerController
@onready var _anim: AnimationPlayer = animation_player if animation_player else $AnimationPlayer
@onready var _sprite: Sprite2D = sprite if sprite else $Sprite2D
@onready var _animAttack: AnimationPlayer = $Sword/KatanaAnimator/AnimationKatana
@onready var _sprite_attack: Sprite2D = $Sword/KatanaAnimator/KatanaAnim
@onready var _sprite_sword: Sprite2D = $Sword/SwordSprite

func _ready():
	_sprite_attack.visible = false
	_sprite_sword.visible = true


func _input(event):
	if event.is_action_pressed("attack"):
		
		_animAttack.play("attack")
		
		_sprite_attack.visible = true
		_sprite_sword.visible = false
		
		if not _animAttack.is_connected("animation_finished", _on_attack_finished):
			_animAttack.animation_finished.connect(_on_attack_finished)

func _on_attack_finished(anim_name: String):
	if anim_name == "attack":
		_sprite_attack.visible = false
		_sprite_sword.visible = true

func _process(_delta):
	if !_player or !_anim or !_sprite:
		return

	var vel = _player.velocity
	var on_floor = _player.is_on_floor()
	var jumps = _player.jumps_made   # ← вот это теперь всегда правильно!

	_sprite.flip_h = get_global_mouse_position().x < _player.global_position.x

	if not on_floor:
		# Сначала проверяем двойной прыжок (самое специфичное условие)
		if jumps >= 1 and vel.y < 0:  # Двойной прыжок только когда движемся вверх
			_anim.play("double_jump")
		# Затем проверяем обычный прыжок (движение вверх)
		elif vel.y < 0:  # Используем порог для надежности
			_anim.play("jump")
		# Все остальное - падение
		else:
			_anim.play("fall")
	else:
		# На земле
		if abs(vel.x) > 1:  # Более мягкое условие для движения
			_anim.play("move")
		else:
			_anim.play("idle")
