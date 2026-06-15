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
@onready var player_hurt: AudioStreamPlayer = $player_hurt


signal player_has_died()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		jump_sfx.play()
	elif is_on_floor():
		is_jumping = false
		
	if Input.is_action_just_pressed("player_attack") and not is_attacking and can_attack:
		perform_attack()

	direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		
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
	if not body.is_in_group("enemies"):
		return
		
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
	
	if Globals.player_life <= 0:
		queue_free()
		emit_signal("player_has_died", source)
		return
	
	if knocback_force != Vector2.ZERO:
		knockback_vector = knocback_force
		var knoback_tween := get_tree().create_tween()
		knoback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1)
		player_hurt.play()
		knoback_tween.tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
		
		await knoback_tween.finished
		is_invulnerable = false
func perform_attack():
	is_attacking = true
	animation.play("attack")
	
	if projectile_scene != null:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		
		var facing_dir = sign(animation.scale.x)
		if facing_dir == 0:
			facing_dir = 1
			
		proj.global_position = self.global_position + Vector2(facing_dir * 20, 0)
		proj.direction = facing_dir
		
func _on_anim_animation_finished() -> void:
	if animation.animation == "attack":
		is_attacking = false

func enable_attack():
	can_attack = true
	print("Poder de ataque liberado!")
