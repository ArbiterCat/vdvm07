extends Node2D

@onready var background_music: AudioStreamPlayer2D = $Player/BackgroundMusic

func _ready() -> void:
	# Подписываемся на сигнал "закончилась музыка"
	background_music.finished.connect(_on_music_finished)
	
	# Запускаем (если Autoplay выключен)
	if not background_music.playing:
		background_music.play()

# Эта функция вызывается автоматически, когда трек доиграл до конца
func _on_music_finished() -> void:
	background_music.play()  # ← просто запускаем заново = бесконечный луп


func _on_background_music_finished() -> void:
	pass # Replace with function body.
