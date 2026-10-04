shader_type canvas_item;
uniform sampler2D painting : source_color, filter_linear;
uniform sampler2D previous_mask : filter_linear;
uniform sampler2D light_mask : filter_linear;
uniform float blend = 1.0;
uniform vec4 crop = vec4(0.0, 0.20, 1.0, 0.64);
void fragment() {
    vec3 paint = texture(painting, crop.xy + UV * crop.zw).rgb;
    float light = mix(texture(previous_mask, UV).r, texture(light_mask, UV).r, blend);
    float luminance = dot(paint, vec3(0.299, 0.587, 0.114));
    vec3 night = mix(vec3(0.06, 0.08, 0.16), vec3(0.30, 0.36, 0.54), luminance);
    vec3 warm = paint * vec3(1.06, 0.98, 0.86);
    COLOR = vec4(mix(night, warm, light), 1.0);
}
