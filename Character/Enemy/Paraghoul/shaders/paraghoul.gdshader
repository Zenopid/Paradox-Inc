shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, vec3(1,0,1).rgb, 1);
	COLOR = color;
	//COLOR = vec4(1,1,1,1);
}

void vertex() {
	VERTEX += vec2(10.0, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
