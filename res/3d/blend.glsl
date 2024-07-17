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

uniform vec3 u_BackgroundColor;
uniform int u_BlendMode;
uniform float u_BlendFactor;
uniform float u_Distance;

const int UNION = 0;
const int SUBTRACT = 1;
const int INTERSECTION = 2;
const int XOR = 3;
const int SMOOTH_UNION = 4;
const int SMOOTH_SUBTRACT = 5;
const int SMOOTH_INTERSECTION = 6;
const int SMOOTH_XOR = 7;

const int MAX_IT = 80;
const float MAX_DIST = 75.f;
const float MIN_SURF_DIST = 0.001f;

float sdf_sphere(const vec3 p, const float r)
{
	return length(p) - r;
}

float sdf_box(const vec3 p, const vec3 e)
{
	const vec3 q = abs(p) - e;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
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
	return max(min(d1, d2), -max(d1, d2));
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

float get_dist(const vec3 pCameraPos)
{
	float d = u_MaxDistance;
	float s = sdf_sphere(pCameraPos - vec3(0.f, u_Distance + 0.5f, 0.f), 1.f);
	float b = sdf_box(pCameraPos - vec3(0.f, 0.f, 0.f), vec3(1.f));

	switch(u_BlendMode)
	{
		case UNION:
			d = op_union(b, s);
			break;
		case SUBTRACT:
			d = op_sub(b, s);
			break;
		case INTERSECTION:
			d = op_intersect(b, s);
			break;
		case XOR:
			d = op_xor(b, s);
			break;
		case SMOOTH_UNION:
			d = smooth_union(b, s, u_BlendFactor);
			break;
		case SMOOTH_SUBTRACT:
			d = smooth_sub(b, s, u_BlendFactor);
			break;
		case SMOOTH_INTERSECTION:
			d = smooth_intersect(b, s, u_BlendFactor);
			break;
		case SMOOTH_XOR:
			d = smooth_union(b, s, u_BlendFactor);
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

RaymarchData raymarch(const vec3 pCameraPos, const vec3 pRayDir)
{
	float d = 0.f;
	float mn = u_MaxDistance;
	int i = 0;

	for (; i < u_IterationCount; i++)
	{
		float r = get_dist(pCameraPos + pRayDir * d);
		d += r;
		mn = min(mn, r);

		if (r <= u_MinDistance || d >= u_MaxDistance)
		{
			break;
		}
	}

	return RaymarchData(d, mn, vec3(0.75f), i);
}

vec3 get_normal(const vec3 p)
{
	float d = get_dist(p);
	vec2 e = vec2(0.0005f, 0.f);
	return normalize(d - vec3(
		get_dist(p - e.xyy),
		get_dist(p - e.yxy),
		get_dist(p - e.yyx)
	));
}

vec3 get_light(const vec3 p, const vec3 c)
{
	vec3 lightDir = normalize(vec3(4.f, 5.f, -6.f));
	vec3 n = get_normal(p);
	float dif = clamp(dot(n, lightDir), 0.f, 1.f);
	float d = raymarch(p + n * u_MinDistance * 2.f, lightDir).d;

	if (d < u_MaxDistance)
	{
		dif *= 0.1f;
	}

	return c * dif;
}

mat2 rot2(const float pAngle)
{
	float cos = cos(pAngle);
	float sin = sin(pAngle);
	return mat2(
		cos, -sin,
		sin, cos
	);
}

void main()
{
	vec3 rd = normalize(vec3(v_UV, 1.f));
	rd.yz = rot2(u_CameraRot.x) * rd.yz;
	rd.xz = rot2(u_CameraRot.y) * rd.xz;

	if (u_DebugIterations)
	{
		color = vec4(vec3(raymarch(u_CameraPos, rd).it / (u_IterationCount - 1.f)), 1.f);
		return;
	}

	RaymarchData data = raymarch(u_CameraPos, rd);

	if (data.d < u_MaxDistance)
	{
		vec3 lColor = data.c * get_light(u_CameraPos + rd * data.d, u_LightColor);
		lColor += data.c * vec3(0.15f);
		color = vec4(lColor, 1.f);
	}
	else
	{
		color = vec4(u_BackgroundColor * u_LightColor, 1.f);
	}
}

