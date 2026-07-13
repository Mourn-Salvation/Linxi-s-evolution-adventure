shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float pixel_size = 2.0;
uniform float palette_steps = 7.0;
uniform float edge_strength = 0.26;
uniform vec4 edge_tint : source_color = vec4(0.035, 0.045, 0.055, 1.0);

void fragment() {
	vec2 snapped_uv = UV;
	if (pixel_size > 1.0) {
		vec2 block = TEXTURE_PIXEL_SIZE * pixel_size;
		snapped_uv = floor(UV / block) * block + block * 0.5;
	}

	vec4 color = texture(TEXTURE, snapped_uv);
	if (color.a <= 0.01) {
		COLOR = color;
		return;
	}

	vec3 stepped = floor(color.rgb * palette_steps) / palette_steps;
	float right_alpha = texture(TEXTURE, snapped_uv + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	float left_alpha = texture(TEXTURE, snapped_uv - vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	float down_alpha = texture(TEXTURE, snapped_uv + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
	float up_alpha = texture(TEXTURE, snapped_uv - vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
	float edge = clamp(
		abs(color.a - right_alpha)
		+ abs(color.a - left_alpha)
		+ abs(color.a - down_alpha)
		+ abs(color.a - up_alpha),
		0.0,
		1.0
	);

	vec3 shaded = mix(stepped, edge_tint.rgb, edge * edge_strength);
	COLOR = vec4(shaded, color.a);
}
