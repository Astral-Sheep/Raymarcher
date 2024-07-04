#version 330 core

layout(location = 0) out vec4 color;

in vec2 v_UV;

uniform vec3 u_CameraPos = vec3(0.f, 0.f, -3.f);
uniform vec2 u_CameraRot;

struct Sphere
{
	vec3 pos;
	float radius;
};

float sdf_sphere(Sphere pSphere, vec3 pCameraPos)
{
	return length(pCameraPos - pSphere.pos) - pSphere.radius;
}

float map(vec3 pCameraPos)
{
	return sdf_sphere(Sphere(vec3(0.f), 1.f), pCameraPos);
}

void main()
{
	vec3 lCameraPos = vec3(0.f, 0.f, -3.f);
	vec3 lRayDir = normalize(vec3(v_UV, 1.f));
	float lDist = 0.f;
	int i = 0;

	for (i = 0; i < 80; i++)
	{
		float lRes = map(u_CameraPos + lRayDir * lDist);
		lDist += lRes;

		if (lRes <= 0.001f || lRes >= 100.f || lDist >= 500.f)
		{
			break;
		}
	}

	color = vec4(vec3(lDist * 0.2f), 1.f);
	//color = vec4(vec3(i / 80.f), 1.f);
	//color = vec4(1.f, 0.f, 0.5f, 1.f);
	//color = vec4(v_UV, 0.f, 1.f);
}

