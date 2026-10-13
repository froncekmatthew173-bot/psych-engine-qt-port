#pragma header
uniform float iTime;
uniform sampler2D iChannel1;
#define iChannel0 bitmap
uniform vec4 iMouse;
uniform int  iFrame; 
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void Vignette_filter(inout vec3 color, vec2 pos){
float dist = distance(pos, vec2(0.5)) * 2.0;
dist = pow(dist,1.0);
vec3 DV = vec3(0.09)*dist;
color.rgb -= DV*5.0;
}

void Chromatic_Abberation(inout vec3 color, vec2 FragCoord){

    float dist = distance(FragCoord.st,vec2(0.5));
    
  color.r += texture(iChannel0, FragCoord.st+dist * 0.009).r;
  color.g += texture(iChannel0, FragCoord.st).g;
  color.b += texture(iChannel0, FragCoord.st-dist * 0.009).b;
  color.rgb = color/1.5;
}


void Cinematic_Cam(inout vec3 color, vec2 coord){
	if(coord.t < 0.07 || coord.t > 0.93){
		color.rgb *= 0.0;
	}
}

void BarteropeTonemap(inout vec3 color){

	float curve 			= 14.5;
	float Exposer 		= 0.1;

	float R						= 1.0;
	float G						= 1.0;
	float B						= 1.0;
	float sat				 	= 1.158;
    
	float avg 				= (color.r + color.g + color.b);
	vec3 vary 				= (color - avg );
    
	vec3 V						= (color - 0.1);
	vec3 cMult				= vec3(3);
    
	color 						= ((2.45*V+0.154)/(2.45*V+1.0));
	color						 *= vec3(Exposer);
    
	color 						= pow(color ,vec3(curve));
	color 						= ((vary*sat)+avg);
    
	color.r 					= (R*color.r);
	color.g 					= (G*color.g);
	color.b 					= (B*color.b);
    
	color							= color*cMult;
}



void mainImage()
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    vec2 uv2 = fragCoord.xy / iResolution.xy;
    
    fragColor = texture(iChannel0, uv2.st);
   	
    BarteropeTonemap(fragColor.rgb);
	Chromatic_Abberation(fragColor.rgb, uv2);
    Vignette_filter(fragColor.rgb, uv2);
}