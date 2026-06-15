extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func change_scene(target_scene_path: String) -> void:
	var mat = color_rect.material as ShaderMaterial
	
	var tween = create_tween()
	
	tween.tween_property(mat, "shader_parameter/threshold", 1.0, 0.5)
	
	await tween.finished
	
	get_tree().change_scene_to_file(target_scene_path)
	
	var tween_in = create_tween()
	tween_in.tween_property(mat, "shader_parameter/threshold", 0.0, 0.5)


func reload_scene() -> void:
	var mat = color_rect.material as ShaderMaterial
	var tween = create_tween()
	
	tween.tween_property(mat, "shader_parameter/threshold", 1.0, 0.5)
	await tween.finished
	
	get_tree().reload_current_scene()
	
	var tween_in = create_tween()
	tween_in.tween_property(mat, "shader_parameter/threshold", 0.0, 0.5)
