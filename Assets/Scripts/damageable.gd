extends Node
class_name Damageable

@export var max_health: float = 3.0
@onready var health: float = max_health

signal died()          # ← сигнал на смерть (очень полезно!)
signal health_changed(new_health: float)

func hit(damage: int):
	health -= damage
	health = max(health, 0)
	
	health_changed.emit(health)
	
	print("[Damageable] ", get_parent().name, " получил ", damage, " урона. HP: ", health)
	
	if health <= 0:
		died.emit()
		get_parent().queue_free()  # или анимация смерти + потом queue_free()
