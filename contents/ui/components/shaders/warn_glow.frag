#version 440

// Soft inner halo along the glass edge — the "next prayer is close" warning.
//
// The silhouette is the same superellipse (squircle) used by liquidglass.frag,
// so the glow hugs the card exactly, including the corner rounding.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    vec2  size;        // widget size in px
    float radius;      // corner radius in px
    float roundness;   // superellipse exponent
    float bandWidth;   // how far the halo reaches inward, in px
    vec4  glowColor;   // rgb + maximum alpha
    float strength;    // 0..1, pulsed from QML
};

// Distance to the squircle silhouette (negative inside, positive outside).
float sceneSDF(vec2 p) {
    vec2 b = size * 0.5;
    float n = max(roundness, 2.0);
    float r = clamp(radius, 0.0, min(b.x, b.y));

    vec2 q = abs(p) - b + vec2(r);
    float qx = max(q.x, 0.0);
    float qy = max(q.y, 0.0);

    if (qx <= 0.0 && qy <= 0.0)
        return max(q.x, q.y) - r;
    if (qx == 0.0)
        return qy - r;
    if (qy == 0.0)
        return qx - r;

    float arc = pow(pow(qx, n) + pow(qy, n), 1.0 / n);
    float gx = pow(qx / arc, n - 1.0);
    float gy = pow(qy / arc, n - 1.0);
    float gradLen = max(sqrt(gx * gx + gy * gy), 1e-3);
    return (arc - r) / gradLen;
}

void main() {
    vec2 p = (qt_TexCoord0 - vec2(0.5)) * size;
    float d = sceneSDF(p);

    // Clip to the card (1px of feather at the silhouette).
    float inside = 1.0 - smoothstep(-1.0, 1.0, d);

    // Halo: strongest at the edge, fading inwards over bandWidth.
    // d is negative inside the card, so depth = -d is the distance inward.
    float depth = clamp(-d / max(bandWidth, 1.0), 0.0, 1.0);
    float halo = pow(1.0 - depth, 2.2) * inside;

    // A thin, slightly brighter rim right on the edge.
    float rim = (1.0 - smoothstep(0.0, 1.8, abs(d + 0.9))) * inside;

    float a = clamp((halo * 0.8 + rim * 0.55) * glowColor.a * strength, 0.0, 1.0);
    a *= qt_Opacity;

    // Premultiplied output (Qt Quick's default blend mode).
    fragColor = vec4(glowColor.rgb * a, a);
}
