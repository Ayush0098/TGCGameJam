shader_type canvas_item;
// Full-screen night view of the room painting behind the HUD. Uses the same
// night grade as room_light.gdshader, so the lit stage band blends into it.
uniform sampler2D painting : source_color, filter_linear;
uniform vec4 crop = vec4(0.0, 0.0, 1.0, 1.0);
void fragment() {
    vec2 at = clamp(crop.xy + UV * crop.zw, vec2(0.0), vec2(1.0));
    vec3 paint = texture(painting, at).rgb;
    float luminance = dot(paint, vec3(0.299, 0.587, 0.114));
    vec3 night = mix(vec3(0.06, 0.08, 0.16), vec3(0.30, 0.36, 0.54), luminance);
    COLOR = vec4(night, 1.0);
}
