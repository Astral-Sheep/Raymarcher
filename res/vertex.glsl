#version 330 core

const ivec2 DEFAULT_SCREEN_SIZE = ivec2(1280, 720);

layout(location = 0) in vec4 position;

out vec2 v_UV;
out float v_AspectRatio;
out float v_SizeFactor;

uniform ivec2 u_ScreenSize = DEFAULT_SCREEN_SIZE;

void main()
{
	v_SizeFactor = max(float(u_ScreenSize.x) / DEFAULT_SCREEN_SIZE.x, float(u_ScreenSize.y) / DEFAULT_SCREEN_SIZE.y);
	gl_Position = position;
	v_AspectRatio = float(u_ScreenSize.x) / float(u_ScreenSize.y);
	v_UV = position.xy * v_SizeFactor;
	v_UV.x *= v_AspectRatio;
}

