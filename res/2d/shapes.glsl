#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

// -- Default parameters --
uniform float u_AspectRatio;
uniform vec2 u_CameraPos;
uniform float u_Zoom;
uniform vec2 u_MousePos;
uniform bool u_ShowMouseDistance;

// -- Specific parameters --
uniform int u_Shape;
uniform vec3 u_InColor;
uniform vec3 u_OutColor;
uniform float u_Time;

const float PI = 3.1415926535f;
const float EPSILON = 0.00002f;

const int CIRCLE = 0;
const int SQUARE = 1;
const int ROUNDED_SQUARE = 2;
const int SEGMENT = 3;
const int RHOMBUS = 4;
const int ISOSCELES_TRAPEZOID = 5;
const int PARALLELOGRAM = 6;
const int EQUILATERAL_TRIANGLE = 7;
const int ISOSCELES_TRIANGLE = 8;

float ndot(const vec2 a, const vec2 b)
{
	return a.x * b.x - a.y * b.y;
}

float sdf_circle(const vec2 p, const float r)
{
	return length(p) - r;
}

float sdf_square(const vec2 p, const vec2 s)
{
	vec2 d = abs(p) - s;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float sdf_rounded_square(const vec2 p, const vec2 s, in vec4 r)
{
	r.xy = p.x > 0.f ? r.xy : r.zw;
	r.x = p.y > 0.f ? r.x : r.y;
	vec2 q = abs(p) - s + r.x;
	return min(max(q.x, q.y), 0.f) + length(max(q, vec2(0.f))) - r.x;
}

float sdf_segment(const vec2 p, const vec2 a, const vec2 b)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.f, 1.f);
	return length(pa - ba * h);
}

float sdf_rhombus(in vec2 p, const vec2 s)
{
	p = abs(p);
	float h = clamp(ndot(s - 2.f * p, s) / dot(s, s), -1.f, 1.f);
	float d = length(p - 0.5f * s * vec2(1.f - h, 1.f + h));
	return d * sign(p.x * s.y + p.y * s.x - s.x * s.y);
}

float get_dist(const vec2 p)
{
	switch (u_Shape)
	{
		case CIRCLE:
			return sdf_circle(p, 1.f);
		case SQUARE:
			return sdf_square(p, vec2(1.f));
		case ROUNDED_SQUARE:
			return sdf_rounded_square(p, vec2(1.f), vec4(0.2f));
		case SEGMENT:
			return sdf_segment(p, vec2(-1.f, 0.f), vec2(1.f, 0.f));
		case RHOMBUS:
			return sdf_rhombus(p, vec2(2.f, 1.f));
		default:
			return length(p);
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

//vec3 get_rainbow(const float o)
//{
	//float t = u_Time * 1.f + mix(0.f, 2.f * PI, o);
	//return vec3(
		//2.f * cos(t),
		//2.f * cos(t + 2.f * PI / 3.f),
		//2.f * cos(t + 4.f * PI / 3.f)
	//);
//}

void main()
{
	vec2 uv = v_UV * 2.f;
	vec2 ro = u_CameraPos + uv;
	float zoom = pow(1.25f, -u_Zoom);

	if (u_ShowMouseDistance)
	{
		vec2 mpos = u_MousePos;
		mpos.x -= u_AspectRatio * 0.5f;
		mpos.y += 0.5f;
		mpos *= 4.f; // 2 (default) x 2 (UV multiplier)

		float d = abs(get_dist(u_CameraPos + mpos * zoom));
		float l = length(uv * zoom - mpos * zoom);

		if (l <= 0.02f)
		{
			color = vec4(1.f);
			return;
		}
		else if (l >= d - 0.0075f && l <= d + 0.0075f)
		{
			color = vec4(get_rainbow(atan(uv.y - mpos.y, uv.x - mpos.x) / (2.f * PI)), 1.f);
			return;
		}
	}

	float d = get_dist(u_CameraPos + uv * zoom);
	vec3 c = d > 0.f ? u_OutColor : u_InColor;
	c *= 1.f - exp(-6.f * abs(d));
	c *= 0.8f + 0.2f * cos(150.f * d);
	c = mix(c, vec3(1.f), 1.f - smoothstep(0.f, 0.01f, abs(d)));

	color = vec4(c, 1.f);
}

