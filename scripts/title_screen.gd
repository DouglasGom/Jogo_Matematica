extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 3
	
	# ADICIONE ESTA LINHA: Isso apaga a memória do checkpoint
	Globals.current_checkpoint_pos = null


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world_01.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://extras/credits.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
