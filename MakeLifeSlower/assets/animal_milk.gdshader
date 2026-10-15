shader_type spatial;
render_mode cull_disabled;
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform bool textured = false;
uniform bool vertex_colored = false;
uniform float milk_pull = 0.0;
void vertex(){
 // Cow's source mesh: deform only the udder/teats, leaving torso and legs alone.
 float x_mask = smoothstep(0.18,0.34,VERTEX.x)*(1.0-smoothstep(0.74,0.86,VERTEX.x));
 float y_mask = smoothstep(0.14,0.24,VERTEX.y)*(1.0-smoothstep(0.46,0.58,VERTEX.y));
 float z_mask = 1.0-smoothstep(0.18,0.27,abs(VERTEX.z));
 VERTEX.y -= milk_pull*0.055*x_mask*y_mask*z_mask;
}
void fragment(){
 ALBEDO=albedo_tint.rgb*(textured?texture(albedo_texture,UV).rgb:vec3(1.0))*(vertex_colored?COLOR.rgb:vec3(1.0));
 ROUGHNESS=0.85;
}
