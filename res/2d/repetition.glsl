#version 330 core

const float PI = 3.1415926535f;

const int CIRCLE = 0;
const int SQUARE = 1;

layout(location = 0) out vec4 color;

in vec2 v_UV;
in float v_AspectRatio;

// -- Default parameters --
uniform vec2 u_CameraPos;
uniform float u_Zoom;
uniform vec2 u_MousePos;
uniform bool u_ShowMouseDistance;

// -- Specific parameters --
uniform vec3 u_InColor;
uniform vec3 u_OutColor;
uniform float u_Time;
uniform vec2 u_Mod;
uniform int u_Shape;

float sdf_circle(const vec2 p, const float r)
{
	return length(p) - r;
}

float sdf_square(const vec2 p, const vec2 s)
{
	const vec2 d = abs(p) - s;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

vec2 op_repetition(const vec2 p, const vec2 m)
{
	return mod(p + m * 0.5f, m) - m * 0.5f;
}

float get_dist(in vec2 p)
{
	p = op_repetition(p, u_Mod);

	switch (u_Shape)
	{
		case CIRCLE:
			return sdf_circle(p, 0.5f);
		case SQUARE:
			return sdf_square(p, vec2(0.5f));
		default:
			return 0.f;
	}
}

float osc(const float v, const float o)
{
	return clamp((-abs(mod(v + o, 3.f) - 1.f) + 1.f) * 2.f, 0.f, 1.f);
}

vec3 get_rainbow(const float o)
{
	float t = u_Time * 0.5f + mix(0.f, 3.f, o);

	return vec3(
		osc(t, -1.f),
		osc(t, 0.f),
		osc(t, 1.f)
	);
}

void main()
{
	vec2 uv = v_UV * 2.f;
	vec2 ro = u_CameraPos + uv;
	float zoom = pow(1.25f, -u_Zoom);

	if (u_ShowMouseDistance)
	{
		vec2 mpos = u_MousePos;
		mpos.x -= v_AspectRatio * 0.5f;
		mpos.y += 0.5f;
		mpos *= 4.f; // 2 (default) x 2 (UV multiplier)

		float d = abs(get_dist(u_CameraPos + mpos * zoom));
		float l = length(uv * zoom - mpos * zoom);

		if (l <= 0.02f * zoom)
		{
			color = vec4(1.f);
			return;
		}
		else if (l >= d - 0.0075f * zoom && l <= d + 0.0075f * zoom)
		{
			color = vec4(get_rainbow(atan(uv.y - mpos.y, uv.x - mpos.x) / (2.f * PI)), 1.f);
			return;
		}
	}

	float d = get_dist(u_CameraPos + uv * zoom) * pow(1.25f, u_Zoom);
	vec3 c = d > 0.f ? u_OutColor : u_InColor;
	c *= 1.f - exp(-6.f * abs(d));
	c *= 0.8f + 0.2f * cos(150.f * d);
	c = mix(c, vec3(1.f), 1.f - smoothstep(0.f, 0.01f, abs(d)));

	color = vec4(c, 1.f);
}

