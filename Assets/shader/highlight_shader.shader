shader_type canvas_item;
uniform vec4 color: hint_color;
void fragment(){
	vec4 final_color = mix(color,texture(TEXTURE, UV + TIME * 0.01), 0.6);
	final_color.a = 1.0;
	if(distance(vec2(0.03,0.03), UV) > 0.02){
//		final_color.a =  (0.02 / distance(vec2(0.03,0.03), UV));
//		final_color.a =  1.0 - (distance(vec2(0.03,0.03), UV)/0.04);
	}
	final_color.a = 0.6 - (distance(vec2(0.03,0.03), UV)/0.05);
	if( final_color.a < 0.0){
		final_color.a = 0.0;
		}
	COLOR = final_color;
}

//void vertex() {
//  // Animate Sprite moving in big circle around its location
//  VERTEX += vec2(cos(TIME)*10.0, sin(TIME)*10.0);
//}