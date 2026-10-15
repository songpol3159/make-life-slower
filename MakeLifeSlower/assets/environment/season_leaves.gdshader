shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap;
uniform sampler2D leaf_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 base_color : source_color = vec4(1.0);
uniform float autumn=0.0;
uniform float snow_amount=0.0;
uniform bool textured=true;
uniform bool evergreen=false;
void fragment(){
 vec4 leaf=textured?texture(leaf_texture,UV):vec4(1.0);
 float lightness=dot(leaf.rgb*base_color.rgb,vec3(.22,.65,.13));
 vec3 color=leaf.rgb*base_color.rgb*vec3(1.08,1.06,.94);
 vec3 gold=vec3(lightness*1.5,lightness*.78,lightness*.23);
 color=mix(color,gold,evergreen?0.0:autumn);
 ALBEDO=mix(color,vec3(.86,.91,.93),snow_amount*(evergreen?.55:.83));
 EMISSION=ALBEDO*.035;
 ALPHA=leaf.a;ALPHA_SCISSOR_THRESHOLD=.45;ROUGHNESS=1.0;
}
