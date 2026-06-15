extends Area2D

@export var speed := 400.0
var direction := Vector2.LEFT # O tiro vai para a esquerda por padrão

func _process(delta: float) -> void:
	# Move o projétil constantemente na direção escolhida
	position += direction * speed * delta

# Variável de trava de segurança
var has_hit := false 

func _on_body_entered(body: Node2D) -> void:
	# Só executa se for o player E se o tiro ainda não tiver batido em nada
	if body.name == "player" and not has_hit:
		has_hit = true # Trava o projétil para não dar dano duplo
		
		# Aplica o dano e o knockback
		if body.has_method("take_damage"):
			var knockback_dir = sign(direction.x)
			body.take_damage(Vector2(knockback_dir * 250, -200), 0.25, "Tiro do Boss")
			
		# Desativa a colisão do tiro imediatamente por precaução
		set_deferred("monitoring", false)
		
		queue_free()

# Conecte o sinal "screen_exited" do VisibleOnScreenNotifier2D a esta função
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Destrói o tiro se ele sair da tela
