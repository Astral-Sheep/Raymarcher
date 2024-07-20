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
uniform vec3 u_BackgroundColor;
uniform int u_Shape;

const float PI = 3.1415926535f;
const float EPSILON = 0.00002f;

const int SPHERE = 0;
const int BOX = 1;
const int ROUNDED_BOX = 2;
const int BOX_FRAME = 3;
const int TORUS = 4;
const int CAPPED_TORUS = 5;
const int LINK = 6;
const int CYLINDER = 7;
const int HEXAGONAL_PRISM = 8;
const int TRIANGULAR_PRISM = 9;
const int SOLID_ANGLE = 10;
const int CUT_SPHERE = 11;
const int CUT_HOLLOW_SPHERE = 12;
const int ELLIPSOID = 13;
const int OCTAHEDRON = 14;
const int PYRAMID = 15;

float sdf_sphere(const vec3 p, const float r)
{
	return length(p) - r;
}

float sdf_box(const vec3 p, const vec3 e)
{
	vec3 q = abs(p) - e;
	return length(max(q, 0.f)) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_roundbox(const vec3 p, const vec3 e, const float r)
{
	vec3 q = abs(p) - e + r;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f) - r;
}

float sdf_boxframe(in vec3 p, const vec3 e, const float w)
{
	p = abs(p) - e;
	vec3 q = abs(p + vec3(w)) - vec3(w);
	return min(min(
		length(max(vec3(p.x, q.y, q.z), vec3(0.f))) + min(max(p.x, max(q.y, q.z)), 0.f),
		length(max(vec3(q.x, p.y, q.z), vec3(0.f))) + min(max(q.x, max(p.y, q.z)), 0.f)),
		length(max(vec3(q.x, q.y, p.z), vec3(0.f))) + min(max(q.x, max(q.y, p.z)), 0.f)
	);
}

float sdf_torus(const vec3 p, const vec2 t)
{
	vec2 q = vec2(length(p.xz) - t.x, p.y);
	return length(q) - t.y;
}

// TODO: // 5
//float sdf_cappedtorus(const CappedTorus pCappedTorus)
//{
	//vec3 p = pCappedTorus.pos;
	//p.x = abs(p.x);
	//float k =
//}

float sdf_link(const vec3 p, const float le, const float r1, const float r2)
{
	vec3 q = vec3(p.x, max(abs(p.y) - le, 0.f), p.z);
	return length(vec2(length(q.xy) - r1, q.z)) - r2;
}

float sdf_hexagonalprism(in vec3 p, const vec2 h)
{
	const vec3 k = vec3(-0.8660254f, 0.5f, 0.57735f);
	p = abs(p);
	p.xy -= 2.f * min(dot(k.xy, p.xy), 0.f) * k.xy;
	vec2 d = vec2(
		length(p.xy - vec2(clamp(p.x, -k.z * h.x, k.z * h.x), h.x)) * sign(p.y - h.x),
		p.z - h.y
	);
	return min(max(d.x, d.y), 0.f) + length(max(d, 0.f));
}

float sdf_triangularprism(const vec3 p, const vec2 h)
{
	vec3 q = abs(p);
	return max(q.z - h.y, max(q.x * 0.866025f + p.y * 0.5f, -p.y) - h.x * 0.5f);
}

float sdf_solidangle(const vec3 p, const vec2 c, const float ra)
{
	vec2 q = vec2(length(p.xz), p.y);
	float l = length(q) - ra;
	float m = length(q - c * clamp(dot(q, c), 0.f, ra));
	return max(l, m * sign(c.y * q.x - c.x * q.y));
}

float sdf_cutsphere(const vec3 p, const float r, const float h)
{
	float w = sqrt(r * r - h * h);
	vec2 q = vec2(length(p.xz), p.y);
	float s = max((h - r) * q.x * q.x + w * w * (h + r - 2.f * q.y), h * q.x - w * q.y);
	return (s < 0.f) ? length(q) - r :
	       (q.x < w) ? h - q.y       :
	                   length(q - vec2(w, h));
}

float sdf_cuthollowsphere(const vec3 p, const float r, const float h, const float t)
{
	float w = sqrt(r * r - h * h);
	vec2 q = vec2(length(p.xz), p.y);
	return (h * q.x < w * q.y ? length(q - vec2(w, h)) : abs(length(q) - r)) - t;
}

float sdf_ellipsoid(const vec3 p, const vec3 r)
{
	float k0 = length(p / r);
	float k1 = length(p / (r * r));
	return k0 * (k0 - 1.f) / k1;
}

float sdf_octahedron(in vec3 p, const float s)
{
	p = abs(p);
	float m = p.x + p.y + p.z - s;
	vec3 q;

	if (3.f * p.x < m)
	{
		q = p.xyz;
	}
	else if (3.f * p.y < m)
	{
		q = p.yzx;
	}
	else if (3.f * p.z < m)
	{
		q = p.zxy;
	}
	else
	{
		return m * 0.57735027f;
	}

	float k = clamp(0.5f * (q.z - q.y + s), 0.f, s);
	return length(vec3(q.x, q.y - s + k, q.z - k));
}

float sdf_pyramid(in vec3 p, const float h)
{
	float m2 = h * h + 0.25f;

	p.xz = abs(p.xz);
	p.xz = p.z > p.x ? p.zx : p.xz;
	p.xz -= 0.5f;

	vec3 q = vec3(p.z, h * p.y - 0.5f * p.x, h * p.x + 0.5f * p.y);

	float s = max(-q.x, 0.f);
	float t = clamp((q.y - 0.5f * p.z) / (m2 + 0.25f), 0.f, 1.f);

	float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
	float b = m2 * (q.x + 0.5f * t) * (q.x + 0.5f * t) + (q.y - m2 * t) * (q.y - m2 * t);

	float d2 = min(q.t, -q.x * m2 - q.y * 0.5f) > 0.f ? 0.f : min(a, b);
	return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
}

