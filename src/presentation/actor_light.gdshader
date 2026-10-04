shader_type canvas_item;
uniform float lit = 1.0;
void fragment() {
    vec4 paint = texture(TEXTURE, UV) * COLOR;
    float luminance = dot(paint.rgb, vec3(0.299, 0.587, 0.114));
    vec3 night = mix(vec3(0.13, 0.16, 0.28), vec3(0.56, 0.64, 0.84), luminance);
    COLOR = vec4(mix(night, paint.rgb * vec3(1.06, 0.98, 0.86), lit), paint.a);
}
