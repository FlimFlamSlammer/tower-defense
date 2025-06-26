shader_type canvas_item;

uniform vec4 line_color = vec4(1);
uniform float line_thickness : hint_range(0, 32) = 1.0;

varying flat vec4 modulate;

void fragment() {
	modulate = COLOR;
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;

	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + 0.7 * vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + 0.7 * vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + 0.7 * vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + 0.7 * vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV);
	vec4 modulated = vec4(color.r, color.g, color.b, color.a * modulate.a);
	COLOR = mix(modulated, line_color, outline - color.a);
}