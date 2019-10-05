shader_type canvas_item;

uniform float seed = 1.1;

void vertex(){
	VERTEX.x += (sin(TIME * 1.5 * seed + (100.0 * seed * seed)) -0.5)	* 12.0;
	VERTEX.y += (sin(TIME * 0.5 * seed + (100.0 * seed * seed)))	* 6.0;
}