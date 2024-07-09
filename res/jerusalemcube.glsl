#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

uniform vec3 u_CameraPos;
uniform vec2 u_CameraRot;
uniform vec3 u_Color;
uniform vec3 u_LightColor;
uniform vec3 u_BackgroundColor;
uniform int u_IterationCount;

const int MAX_IT = 80;
const float MAX_DIST = 75.f;
const float MIN_SURF_DIST = 0.001f;

mat2 rot2(const float a)
{
	float cos = cos(a);
	float sin = sin(a);
	return mat2(
		cos, -sin,
		sin,  cos
	);
}

vec3 get_raydir()
{
	vec3 raydir = normalize(vec3(v_UV * 0.5f, 1.f));
	raydir.yz *= rot2(-u_CameraRot.x);
	raydir.xz *= rot2(-u_CameraRot.y);
	return raydir;
}

float sdf_box(const vec3 p, const vec3 e)
{
	vec3 q = abs(p) - e;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_box2(const vec2 p, const vec2 e)
{
	vec2 d = abs(p) - e;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float sdf_cross(const vec3 p, const float s)
{
	return min(
		min(
			min(
				sdf_box2(p.xy, vec2(CROSS_LENGTH, CROSS_WIDTH) * s),
				sdf_box2(p.xy, vec2(CROSS_WIDTH, CROSS_LENGTH) * s)
			),
			min(
				sdf_box2(p.zy, vec2(CROSS_LENGTH, CROSS_WIDTH) * s),
				sdf_box2(p.zy, vec2(CROSS_WIDTH, CROSS_LENGTH) * s)
			)
		),
		min(
			sdf_box2(p.xz, vec2(CROSS_LENGTH, CROSS_WIDTH) * s),
			sdf_box2(p.xz, vec2(CROSS_WIDTH, CROSS_LENGTH) * s)
		)
	);
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

float get_dist(vec3 p)
{
	//const float SIZE = 1.f;
	//float c = MAX_DIST;
	//float o = 0.f;

	//for (int i = 0; i < u_IterationCount; i++)
	//{
		//float scale = pow(CROSS_SIDE, i);
		//float modulus = SIZE * pow(CROSS_SIDE, i - 1) * CROSS_LENGTH;

		//vec3 q = p + vec3(SIZE * o);
		//q -= vec3(2.f * modulus) * clamp(
			//round(q / vec3(2.f * modulus)),
			//vec3(-SIZE / scale),
			//vec3(SIZE / scale)
		//);
		//o += scale * CROSS_LENGTH;

		//c = op_union(c, sdf_cross(q, SIZE * scale));
	//}

	//return op_sub(sdf_box(p, vec3(SIZE)), c);

	const float vB = 0.4f;
	const float vA = 1.f - 2.f * vB;
	float s = 1.f;
	p *= 0.5f;

	for (int i = 0; i < u_IterationCount; i++)
	{
		p = abs(p);

		if (p.x < p.z)
		{
			p.xz = p.zx;
		}

		if (p.y < p.z)
		{
			p.yz = p.zy;
		}

		if (p.x < p.y)
		{
			p.xy = p.yx;
		}

		if (p.z > 0.5f * vA || p.z > p.y + 3.f / 2.f * vA - 0.5f)
		{
			p -= vec3(0.5f - 0.5f * vB);
			p *= 1.f / vB;
			s *= vB;
		}
		else
		{
			p -= vec3(vec2(0.5f - 0.5f * vA), 0.f);
			p *= 1.f / vA;
			s *= vA;
		}
	}

	return sdf_box(p, vec3(0.5f)) * s;
}

float raymarch(const vec3 p, const vec3 dir)
{
	float d = 0.f;

	for (int i = 0; i < MAX_IT; i++)
	{
		float r = get_dist(p + dir * d);
		d += r;

		if (r <= MIN_SURF_DIST || r >= 100.f || d >= MAX_DIST)
		{
			break;
		}
	}

	return d;
}

vec3 get_normal(const vec3 pPos)
{
	float d = get_dist(pPos);
	vec2 e = vec2(0.0005f, 0.f);

	return normalize(d - vec3(
		get_dist(pPos - e.xyy),
		get_dist(pPos - e.yxy),
		get_dist(pPos - e.yyx)
	));
}

vec3 get_light(const vec3 pPos, const vec3 pColor)
{
	vec3 lLightDir = normalize(vec3(4.f, 5.f, -6.f));
	vec3 lNormal = get_normal(pPos);
	float lDif = clamp(dot(lNormal, lLightDir), 0.f, 1.f);
	float lDistance = raymarch(pPos + lNormal * MIN_SURF_DIST * 2.f, lLightDir);

	if (lDistance < MAX_DIST)
	{
		lDif *= 0.1f;
	}

	return pColor * lDif;
}

void main()
{
	vec3 raydir = get_raydir();
	float d = raymarch(u_CameraPos, raydir);
	vec3 c = u_BackgroundColor;

	if (d < MAX_DIST)
	{
		c = u_Color * get_light(u_CameraPos + raydir * d, u_LightColor);
		c += u_Color * vec3(0.15f);
	}

	color = vec4(c, 1.f);
}

