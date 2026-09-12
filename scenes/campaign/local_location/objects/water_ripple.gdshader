shader_type canvas_item;

// Настройки скорости течения
uniform vec2 flow_speed = vec2(0.04, 0.0);
uniform vec2 micro_wave_speed = vec2(-0.015, 0.008);

// Сила волнового искажения
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.015;
uniform vec2 wave_frequency = vec2(12.0, 6.0);

// Итоговая прозрачность и модуляция ряби
uniform float ripple_opacity : hint_range(0.0, 1.0) = 0.55;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	// Базовый UV со спокойным горизонтальным смещением
	vec2 uv = UV + flow_speed * TIME;

	// Мягкое двухволновое искажение UV без швов и резких перегибов
	float wave_x = sin(UV.y * wave_frequency.y + TIME * micro_wave_speed.x * 20.0);
	float wave_y = cos(UV.x * wave_frequency.x + TIME * micro_wave_speed.y * 20.0);
	vec2 offset = vec2(wave_x, wave_y) * distortion_strength;

	vec4 tex_color = texture(TEXTURE, uv + offset);

	COLOR = tex_color * tint_color;
	COLOR.a *= ripple_opacity;
}
