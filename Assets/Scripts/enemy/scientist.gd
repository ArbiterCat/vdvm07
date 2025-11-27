extends CharacterBody2D
class_name Scientist

@export var max_hp: int = 3
@onready var hurtbox: Area2D = $HurtBox

var current_hp: int = 3   

func _ready():
	current_hp = max_hp

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var potential_player = area.get_parent().get_parent()
	if potential_player and potential_player is PlayerController:
		take_damage(1)
		print("Враг получил урон от игрока!")

func take_damage(amount: int = 1):
	current_hp -= amount
	print("Враг получил урон! HP: ", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Враг мёртв!")
	# ←←← ЗАПУСК СЦЕНЫ С ТИТРАМИ
	get_tree().change_scene_to_packed(load("res://Assets/Scenes/User Interface/credits.tscn"))
	# Или если у тебя PackedScene:
	# get_tree().change_scene_to_packed(load("res://Scenes/Credits.tscn"))
