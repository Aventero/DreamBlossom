shader_type spatial;

void vertex() {
	VERTEX.x += sin(TIME);
}

void fragment() {
	ALPHA = 1.0;
}
