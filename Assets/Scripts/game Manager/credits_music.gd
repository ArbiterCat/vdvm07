extends Node2D

@onready var credits_music: AudioStreamPlayer2D = $Camera2D/AudioStreamPlayer2D

func _ready() -> void:
	# Запускаем музыку автоматически при загрузке сцены
	credits_music.play()
