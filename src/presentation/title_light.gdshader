shader_type canvas_item;
// Title screen: the room painting at night, with a warm torch pool that follows
// the cursor (the game's core idea, "light reveals", before the first page).
uniform sampler2D painting : source_color, filter_linear;
uniform vec2 light_pos = vec2(0.5, 0.45);   // in UV
uniform float radius = 0.26;
uniform float aspect = 1.7778;
uniform float glow = 1.0;
void fragment() {
    vec3 paint = texture(painting, UV).rgb;
    float luminance = dot(paint, vec3(0.299, 0.587, 0.114));
    vec3 night = mix(vec3(0.05, 0.065, 0.13), vec3(0.26, 0.31, 0.47), luminance);
    vec2 d = (UV - light_pos) * vec2(aspect, 1.0);
    float pool = 1.0 - smoothstep(radius * 0.35, radius, length(d));
    vec3 warm = paint * vec3(1.08, 0.98, 0.84) * (0.9 + 0.1 * glow);
    vec3 colour = mix(night, warm, pool * glow);
    // Soft vignette keeps the eye on the middle.
    float edge = smoothstep(0.95, 0.35, length((UV - 0.5) * vec2(aspect * 0.62, 1.0)));
    COLOR = vec4(colour * mix(0.55, 1.0, edge), 1.0);
}
