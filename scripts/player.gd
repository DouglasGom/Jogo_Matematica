extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -300.0
var direction

var is_jumping := false
var knockback_vector := Vector2.ZERO


@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform = $remote as RemoteTransform2D
@onready var jump_sfx: AudioStreamPlayer = $jump_sfx as AudioStreamPlayer
@onready var body := $body as CharacterBody2D

signal player_has_died()

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Controle do pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play('jump')
		is_jumping = true
		jump_sfx.play()
	elif is_on_floor():
		is_jumping = false

	# Pega a direção do input e controla o movimento/desaceleração
	direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		
		# Define a animação correta em movimento
		#if not is_jumping and is_on_floor():
			#animation.play('run')
		#else:
			#animation.play('jump')
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	_set_state()
	move_and_slide()

func _set_state():
	var state = "idle"
	
	if !is_on_floor(): 
		state = "jump"
	elif direction != 0:
		state = "run"
	
	if animation.name != state:
		animation.play(state)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemies"):
		#queue_free()
	if Globals.player_life <= 0:
		queue_free()
		emit_signal("player_has_died")
	else:
		if $ray_right.is_colliding():
			take_damage(Vector2(-200, -200))
		elif $ray_left.is_colliding():
			take_damage(Vector2(200, -200))
		elif body.is_in_group("fireball"):
			#dano com a bola de fogo do microondas
			body.queue_free()
		
func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
	
func take_damage(knocback_force := Vector2.ZERO, duration := 0.25):
	Globals.player_life -= 1
	
	if knocback_force != Vector2.ZERO:
		knockback_vector = knocback_force
		
		var knoback_tween := get_tree().create_tween()
		
		knoback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1)
		knoback_tween.tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
