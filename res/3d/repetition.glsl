#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

// -- Default parameters --
uniform vec3 u_CameraPos;
uniform vec2 u_CameraRot;
uniform int u_IterationCount;
uniform float u_MinDistance;
uniform float u_MaxDistance;
uniform bool u_DebugIterations;
uniform vec3 u_LightColor;
uniform int u_LightBounces;

// -- Specific parameters --
uniform vec3 u_Color;
uniform float u_Time;
uniform vec3 u_Mod;
uniform int u_Shape;

const float PI = 3.1415926535f;
const float EPSILON = 0.00002f;

const int SPHERE = 0;
const int BOX = 1;
const int BOX_FRAME = 2;

float sdf_sphere(const vec3 p, const float r)
{
	return length(p) - r;
}

float sdf_box(const vec3 p, const vec3 e)
{
	vec3 q = abs(p) - e;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_boxframe(in vec3 p, const vec3 e, const vec3 w)
{
	p = abs(p) - e;
	vec3 q = abs(p + w) - w;
	return min(min(
		length(max(vec3(p.x, q.y, q.z), vec3(0.f))) + min(max(p.x, max(q.y, q.z)), 0.f),
		length(max(vec3(q.x, p.y, q.z), vec3(0.f))) + min(max(q.x, max(p.y, q.z)), 0.f)),
		length(max(vec3(q.x, q.y, p.z), vec3(0.f))) + min(max(q.x, max(q.y, p.z)), 0.f)
	);
}

vec3 op_repetition(const vec3 p, const vec3 s)
{
	return mod(p + s * 0.5f, s) - s * 0.5f;
}

float get_dist(in vec3 p, const bool repeat)
{
	if (repeat)
	{
		p = op_repetition(p, u_Mod);
	}

	float d = u_MaxDistance;

	switch(u_Shape)
	{
		case SPHERE:
			d = sdf_sphere(p, 1.f);
			break;
		case BOX:
			d = sdf_box(p, vec3(1.f));
			break;
		case BOX_FRAME:
			d = sdf_boxframe(p, vec3(1.f), vec3(0.1f));
			break;
		default:
			break;
	}

	return d;
}

struct RaymarchData
{
	float d;
	float mn;
	vec3 c;
	int it;
};

RaymarchData raymarch(const vec3 ro, const vec3 rd, const bool repeat)
{
	float d = 0.f;
	float mn = u_MaxDistance;
	int i = 0;

	for (; i < u_IterationCount; i++)
	{
		float r = get_dist(ro + rd * d, repeat);
		d += r;
		mn = min(mn, r);

		if (r <= u_MinDistance || d >= u_MaxDistance)
		{
			break;
		}
	}

	return RaymarchData(d, mn, u_Color, i);
}

vec3 get_normal(const vec3 p)
{
	const vec2 e = vec2(EPSILON, 0.f);
	return normalize(get_dist(p, true) - vec3(
		get_dist(p - e.xyy, true),
		get_dist(p - e.yxy, true),
		get_dist(p - e.yyx, true)
	));
}

vec3 get_rainbow()
{
	float t = u_Time * 0.25f;
	return vec3(
		2.f * cos(t),
		2.f * cos(t + 2.f * PI / 3.f),
		2.f * cos(t + 4.f * PI / 3.f)
	);
}

mat2 rot2(const float a)
{
	const float cos = cos(a);
	const float sin = sin(a);
	return mat2(
		cos, -sin,
		sin,  cos
	);
}

void main()
{
	color = vec4(vec3(0.f), 1.f);

	vec3 ro = u_CameraPos;
	vec3 rd = normalize(vec3(v_UV * 0.5f, 1.f));
	rd.yz = rot2(u_CameraRot.x) * rd.yz;
	rd.xz = rot2(u_CameraRot.y) * rd.xz;

	if (u_DebugIterations)
	{
		color = vec4(vec3(raymarch(ro, rd, true).it / (u_IterationCount - 1.f)), 1.f);
		return;
	}

	const vec3 lightDir = normalize(vec3(4.f, 2.f, -6.f));
	vec3 c = vec3(1.f);

	for (int i = 0; i < u_LightBounces; i++)
	{
		RaymarchData data = raymarch(ro, rd, i == 0);
		vec3 p = op_repetition(ro + rd * data.d, u_Mod);
		vec3 n = get_normal(p);

		float diffuse = max(0.f, dot(n, lightDir));
		float specular = pow(clamp(dot(reflect(-lightDir, n), -rd), 0.f, 1.f), 8.f);

		if (data.d < u_MaxDistance && data.mn <= u_MinDistance)
		{
			color.rgb += c * (diffuse + specular) * data.c * u_LightColor;
			c *= data.c * mix(0.2f, 0.65f, 1.f - max(0.f, dot(-rd, n)));
			ro = p + n * (EPSILON * 3.f);
			rd = reflect(rd, n);
		}
		else
		{
			color.rgb += c * exp(1.f - data.mn * 5.f) * get_rainbow() * 0.1f;
			break;
		}
	}
}

