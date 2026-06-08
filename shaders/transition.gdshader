shader_type canvas_item;

// A cor do seu fade. O padrão é preto.
uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Controle da opacidade. Substitui o antigo "threshold".
uniform float alpha : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Aplica a cor preta com a opacidade atual
    COLOR = vec4(fade_color.rgb, alpha);
}