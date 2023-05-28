#version 120

in vec3 position;
in vec3 color;

void main() {
	gl_Position = vec4(position, 1);

	gl_FrontColor.rgb = color;
	gl_FrontColor.a = 1.0f;
}
