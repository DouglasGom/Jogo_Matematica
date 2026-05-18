extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -350.0

var is_jumping := false
@onready var animation := $anim as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Controle do pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play('jump')
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Pega a direção do input e controla o movimento/desaceleração
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		
		# Define a animação correta em movimento
		if not is_jumping and is_on_floor():
			animation.play('run')
		else:
			animation.play('jump')
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# Define a animação correta parado
		if is_on_floor():
			animation.play('idle')
		else:
			animation.play('jump')

	move_and_slide()
