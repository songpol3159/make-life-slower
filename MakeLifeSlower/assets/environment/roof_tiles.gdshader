shader_type spatial;
uniform sampler2D color_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float snow_amount=0.0;
varying vec3 position_world;
void vertex(){position_world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec2 uv=position_world.xz*.55;
 vec3 tiles=texture(color_texture,uv).rgb;
 float value=dot(tiles,vec3(.25,.6,.15));
 vec3 warm=mix(tiles,vec3(value)*vec3(1.04,.83,.64),.88);
 ALBEDO=mix(warm,vec3(.86,.90,.91),snow_amount);
 NORMAL_MAP=mix(texture(normal_texture,uv).rgb,vec3(.5,.5,1.0),snow_amount);NORMAL_MAP_DEPTH=.55;ROUGHNESS=.9;
}
