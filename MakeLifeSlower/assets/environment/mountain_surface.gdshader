shader_type spatial;
uniform sampler2D rock_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 position_world;
varying vec3 normal_world;
void vertex(){position_world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;normal_world=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 w=pow(abs(normal_world),vec3(3.0));w/=max(w.x+w.y+w.z,.001);
 vec3 rock=texture(rock_texture,position_world.zy*.055).rgb*w.x+texture(rock_texture,position_world.xz*.055).rgb*w.y+texture(rock_texture,position_world.xy*.055).rgb*w.z;
 float detail=dot(rock,vec3(.25,.60,.15));
 ALBEDO=COLOR.rgb*(.65+detail*.65);ROUGHNESS=1.0;
}