vec4 op_union(const vec4 pLhs, const vec4 pRhs)
{
	float res = min(pLhs.w, pRhs.w);
	return vec4(res == pLhs.w ? pLhs.rgb : pRhs.rgb, res);
}

vec4 get_dist(const vec3 p)
{
	vec4 r = vec4(vec3(1.f), u_MaxDistance);

	switch (u_Shape)
	{
		case SPHERE:
			r = vec4(vec3(0.f, 0.5f, 1.f), sdf_sphere(p, 1.f));
			break;
		case BOX:
			r = vec4(vec3(0.25f, 1.f, 0.f), sdf_box(p, vec3(1.f)));
			break;
		case ROUNDED_BOX:
			r = vec4(vec3(0.25f, 1.f, 0.f), sdf_roundbox(p, vec3(1.f), 0.25f));
			break;
		case BOX_FRAME:
			r = vec4(vec3(1.f, 0.5f, 0.f), sdf_boxframe(p, vec3(1.f), 0.1f));
			break;
		case TORUS:
			r = vec4(vec3(1.f, 0.f, 0.5f), sdf_torus(p, vec2(1.f, 0.25f)));
			break;
		case CAPPED_TORUS:
			break;
		case LINK:
			r = vec4(vec3(1.f, 0.f, 0.f), sdf_link(p, 0.5f, 0.5f, 0.2f));
			break;
		case HEXAGONAL_PRISM:
			r = vec4(vec3(0.5f, 0.f, 1.f), sdf_hexagonalprism(p, vec2(1.f, 0.25f)));
			break;
		case TRIANGULAR_PRISM:
			r = vec4(vec3(1.f, 0.f, 0.f), sdf_triangularprism(p, vec2(1.f, 0.25f)));
			break;
		//case SOLID_ANGLE:
			//shape = vec4(vec3(0.f, 1.f, 0.f), sdf_solidangle(SolidAngle(p, vec2(tan(PI * 0.5f)), 1.f)));
			//break;
		case CUT_SPHERE:
			r = vec4(vec3(0.f, 1.f, 0.f), sdf_cutsphere(p, 1.f, 0.25f));
			break;
		case CUT_HOLLOW_SPHERE:
			r = vec4(vec3(0.f, 0.f, 1.f), sdf_cuthollowsphere(p, 1.f, 0.f, 0.1f));
			break;
		case ELLIPSOID:
			r = vec4(vec3(0.5f, 1.f, 0.f), sdf_ellipsoid(p, vec3(1.f, 0.5f, 0.25f)));
			break;
		case OCTAHEDRON:
			r = vec4(vec3(1.f, 1.f, 0.f), sdf_octahedron(p, 1.f));
			break;
		case PYRAMID:
			r = vec4(vec3(0.f, 1.f, 1.f), sdf_pyramid(p, 1.f));
			break;
		default:
			break;
	}

	return op_union(
		vec4(vec3(0.75f), sdf_box(p - vec3(0.f, -2.f, 0.f), vec3(5.f, 0.5f, 5.f))),
		r
	);
}

struct RaymarchData
{
	float d;
	float mn;
	vec3 c;
	int it;
};

RaymarchData raymarch(const vec3 ro, const vec3 rd)
{
	vec3 c = vec3(0.f);
	float d = 0.f;
	float mn = u_MaxDistance;
	int i = 0;

	for (; i < u_IterationCount; i++)
	{
		vec4 r = get_dist(ro + rd * d);
		c = r.rgb;
		d += r.w;
		mn = min(mn, r.w);

		if (r.w <= u_MinDistance || d >= u_MaxDistance)
		{
			break;
		}
	}

	return RaymarchData(d, mn, c, i);
}

vec3 get_normal(const vec3 p)
{
	const vec2 e = vec2(EPSILON, 0.f);
	return normalize(get_dist(p).w - vec3(
		get_dist(p - e.xyy).w,
		get_dist(p - e.yxy).w,
		get_dist(p - e.yyx).w
	));
}

vec3 get_light(const vec3 p, const vec3 c)
{
	vec3 lightDir = normalize(vec3(4.f, 5.f, -6.f));
	vec3 normal = get_normal(p);
	float dif = clamp(dot(normal, lightDir), 0.f, 1.f);
	float distance = raymarch(p + normal * u_MinDistance * 2.f, lightDir).d;

	if (distance < u_MaxDistance)
	{
		dif *= 0.1f;
	}

	return c * dif;
}

mat2 rot2(const float pAngle)
{
	float cs = cos(pAngle);
	float sn = sin(pAngle);
	return mat2(
		cs, -sn,
		sn,  cs
	);
}

void main()
{
	vec3 ro = u_CameraPos;
	vec3 rd = normalize(vec3(v_UV * 0.5f, 1.f));
	rd.yz *= rot2(-u_CameraRot.x);
	rd.xz *= rot2(-u_CameraRot.y);

	if (u_DebugIterations)
	{
		color = vec4(vec3(raymarch(ro, rd).it / (u_IterationCount - 1.f)), 1.f);
		return;
	}

	RaymarchData data = raymarch(ro, rd);

	if (data.d < u_MaxDistance)
	{
		vec3 c = data.c * get_light(u_CameraPos + rd * data.d, u_LightColor);
		c += data.c * vec3(0.15f);
		color = vec4(c, 1.f);
	}
	else
	{
		color = vec4(u_BackgroundColor, 1.f);
	}
}

