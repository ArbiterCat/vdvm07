extends Node2D

func _ready() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	# Правильно: сначала загружаем сцену через load() или preload(), потом передаём в change_scene_to_packed
	get_tree().change_scene_to_packed(load("res://Assets/Scenes/areas/area_1.tscn"))
	
	# Или можно использовать preload (сцена загрузится на этапе компиляции — чуть быстрее):
	# get_tree().change_scene_to_packed(preload("res://Assets/Scenes/areas/area_1.tscn"))
