extends CharacterBody2D

# --- CÓDIGO ANTERIOR DOS ESTADOS E TIROS ---
enum States { IDLE, ATTACK_SHOOT, HURT, DEAD }
var current_state = States.IDLE

@export var projectile_scene: PackedScene 
@onready var anim: AnimatedSprite2D = $anim
@onready var attack_timer: Timer = $attack_timer

var facing_direction := -1

# --- NOVAS VARIÁVEIS DA VIDA E PERGUNTAS ---
@export var max_health := 5
var current_health := 5

# Referência à barra de vida que criámos
@onready var health_bar: TextureProgressBar = $CanvasLayer/boss_health_bar

# Sinal que vai avisar o jogo que é hora da pergunta
signal question_time_triggered()

func _ready() -> void:
	anim.play("idle")
	current_health = max_health
	
	if health_bar != null:
		print("Barra de vida encontrada com sucesso!")
		health_bar.max_value = max_health
		health_bar.value = current_health
	else:
		print("ERRO: O Godot não achou a barra de vida! Verifique o caminho.")
# --- NOVA FUNÇÃO DE RECEBER DANO ---
func take_damage(amount := 1) -> void:
	# Impede que ele tome múltiplos danos ao mesmo tempo enquanto já está machucado
	if current_state == States.HURT:
		return
		
	current_health -= amount
	if health_bar != null:
		health_bar.value = current_health
		
	# Muda o estado para HURT, para o ataque e faz a animação
	current_state = States.HURT
	attack_timer.stop()
	anim.play("hurt")
	print("Boss levou dano! Vida restante: ", current_health)

func trigger_question() -> void:
	print("O Boss levou dano! A preparar a pergunta... Vida restante: ", current_health)
	
	# Opcional: Pausar os ataques do Boss enquanto a pergunta estiver no ecrã
	attack_timer.stop() 
	current_state = States.IDLE
	anim.play("idle")
	
	# Emite o sinal para que a interface de perguntas apareça
	emit_signal("question_time_triggered")

func die() -> void:
	# Impede que ele morra duas vezes
	if current_state == States.DEAD:
		return
		
	print("Boss derrotado!")
	current_state = States.DEAD
	attack_timer.stop() # Para de atirar
	
	# Desativa a colisão para que o player não tome dano no corpo morto do Boss
	$collision.set_deferred("disabled", true) 
	
	anim.play("destroy")

func _on_anim_animation_finished() -> void:
	if current_state == States.ATTACK_SHOOT and anim.animation == "attack":
		current_state = States.IDLE
		anim.play("idle")
		
	elif current_state == States.HURT and anim.animation == "hurt":
		if current_health <= 0:
			die()
		else:
			trigger_question()
			
	# NOVA PARTE: Destrói o boss quando a explosão acabar
	elif current_state == States.DEAD and anim.animation == "destroy":
		queue_free()
