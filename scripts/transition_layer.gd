extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

# Função para mudar para uma cena totalmente nova
func change_scene(target_scene_path: String) -> void:
	var mat = color_rect.material as ShaderMaterial
	
	# Cria a animação (Tween)
	var tween = create_tween()
	
	# FADE OUT: Anima o 'threshold' até 1.0 em 0.5 segundos
	# (Note que no Godot 4, acessamos uniforms com "shader_parameter/nome")
	tween.tween_property(mat, "shader_parameter/threshold", 1.0, 0.5)
	
	# Espera o Fade Out terminar
	await tween.finished
	
	# Troca de fato a cena
	get_tree().change_scene_to_file(target_scene_path)
	
	# FADE IN: Anima o 'threshold' de volta para 0.0 em 0.5 segundos
	var tween_in = create_tween()
	tween_in.tween_property(mat, "shader_parameter/threshold", 0.0, 0.5)


# Função para recarregar a cena atual (útil para quando o player morre)
func reload_scene() -> void:
	var mat = color_rect.material as ShaderMaterial
	var tween = create_tween()
	
	tween.tween_property(mat, "shader_parameter/threshold", 1.0, 0.5)
	await tween.finished
	
	get_tree().reload_current_scene()
	
	var tween_in = create_tween()
	tween_in.tween_property(mat, "shader_parameter/threshold", 0.0, 0.5)
