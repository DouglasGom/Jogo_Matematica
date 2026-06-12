extends Node2D

@onready var player := $player as CharacterBody2D
@onready var player_scene = preload("res://actors/player.tscn")
@onready var camera := $camera as Camera2D
@onready var control: Control = $HUD/control as Control

func _ready() -> void:
	Globals.player = player
	Globals.player.follow_camera(camera)
	Globals.player.player_has_died.connect(reload_game)
	control.time_is_up.connect(game_over)
	
	# Se o jogador já passou por um checkpoint antes do reload
	if Globals.current_checkpoint_pos != null:
		Globals.respawn_player()
	else:
		# Se é a PRIMEIRA vez entrando na fase, aí sim começamos do zero absoluto
		Globals.coins = 0
		Globals.score = 0
		Globals.player_life = 3

func reload_game():
	await get_tree().create_timer(1.0).timeout
	
	# Subtrai 1 vida (caso você não esteja fazendo isso no script do player)
	Globals.player_life -= 1
	
	# Checa se as vidas acabaram
	if Globals.player_life <= 0:
		game_over()
	else:
		get_tree().reload_current_scene() 

func game_over():
	get_tree().change_scene_to_file("res://extras/game_over.tscn")
