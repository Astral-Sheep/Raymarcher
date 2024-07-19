#version 330 core

const float PI = 3.1415926535f;
const float EPSILON = 0.00002f;

const int UNION = 0;
const int SUBTRACT = 1;
const int INTERSECTION = 2;
const int XOR = 3;
const int SMOOTH_UNION = 4;
const int SMOOTH_SUBTRACT = 5;
const int SMOOTH_INTERSECTION = 6;
const int SMOOTH_XOR = 7;

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
uniform int u_BlendMode;
uniform float u_BlendFactor;
uniform float u_Distance;

float sdf_circle(const vec2 p, const float r)
{
	return length(p) - r;
}

float sdf_square(const vec2 p, const vec2 s)
{
	vec2 d = abs(p) - s;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float op_union(const float d1, const float d2)
{
	return min(d1, d2);
}

float op_sub(const float d1, const float d2)
{
	return max(d1, -d2);
}

float op_intersect(const float d1, const float d2)
{
	return max(d1, d2);
}

float op_xor(const float d1, const float d2)
{
	return op_sub(op_union(d1, d2), op_intersect(d1, d2));
}

float smooth_union(const float d1, const float d2, const float k)
{
	float h = clamp(0.5f + 0.5f * (d2 - d1) / k, 0.f, 1.f);
	return mix(d2, d1, h) - k * h * (1.f - h);
}

float smooth_sub(const float d1, const float d2, const float k)
{
	float h = clamp(0.5f - 0.5f * (d2 + d1) / k, 0.f, 1.f);
	return mix(d1, -d2, h) + k * h * (1.f - h);
}

float smooth_intersect(const float d1, const float d2, const float k)
{
	float h = clamp(0.5f - 0.5f * (d2 - d1) / k, 0.f, 1.f);
	return mix(d2, d1, h) + k * h * (1.f - h);
}

float smooth_xor(const float d1, const float d2, const float k)
{
	return op_sub(smooth_union(d1, d2, k), smooth_intersect(d1, d2, k));
}

float get_dist(const vec2 p)
{
	float c = sdf_circle(p - vec2(-u_Distance, 0.f), 1.f);
	float s = sdf_square(p - vec2(u_Distance, 0.f), vec2(1.f));

	switch (u_BlendMode)
	{
		case UNION:
			return op_union(s, c);
		case SUBTRACT:
			return op_sub(s, c);
		case INTERSECTION:
			return op_intersect(s, c);
		case XOR:
			return op_xor(s, c);
		case SMOOTH_UNION:
			return smooth_union(s, c, u_BlendFactor);
		case SMOOTH_SUBTRACT:
			return smooth_sub(s, c, u_BlendFactor);
		case SMOOTH_INTERSECTION:
			return smooth_intersect(s, c, u_BlendFactor);
		case SMOOTH_XOR:
			return smooth_xor(s, c, u_BlendFactor);
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

