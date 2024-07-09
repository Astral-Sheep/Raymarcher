#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

uniform vec3 u_CameraPos;
uniform vec2 u_CameraRot;
uniform vec3 u_Color;
uniform vec3 u_LightColor;
uniform vec3 u_BackgroundColor;
uniform int u_IterationCount = 1;

const float DEG2RAD = 3.1415926535f / 180.f;

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

float sdf_tetrahedron(vec3 p, const float hs)
{
	p.yz = rot2(DEG2RAD * 60.f) * p.yz;
	p.xz = rot2(DEG2RAD * 45.f) * p.xz;
	return (max(
		abs(p.x + p.y) - p.z,
		abs(p.x - p.y) + p.z
	) - 1.f) / sqrt(3.f);
}

vec3 fold(const vec3 p, const vec3 pointOnPlane, const vec3 planeNormal)
{
	float d = dot(p - pointOnPlane, planeNormal);
	d = min(d, 0.f);
	return p - 2.f * d * planeNormal;
}

float get_dist(vec3 p)
{
	//const vec3[] vert = vec3[](
		//vec3(-1.f, -1.f, -1.f),
		//vec3( 1.f, -1.f, -1.f),
		//vec3( 1.f, -1.f,  1.f),
		//vec3( 0.f,  1.f,  0.f)
	//);

	//float scale = 1.f;

	//for (int i = 0; i < u_IterationCount; i++)
	//{
		//p -= vert[3];
		//p *= 2.f;
		//p += vert[3];
		//scale *= 2.f;

		//for (int i = 0; i < 3; i++)
		//{
			//vec3 normal = normalize(vert[3] - vert[i]);
			//p = fold(p, vert[i], normal);
		//}
	//}

	//return sdf_tetrahedron(p, 1.f) / scale;

	float s = 2.f;
	float offset = 3.f;
	int n;

	for (n = 0; n < u_IterationCount; n++)
	{
		if (p.x + p.y < 0.f)
		{
			p.xy = -p.yx;
		}

		if (p.x + p.z < 0.f)
		{
			p.xz = -p.zx;
		}

		if (p.y + p.z < 0.f)
		{
			p.zy = -p.yz;
		}

		p = p * s - offset * (s - 1.f);
	}

	return length(p) * pow(s, -n);
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

