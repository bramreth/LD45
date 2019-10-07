shader_type canvas_item;
uniform bool on;

void fragment(){
	if(on){
		if (UV.y < 0.58 && UV.x > 0.35){
			float t = TIME * 2.0;
		    vec2 uv = UV;
		    float uv_x_deform = cos( t*15.0) * 0.002;
			float uv_y_deform = 0.001 * clamp(tan(t* 3.0), 0.0, 2.0);
		    vec2 offs_uv = vec2(0.0,0.0);//vec2(sin(t), sin(t*5.0));//vec2(cos(t + uv.y ) * 0.5 + sin(t + uv.x) * 0.5 , cos(t + uv.x)* 0.5+ sin(t + uv.y) * 0.5) * 0.01;
		
		    vec4 img = texture(TEXTURE, uv + vec2(uv_x_deform, uv_y_deform));
		    COLOR = img;
		}else{
			COLOR =texture(TEXTURE, UV);
		}
	}else{
		COLOR =texture(TEXTURE, UV);
	}
}

void vertex(){
	if (VERTEX.y < 0.5)
		VERTEX.y += sin(TIME * 3.0) * 10.00;
	
	}