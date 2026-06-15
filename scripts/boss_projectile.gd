extends Area2D

@export var speed := 400.0
var direction := Vector2.LEFT 

func _process(delta: float) -> void:
	position += direction * speed * delta

var has_hit := false 

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and not has_hit:
		has_hit = true 
		
		if body.has_method("take_damage"):
			var knockback_dir = sign(direction.x)
			body.take_damage(Vector2(knockback_dir * 250, -200), 0.25, "Tiro do Boss")
			
		set_deferred("monitoring", false)
		
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() 
