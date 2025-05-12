// Modified version of this shader: https://godotshaders.com/shader/3d-item-highlighter-with-angle-adjustment/
// Credits for original shader go to original creator.
shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress : hint_range(-2.0, 2.0, 0.05) = 0.5;
uniform float shine_width : hint_range(0.01, 1.0, 0.01) = 0.5;

uniform float shine_angle_x : hint_range(-90.0, 90.0, 15.0) = 0.0;
uniform float shine_angle_y : hint_range(-90.0, 90.0, 15.0) = 0.0;
uniform float shine_angle_z : hint_range(-90.0, 90.0, 15.0) = 0.0;

mat3 rotation_x(float angle_x)
{
    float cx = cos(radians(angle_x));
    float sx = sin(radians(angle_x));
    return mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cx, -sx),
        vec3(0.0, sx, cx)
    );
}

mat3 rotation_y(float angle_y)
{
    float cy = cos(radians(angle_y));
    float sy = sin(radians(angle_y));
    return mat3(
        vec3(cy, 0.0, sy),
        vec3(0.0, 1.0, 0.0),
        vec3(-sy, 0.0, cy)
    );
}

mat3 rotation_z(float angle_z)
{
    float cz = cos(radians(angle_z));
    float sz = sin(radians(angle_z));
    return mat3(
        vec3(cz, -sz, 0.0),
        vec3(sz, cz, 0.0),
        vec3(0.0, 0.0, 1.0)
    );
}

mat3 rotation_matrix() {
    return rotation_x(shine_angle_x) * rotation_y(shine_angle_y) * rotation_z(shine_angle_z);
}

void fragment() {
    vec3 vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    mat3 rotation = rotation_matrix();
    vertex = rotation * vertex;
    
    // Convert vertex position to 0-1 range along the Z-axis
    float pos = (vertex.z + 1.0) / 2.0;
    
    // Create progress-based shine effect
    float shine = smoothstep(progress - shine_width, progress, pos) * 
                (1.0 - smoothstep(progress, progress + shine_width, pos));
    
    // Apply fresnel effect for edge glow
    float fresnel = 1.0 - dot(NORMAL, VIEW);
    
    ALBEDO = shine_color.rgb;
    ALPHA = clamp(fresnel * shine * shine_color.a, 0.0, 1.0);
}