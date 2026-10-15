shader_type spatial;
uniform sampler2D grass_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 season_tint : source_color = vec3(1.0);
uniform float snow_amount=0.0;
uniform sampler2D road_mask : filter_linear, repeat_disable;
uniform sampler2D path_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D path_normal : hint_normal, filter_linear_mipmap, repeat_enable;
varying vec3 world_position;
void vertex(){world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 vec3 detail=texture(grass_texture,world_position.xz*.52).rgb;
 float lightness=dot(detail,vec3(.22,.62,.16));
 float patches=sin(world_position.x*.085+sin(world_position.z*.065)*1.8)*cos(world_position.z*.07)*.5+.5;
 vec3 masks=texture(road_mask,(world_position.xz+140.0)/280.0).rgb;
 vec3 meadow=mix(vec3(.31,.38,.14),vec3(.49,.56,.26),clamp(lightness*.24+patches*.22+masks.b*.50,0.0,1.0));
 meadow=mix(meadow,detail*vec3(1.05,1.05,.82),.10);
 meadow*=.94+lightness*.16;
 float path=masks.r;
 vec3 dirt=texture(path_texture,world_position.xz*.38).rgb;
 float gravel=dot(dirt,vec3(.25,.6,.15));
 dirt=mix(vec3(.46,.34,.20),vec3(.69,.55,.36),gravel);
 vec3 surface=mix(meadow*season_tint,dirt,path);
 ALBEDO=mix(surface,vec3(.84,.89,.92),snow_amount*(1.0-path*.65))*(.73+.27*masks.g);
 NORMAL_MAP=mix(vec3(.5,.5,1.0),texture(path_normal,world_position.xz*.38).rgb,path*.35*(1.0-snow_amount));
 ROUGHNESS=1.0;
}
