class_name BattleScreenFeedback
extends ColorRect

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform vec4 tint : source_color = vec4(1.0);
uniform bool edges_only = false;
void fragment() {
	float edge = smoothstep(0.2, 0.7, length(UV - vec2(0.5)));
	COLOR = vec4(tint.rgb, tint.a * (edges_only ? edge : 1.0));
}
"""
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	material = shader_material
	modulate.a = 0


func flash(tint: Color = Color(1, 1, 1, 0.22), duration: float = 0.25, edges_only: bool = false) -> void:
	if _tween != null:
		_tween.kill()
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("edges_only", edges_only)
	modulate.a = 1
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, maxf(duration, 0.01))


func damage_flash() -> void:
	flash(Color(0.85, 0.06, 0.02, 0.5), 0.3, true)


func dark_flash() -> void:
	flash(Color(0, 0, 0, 0.4), 0.4)


func reset() -> void:
	if _tween != null:
		_tween.kill()
	modulate.a = 0
