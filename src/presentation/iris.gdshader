shader_type canvas_item;
// Cartoon iris wipe: ink everywhere outside a circle that opens or closes.
uniform vec2 centre = vec2(0.5, 0.5);
uniform float radius = 1.5;
uniform float aspect = 1.7778;
void fragment() {
    float d = length((UV - centre) * vec2(aspect, 1.0));
    float edge = smoothstep(radius, radius + 0.006, d);
    COLOR = vec4(0.141, 0.188, 0.263, edge);
}
