extends Node2D

@onready var player := $player as CharacterBody2D
@onready var player_scene = preload("res://actors/player.tscn")
@onready var camera := $camera as Camera2D
@onready var control: Control = $HUD/control as Control
@onready var boss = $boss 
@onready var question_screen = $question_screen 

func _ready() -> void:
	Globals.player = player
	Globals.player.follow_camera(camera)
	Globals.player.player_has_died.connect(reload_game)
	control.time_is_up.connect(game_over)
	
	if Globals.current_checkpoint_pos != null:
		Globals.respawn_player()
	else:
		Globals.player_life = 3
		
	if boss != null and question_screen != null:
		boss.question_time_triggered.connect(question_screen.show_question)
		question_screen.question_answered.connect(boss._on_question_answered)
		
		boss.boss_fight_started.connect(control.hide_and_disable_timer)
		
		boss.boss_fight_started.connect(player.enable_attack)
		
		boss.boss_fight_started.connect(convert_coins_to_lives)
		
		
func reload_game(cause: String = ""):
	await get_tree().create_timer(1.0).timeout
	
	if cause == "Boss" or cause == "Tiro do Boss":
		game_over()
	else:
		get_tree().reload_current_scene()

func game_over():
	get_tree().change_scene_to_file("res://extras/game_over.tscn")

func convert_coins_to_lives():
	if Globals.coins > 0:
		var extra_lives = ceil(Globals.coins / 2.0)
		Globals.player_life += extra_lives
		
		print("Bônus de Batalha! O jogador tinha ", Globals.coins, " moedas e ganhou ", extra_lives, " vidas extras. Vidas totais: ", Globals.player_life)
