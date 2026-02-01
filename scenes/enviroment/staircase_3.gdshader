shader_type spatial;
render_mode world_vertex_coords, unshaded;
uniform vec4 top_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 left_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 right_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 front_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 back_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
varying vec3 world_normal;

// Vertex Shader
void vertex() {
	world_normal = normalize(NORMAL);
    }

// Fragment Shader
void fragment() {
	float weight_x = world_normal.x;
	float weight_y = world_normal.y;
	float weight_z = world_normal.z;
	
	vec3 x_axis_color = mix(right_color.rgb, left_color.rgb, weight_x*0.5 + 0.5) * abs(weight_x);
	vec3 y_axis_color = mix(bottom_color.rgb, top_color.rgb, weight_y*0.5 + 0.5) * abs(weight_y);
	vec3 z_axis_color = mix(front_color.rgb, back_color.rgb, weight_z*0.5 + 0.5) * abs(weight_z);
	
	
	ALBEDO = y_axis_color+x_axis_color+z_axis_color;
}   

//void light() {
//	// called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
