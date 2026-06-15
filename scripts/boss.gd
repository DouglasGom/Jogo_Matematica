extends CharacterBody2D

enum States { IDLE, ATTACK_SHOOT, HURT, DEAD, RECOVERY }
var current_state = States.IDLE

@export var max_health := 100
var current_health := 100
var checkpoints = [80, 60, 40, 20, 0] 

var current_checkpoint_in_question := -1

@export var projectile_scene: PackedScene 
@onready var anim: AnimatedSprite2D = $anim
@onready var attack_timer: Timer = $attack_timer
@onready var health_bar: TextureProgressBar = $boss_health_bar
@onready var boss_hurt: AudioStreamPlayer = $boss_hurt
@onready var boss_recovery: AudioStreamPlayer = $boss_recovery


var facing_direction := -1

# --- VARIÁVEIS DO TIMER (NOVO) ---
var time_left := 600.0 # 600 segundos = 10 minutos
var is_timer_active := false
@onready var timer_label: Label = $BossUI/timer_label
# ---------------------------------

# Puxa a gravidade padrão configurada no seu Godot
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal question_time_triggered()
signal boss_fight_started() # NOVO SINAL

func _ready() -> void:
	anim.play("idle")
	current_health = max_health
	
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.hide() 
	
	# Esconde o timer no início (NOVO)
	if timer_label != null:
		timer_label.hide()

# --- NOVA FUNÇÃO DE FÍSICA PARA O KNOCKBACK ---
func _physics_process(delta: float) -> void:
	# Aplica a gravidade para ele voltar ao chão após o empurrão
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Se estiver no chão, vai parando devagarzinho (atrito)
		velocity.x = move_toward(velocity.x, 0, 600 * delta)

	move_and_slide()

func _process(delta: float) -> void:
	# Só diminui o tempo se a luta começou e o boss estiver vivo
	if is_timer_active and current_state != States.DEAD:
		time_left -= delta
		
		# O tempo acabou! Game Over.
		if time_left <= 0:
			time_left = 0
			is_timer_active = false
			print("O tempo acabou! Game Over.")
			get_tree().change_scene_to_file("res://extras/game_over.tscn")
			
		# Atualiza o texto na tela no formato MM:SS
		if timer_label != null:
			var minutes = int(time_left) / 60
			var seconds = int(time_left) % 60
			timer_label.text = "\n%s: %02d:%02d" % ["TEMPO", minutes, seconds]

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if health_bar != null and current_state != States.DEAD:
		health_bar.show()
		
	# Inicia e mostra o timer na primeira vez que vir o boss
	if not is_timer_active and current_state != States.DEAD and time_left > 0:
		is_timer_active = true
		if timer_label != null:
			timer_label.show()
			
		# Grita que a luta começou!
		emit_signal("boss_fight_started")
		
		# NOVO: O Boss só começa a atirar agora!
		attack_timer.start()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if health_bar != null:
		health_bar.hide()
	if health_bar != null:
		health_bar.hide()

# --- FUNÇÕES DE DANO E ATAQUE ---
func take_damage(amount := 1) -> void:
	if current_state == States.HURT or current_state == States.DEAD or current_state == States.RECOVERY:
		return
		
	current_health -= amount*10
	if current_health < 0:
		current_health = 0 
		
	if health_bar != null:
		health_bar.value = current_health
		
	current_state = States.HURT
	attack_timer.stop()
	boss_hurt.play()
	anim.play("hurt")
	
	
	# --- EFEITOS DO IMPACTO (NOVO) ---
	anim.modulate = Color(1, 0, 0, 1) # Deixa a textura totalmente vermelha
	
	# Joga o boss para cima (eixo Y negativo) e para trás (invertendo a direção que ele olha)
	# Pode aumentar ou diminuir o 150 e o 250 se quiser o empurrão mais forte/fraco!
	velocity = Vector2(-facing_direction * 150, -250) 

func trigger_question() -> void:
	print("Checkpoint atingido! A preparar a pergunta... Vida: ", current_health)
	current_state = States.IDLE
	anim.play("idle")
	emit_signal("question_time_triggered")

func _on_question_answered(is_correct: bool) -> void:
	if is_correct:
		if current_checkpoint_in_question == 0:
			die()
		else:
			current_health -= 10
			if health_bar != null:
				health_bar.value = current_health
				
			current_state = States.IDLE
			anim.play("idle")
			attack_timer.start()
	else:
		var target_health = current_checkpoint_in_question + 20
		if target_health > max_health:
			target_health = max_health
			
		current_health = target_health
		if health_bar != null:
			health_bar.value = current_health
			
		if not checkpoints.has(current_checkpoint_in_question):
			checkpoints.append(current_checkpoint_in_question)
			checkpoints.sort_custom(func(a, b): return a > b) 
			
		current_state = States.RECOVERY
		anim.play("recovery")
		boss_recovery.play()

func die() -> void:
	if current_state == States.DEAD:
		return
		
	print("Boss derrotado!")
	current_state = States.DEAD
	attack_timer.stop() 
	
	# Garante que ele volta à cor original (branca) caso morra
	anim.modulate = Color(1, 1, 1, 1) 
	
	if health_bar != null:
		health_bar.hide() 
		
	# Esconde o timer da vitória!
	if timer_label != null:
		timer_label.hide()
	
	$collision.set_deferred("disabled", true) 
	anim.play("destroy")
	if current_state == States.DEAD:
		return
		
	print("Boss derrotado!")
	current_state = States.DEAD
	attack_timer.stop() 
	anim.modulate = Color(1, 1, 1, 1) 
	
	if health_bar != null:
		health_bar.hide() 
		
	# Esconde o timer da vitória! (NOVO)
	if timer_label != null:
		timer_label.hide()
	
	$collision.set_deferred("disabled", true) 
	anim.play("destroy")
	if current_state == States.DEAD:
		return
		
	print("Boss derrotado!")
	current_state = States.DEAD
	attack_timer.stop() 
	
	# Garante que ele volta à cor original (branca) caso morra, para a explosão não ser vermelha
	anim.modulate = Color(1, 1, 1, 1) 
	
	if health_bar != null:
		health_bar.hide() 
	
	anim.play("destroy")

# --- ANIMAÇÕES E TIROS ---
func _on_anim_animation_finished() -> void:
	if current_state == States.ATTACK_SHOOT and anim.animation == "attack":
		current_state = States.IDLE
		anim.play("idle")
		
	elif current_state == States.HURT and anim.animation == "hurt":
		# Limpa a cor vermelha quando a dor acaba (NOVO)
		anim.modulate = Color(1, 1, 1, 1) 
		
		var hit_checkpoint = false
		for cp in checkpoints:
			if current_health == cp:
				hit_checkpoint = true
				current_checkpoint_in_question = cp 
				checkpoints.erase(cp)
				break
		
		if hit_checkpoint:
			trigger_question()
		else:
			current_state = States.IDLE
			anim.play("idle")
			attack_timer.start()
			
	elif current_state == States.RECOVERY and anim.animation == "recovery":
		current_state = States.IDLE
		anim.play("idle")
		attack_timer.start() 
		
	elif current_state == States.DEAD and anim.animation == "destroy":
		queue_free()
		get_tree().change_scene_to_file("res://extras/victory.tscn")

func _on_attack_timer_timeout() -> void:
	if current_state == States.IDLE:
		perform_shoot_attack()

func perform_shoot_attack() -> void:
	current_state = States.ATTACK_SHOOT
	anim.play("attack")
	
	if projectile_scene != null:
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = self.global_position + Vector2(facing_direction * 20, 30)
		proj.direction = Vector2(facing_direction, 0)
