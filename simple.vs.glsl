#version 120

in vec3 position;
in vec3 color;

void main() {
	gl_Position = vec4(position, 1);

	gl_FrontColor = vec4(color, 1);
}
