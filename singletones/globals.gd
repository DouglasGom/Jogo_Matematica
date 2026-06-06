extends Node

var coins := 0
var score := 0
var player_life := 3

var player = null
var current_checkpoint_pos = null 

var backup_coins := 0
var backup_score := 0

func save_checkpoint_data(pos: Vector2):
	current_checkpoint_pos = pos
	backup_coins = coins
	backup_score = score

# Função de respawn atualizada
func respawn_player():
	if current_checkpoint_pos != null and player != null:
		player.global_position = current_checkpoint_pos
		
		coins = backup_coins
		score = backup_score
		
		player_life = 3
