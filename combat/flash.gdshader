// Lässt ein Sprite in einer Farbe aufblitzen (Treffer weiß, Gegner-Ausholen rot).
shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(mix(c.rgb, flash_color.rgb, flash), c.a);
}
