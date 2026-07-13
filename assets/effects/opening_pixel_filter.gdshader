shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform vec2 filter_resolution = vec2(1280.0, 720.0);
uniform float palette_steps = 56.0;
uniform float scanline_strength = 0.045;
uniform float vignette_strength = 0.26;
uniform float chromatic_offset = 0.0009;

void fragment() {
	vec2 safe_resolution = max(filter_resolution, vec2(1280.0, 720.0));
	vec2 snapped_uv = (floor(SCREEN_UV * safe_resolution) + vec2(0.5)) / safe_resolution;

	float red = texture(screen_texture, snapped_uv + vec2(chromatic_offset, 0.0)).r;
	float green = texture(screen_texture, snapped_uv).g;
	float blue = texture(screen_texture, snapped_uv - vec2(chromatic_offset, 0.0)).b;
	vec3 color = vec3(red, green, blue);

	color = floor(color * palette_steps) / palette_steps;
	color = mix(color, vec3(dot(color, vec3(0.2126, 0.7152, 0.0722))), 0.08);
	color *= vec3(0.94, 0.98, 1.08);

	float scanline = 1.0 - scanline_strength * step(0.5, fract(SCREEN_UV.y * safe_resolution.y * 0.5));
	vec2 centered_uv = SCREEN_UV * 2.0 - vec2(1.0);
	float vignette = 1.0 - vignette_strength * smoothstep(0.35, 1.25, dot(centered_uv, centered_uv));

	COLOR = vec4(color * scanline * vignette, 1.0);
}
