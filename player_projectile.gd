extends Area2D

@export var speed := 500.0
var direction := 1 # 1 para a direita, -1 para a esquerda

func _process(delta: float) -> void:
	# Move a bola de energia na direção que o player estiver a olhar
	position.x += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# O Plano A é o grupo "enemies". O Plano B é o próprio nome "boss" do nó!
	if body.is_in_group("enemies") or body.name == "boss":
		print("O tiro acertou em cheio o: ", body.name)
		
		if body.has_method("take_damage"):
			body.take_damage(1)
			print("Dano de 1 aplicado no Boss!")
			
		queue_free() # Destrói a bola de energia

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
