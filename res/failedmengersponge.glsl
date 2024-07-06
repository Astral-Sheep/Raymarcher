#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

uniform vec3 u_CameraPos;
uniform vec2 u_CameraRot;
uniform float u_Time;
uniform vec3 u_Color;
uniform vec3 u_LightColor;
uniform vec3 u_BackgroundColor;
uniform int u_IterationCount = 1;

const int MAX_IT = 80;
const float MAX_DIST = 75.f;
const float MIN_SURF_DIST = 0.001f;

struct Box
{
	vec3 pos;
	vec3 extent;
};

struct Box2
{
	vec2 pos;
	vec2 extent;
};

mat2 rot2(const float pAngle)
{
	float cos = cos(pAngle);
	float sin = sin(pAngle);
	return mat2(
		cos, -sin,
		sin, cos
	);
}

vec3 get_ray_dir()
{
	vec3 lRayDir = normalize(vec3(v_UV * 0.5f, 1.f));
	lRayDir.yz *= rot2(-u_CameraRot.x);
	lRayDir.xz *= rot2(-u_CameraRot.y);
	return lRayDir;
}

float sdf_box(const Box pBox, const vec3 pCameraPos)
{
	vec3 q = abs(pCameraPos - pBox.pos) - pBox.extent;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_box2(Box2 pBox, const vec2 pCameraPos)
{
	pBox.pos = pCameraPos - pBox.pos;
	vec2 d = abs(pBox.pos) - pBox.extent;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float sdf_infinite_cross(Box pBox, const vec3 pCameraPos)
{
	pBox.pos = pCameraPos - pBox.pos;
	float da = sdf_box2(
		Box2(pBox.pos.xy, pBox.extent.xy),
		vec2(0.f)
	);
	float db = sdf_box2(
		Box2(pBox.pos.yz, pBox.extent.yz),
		vec2(0.f)
	);
	float dc = sdf_box2(
		Box2(pBox.pos.zx, pBox.extent.zx),
		vec2(0.f)
	);
	return min(da, min(db, dc));
}

float op_union(const float pDist1, const float pDist2)
{
	return min(pDist1, pDist2);
}

float op_sub(const float pDist1, const float pDist2)
{
	return max(pDist1, -pDist2);
}

float op_intersection(const float pDist1, const float pDist2)
{
	return max(pDist1, pDist2);
}

float get_dist(const vec3 pPos)
{
	float d = sdf_box(Box(vec3(0.f), vec3(1.f)), pPos);
	float s = 1.f;

	for (int i = 0; i < u_IterationCount; i++)
	{
		vec3 p = pPos - (1.f / s) * round(pPos * s);
		float c = sdf_infinite_cross(Box(vec3(0.f), vec3(1.f / (s * 3.f))), p);
		d = op_sub(d, c);
		s *= 3.f;

		//vec3 a = mod(pPos * s, vec3(2.f)) - vec3(1.f);
		//s *= 3.f;
		//vec3 r = vec3(1.f) - 3.f * abs(a);

		//float c = sdf_infinite_cross(Box(r, vec3(1.f)), pPos) / s;
		//d = max(d, c);
	}

	return d;
	//return op_sub(sdf_box(Box(vec3(0.f), vec3(3.f)), pPos), sdf_infinite_cross(Box(vec3(0.f), vec3(1.f)), pPos));
}

float raymarch(const vec3 pPos, const vec3 pDir)
{
	float lDist = 0.f;

	for (int i = 0; i < MAX_IT; i++)
	{
		float lRes = get_dist(pPos + pDir * lDist);
		lDist += lRes;

		if (lRes <= MIN_SURF_DIST || lRes >= 100.f || lDist >= MAX_DIST)
		{
			break;
		}
	}

	return lDist;
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
	vec3 lLightDir = normalize(vec3(5.f, 5.f, 6.f));
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
	vec3 lRayDir = get_ray_dir();
	float lDist = raymarch(u_CameraPos, lRayDir);
	vec3 lColor = u_Color * get_light(u_CameraPos + lRayDir * lDist, u_LightColor);

	if (lDist < MAX_DIST)
	{
		lColor += u_Color * vec3(0.1f);
	}
	else
	{
		lColor = u_BackgroundColor;
	}

	color = vec4(lColor, 1.f);
}

