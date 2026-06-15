extends CharacterBody2D


const SPEED = 1500.0
const JUMP_VELOCITY = -400.0

@onready var wall_detector = $wall_detector as RayCast2D
@onready var texture = $texture as AnimatedSprite2D

var direction := -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		#print("Colidiu")

	if direction == 1:
		texture.flip_h = true
	else:
		texture.flip_h = false
		
	velocity.x = direction * SPEED * delta

	move_and_slide()


func _on_texture_animation_finished() -> void:
	if texture.animation == "hurt":
		Globals.score += 100
		queue_free();
