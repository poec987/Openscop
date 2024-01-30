shader_type canvas_item;
uniform float gradient_power = 10.;
//const float 
uniform float offset = 0;
void fragment(){
    if (COLOR.rgb!=vec3(0.,0.,0.) && COLOR.rgb!=vec3(1.,1.,1.)) {
        COLOR *= fract((SCREEN_UV.y*gradient_power)+offset);
    }
}