extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -300.0
var direction

var is_jumping := false
var knockback_vector := Vector2.ZERO

var is_invulnerable := false
@export var projectile_scene: PackedScene
var is_attacking := false

var can_attack := false

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform = $remote as RemoteTransform2D
@onready var jump_sfx: AudioStreamPlayer = $jump_sfx as AudioStreamPlayer

signal player_has_died()

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Controle do pulo (NO PLAYER.GD)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# APAGUE A LINHA: animation.play('jump')
		is_jumping = true
		jump_sfx.play()
	elif is_on_floor():
		is_jumping = false
		
		# Controlo do ataque
	if Input.is_action_just_pressed("player_attack") and not is_attacking and can_attack:
		perform_attack()

	# Pega a direção do input e controla o movimento/desaceleração
	direction = Input.get_axis("move_left", "move_right")
	
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
	# Se estiver a atacar, não muda a animação até terminar!
	if is_attacking:
		return
		
	var state = "idle"
	
	if !is_on_floor(): 
		state = "jump"
	elif direction != 0:
		state = "run"
	
	if animation.name != state:
		animation.play(state)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Trava de segurança: só reage se for um inimigo
	if not body.is_in_group("enemies"):
		return
		
	# NOVO: Descobre se quem encostou foi o boss ou outro inimigo
	var damage_source = "Inimigo Comum"
	if body.name == "boss":
		damage_source = "Boss"
		
	if $ray_right.is_colliding():
		take_damage(Vector2(-200, -200), 0.25, damage_source)
	elif $ray_left.is_colliding():
		take_damage(Vector2(200, -200), 0.25, damage_source)
		

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
	
func take_damage(knocback_force := Vector2.ZERO, duration := 0.25, source := "Desconhecido"):
	if is_invulnerable:
		return 
		
	is_invulnerable = true 
	Globals.player_life -= 1
	
	print("Dano recebido de: ", source, " | Vidas restantes: ", Globals.player_life)
	
	# Só morre e some SE a vida realmente zerar
	if Globals.player_life <= 0:
		queue_free()
		emit_signal("player_has_died", source) # NOVO: Manda a causa da morte!
		return
	
	# Se ainda tem vida, faz o empurrão e pisca vermelho
	if knocback_force != Vector2.ZERO:
		knockback_vector = knocback_force
		var knoback_tween := get_tree().create_tween()
		knoback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1)
		knoback_tween.tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
		
		await knoback_tween.finished
		is_invulnerable = false
func perform_attack():
	is_attacking = true
	animation.play("attack")
	
	if projectile_scene != null:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		
		# Verifica para que lado o player está virado usando a escala da animação
		var facing_dir = sign(animation.scale.x)
		if facing_dir == 0:
			facing_dir = 1
			
		# Coloca a bola de energia um pouco à frente do player
		proj.global_position = self.global_position + Vector2(facing_dir * 20, 0)
		proj.direction = facing_dir
		
func _on_anim_animation_finished() -> void:
	if animation.animation == "attack":
		is_attacking = false

func enable_attack():
	can_attack = true
	print("Poder de ataque liberado!")
