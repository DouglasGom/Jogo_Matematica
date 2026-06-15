extends Node2D

@onready var player := $player as CharacterBody2D
@onready var player_scene = preload("res://actors/player.tscn")
@onready var camera := $camera as Camera2D
@onready var control: Control = $HUD/control as Control
@onready var boss = $boss # Verifique se o nome do nó do Boss está correto
@onready var question_screen = $question_screen # O nó da tela que você acabou de adicionar

func _ready() -> void:
	Globals.player = player
	Globals.player.follow_camera(camera)
	Globals.player.player_has_died.connect(reload_game)
	control.time_is_up.connect(game_over)
	
	# Se o jogador já passou por um checkpoint antes do reload
	if Globals.current_checkpoint_pos != null:
		Globals.respawn_player()
	else:
		# Repõe apenas a vida para 3 no início de uma nova fase, 
		# mas mantém as moedas e os pontos que já estavam no Globals!
		Globals.player_life = 3
		
	if boss != null and question_screen != null:
		# O Boss chama o ecrã
		boss.question_time_triggered.connect(question_screen.show_question)
		# O ecrã devolve a resposta para o Boss
		question_screen.question_answered.connect(boss._on_question_answered)
		
		# Conecta o sinal do Boss à função de desligar do HUD
		boss.boss_fight_started.connect(control.hide_and_disable_timer)
		
		# Libera o ataque do player quando a boss fight começa!
		boss.boss_fight_started.connect(player.enable_attack)
		
		# NOVO: Conecta o sinal para converter as moedas em vidas!
		boss.boss_fight_started.connect(convert_coins_to_lives)
		
		
func reload_game(cause: String = ""):
	await get_tree().create_timer(1.0).timeout
	
	# Se a causa da morte foi o Boss (seja tiro ou corpo a corpo) -> GAME OVER
	if cause == "Boss" or cause == "Tiro do Boss":
		game_over()
	else:
		# Se morreu para um inimigo comum, buracos, etc. -> REINICIA DO CHECKPOINT
		# O seu _ready() e a função respawn_player() já estão configurados para 
		# repor a vida para 3 e colocar o player no lugar certo automaticamente!
		get_tree().reload_current_scene()

func game_over():
	get_tree().change_scene_to_file("res://extras/game_over.tscn")

# NOVA FUNÇÃO: Transforma moedas em vidas extras no início da batalha
func convert_coins_to_lives():
	if Globals.coins > 0:
		# Divide por 2.0 (para gerar número quebrado) e usa 'ceil' para arredondar sempre para cima
		var extra_lives = ceil(Globals.coins / 2.0)
		Globals.player_life += extra_lives
		
		# Imprime no console para você conferir a matemática funcionando
		print("Bônus de Batalha! O jogador tinha ", Globals.coins, " moedas e ganhou ", extra_lives, " vidas extras. Vidas totais: ", Globals.player_life)
