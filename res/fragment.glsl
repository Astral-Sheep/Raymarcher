#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

uniform vec3 u_CameraPos = vec3(0.f, 0.f, -3.f);
uniform vec2 u_CameraRot;
uniform float u_Time;
uniform vec3 u_LightColor = vec3(1.f);

struct Sphere
{
	vec3 pos;
	float radius;
};

struct Box
{
	vec3 pos;
	vec3 extent;
};

struct Torus
{
	vec3 pos;
	float radius;
	float width;
};

const int MAX_IT = 80;
const float MAX_DIST = 75.f;
const float MIN_SURF_DIST = 0.001f;

mat2 rot2(float pAngle)
{
	float cos = cos(pAngle);
	float sin = sin(pAngle);
	return mat2(cos, -sin, sin, cos);
}

// -- Signed distance functions --

float sdf_sphere(Sphere pSphere, vec3 pCameraPos)
{
	return length(pCameraPos - pSphere.pos) - pSphere.radius;
}

float sdf_box(Box pBox, vec3 pCameraPos)
{
	vec3 q = abs(pCameraPos - pBox.pos) - pBox.extent;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_roundbox(Box pBox, float pRadius, vec3 pCameraPos)
{
	vec3 q = abs(pCameraPos - pBox.pos) - pBox.extent + vec3(pRadius);
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f) - pRadius;
}

float sdf_boxframe(Box pBox, float pWidth, vec3 pCameraPos)
{
	vec3 p = abs(pCameraPos - pBox.pos) - pBox.extent;
	vec3 q = abs(p + vec3(pWidth)) - vec3(pWidth);
	return min(min(
		length(max(vec3(p.x, q.y, q.z), 0.f)) + min(max(p.x, max(q.y, q.z)), 0.f),
		length(max(vec3(q.x, p.y, q.z), 0.f)) + min(max(q.x, max(p.y, q.z)), 0.f)),
		length(max(vec3(q.x, q.y, p.z), 0.f)) + min(max(q.x, max(q.y, p.z)), 0.f)
	);
}

float sdf_torus(Torus pTorus, vec3 pCameraPos)
{
	vec3 p = pCameraPos - pTorus.pos;
	vec2 q = vec2(length(p.xz) - pTorus.radius, p.y);
	return length(q) - pTorus.width;
}

float sdf_floor(float pHeight, vec3 pCameraPos)
{
	return pCameraPos.y - pHeight;
}

// -- Operators --

float op_union(float pDist1, float pDist2)
{
	return min(pDist1, pDist2);
}

float op_sub(float pDist1, float pDist2)
{
	return max(-pDist1, pDist2);
}

float op_intersection(float pDist1, float pDist2)
{
	return max(pDist1, pDist2);
}

float op_xor(float pDist1, float pDist2)
{
	return max(min(pDist1, pDist2), -max(pDist1, pDist2));
}

// -- Smooth operators --

float smooth_union(float pDist1, float pDist2, float k)
{
	float h = clamp(0.5f + 0.5f * (pDist2 - pDist1) / k, 0.f, 1.f);
	return mix(pDist2, pDist1, h) - k * h * (1.f - h);
}

float smooth_sub(float pDist1, float pDist2, float k)
{
	float h = clamp(0.5f + 0.5f * (pDist2 + pDist1) / k, 0.f, 1.f);
	return mix(pDist2, -pDist1, h) - k * h * (1.f - h);
}

float smooth_intersection(float pDist1, float pDist2, float k)
{
	float h = clamp(0.5f + 0.5f * (pDist2 - pDist1) / k, 0.f, 1.f);
	return mix(pDist2, pDist1, h) - k * h * (1.f - h);
}

// -- Symmetry & repetition --

vec3 op_repetition(vec3 pPos, vec3 pMod)
{
	return pPos - pMod * round(pPos / pMod);
}

vec3 op_limited_repetition(vec3 pPos, vec3 pMod, vec3 pLimit)
{
	return pPos - pMod * clamp(round(pPos / pMod), -pLimit, pLimit);
}

float get_dist(vec3 pCameraPos)
{
	float m = 4.f;
	vec3 lRepeatedCameraPos = op_repetition(pCameraPos, vec3(4.f));
	return op_union(sdf_floor(-1.f, pCameraPos), sdf_sphere(Sphere(vec3(0.f), 0.5f), lRepeatedCameraPos));
	//return sdf_torus(Torus(vec3(0.f), 1.f, 0.2f), pCameraPos);
}

float raymarch(vec3 pCameraPos, vec3 pDir)
{
	float lDist = 0.f;

	for (int i = 0; i < MAX_IT; i++)
	{
		float lRes = get_dist(pCameraPos + pDir * lDist);
		lDist += lRes;

		if (lRes <= MIN_SURF_DIST || lRes >= 100.f || lDist >= MAX_DIST)
		{
			break;
		}
	}

	return lDist;
}

vec3 get_normal(vec3 pPos)
{
	float d = get_dist(pPos);
	vec2 e = vec2(0.01f, 0.f);

	vec3 n = d - vec3(
		get_dist(pPos - e.xyy),
		get_dist(pPos - e.yxy),
		get_dist(pPos - e.yyx)
	);

	return normalize(n);
}

vec3 get_light(vec3 pPos, vec3 pColor)
{
	vec3 lightPos = vec3(5.f, 5.f, 6.f);

	vec3 l = normalize(lightPos - pPos);
	vec3 n = get_normal(pPos);

	float dif = clamp(dot(n, l), 0.f, 1.f);

	float d = raymarch(pPos + n * MIN_SURF_DIST * 2.f, l);

	// Shadows
	//if (d < length(lightPos - pPos))
	//{
		//dif *= 0.1f;
	//}

	return pColor * dif;
}

void main()
{
	vec3 lRayDir = normalize(vec3(v_UV * 0.5f, 1.f));
	lRayDir.yz *= rot2(-u_CameraRot.x);
	lRayDir.xz *= rot2(-u_CameraRot.y);
	float lDist = raymarch(u_CameraPos, lRayDir);
	vec3 lColor = get_light(u_CameraPos + lRayDir * lDist, u_LightColor);

	if (lDist < MAX_DIST)
	{
		lColor += vec3(0.05f);
	}
	else
	{
		lColor = vec3(0.5f, 0.75f, 1.0f);
	}

	color = vec4(lColor, 1.f);

	//color = vec4(vec3(lDist * 0.025f), 1.f);
}

