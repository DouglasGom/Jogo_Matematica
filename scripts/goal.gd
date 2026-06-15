extends Area2D

@onready var transition: CanvasLayer = $"../transition"
@export var next_level : String = ""


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and !next_level == "":
		
		# NOVO: Limpa o checkpoint da fase anterior!
		Globals.current_checkpoint_pos = null
		
		# Muda para a próxima fase
		transition.change_scene(next_level)
