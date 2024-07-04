#version 330 core

layout(location = 0) in vec4 position;

out vec2 v_UV;

uniform float u_AspectRatio = 1.f;

void main()
{
	gl_Position = position;
	v_UV = position.xy;
	v_UV.x *= u_AspectRatio;
}

