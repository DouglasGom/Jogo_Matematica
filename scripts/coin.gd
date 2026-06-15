extends Area2D

@onready var animation := $anim as AnimatedSprite2D
@onready var collect_sfx: AudioStreamPlayer = $collect_sfx as AudioStreamPlayer

var coins = 1
var is_collected := false 

func _on_body_entered(body: Node2D) -> void:

	if body.name != "player" or is_collected:
		return
		
	is_collected = true 
	
	$collision.set_deferred("disabled", true)
	
	animation.play('collect')
	Globals.coins += coins
	collect_sfx.play()
	print(Globals.coins)
	
func _on_anim_animation_finished() -> void:
	queue_free()
