shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_size = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	vec2 pixel = TEXTURE_PIXEL_SIZE * outline_size;

	float left  = texture(TEXTURE, UV + vec2(-pixel.x, 0.0)).a;
	float right = texture(TEXTURE, UV + vec2( pixel.x, 0.0)).a;
	float up    = texture(TEXTURE, UV + vec2(0.0, -pixel.y)).a;
	float down  = texture(TEXTURE, UV + vec2(0.0,  pixel.y)).a;

	float edge = max(max(left, right), max(up, down));

	if (color.a == 0.0 && edge > 0.0) {
		COLOR = outline_color;
	} else {
		COLOR = color;
	}
}