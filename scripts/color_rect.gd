extends ColorRect

var alpha_value: float = 0.0

func _process(delta: float) -> void:
	material.set("shader_parameter/alpha", alpha_value)
