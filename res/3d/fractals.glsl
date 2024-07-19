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

// -- Specific parameters --
uniform float u_Time;
uniform int u_Fractal;
uniform int u_FractalIterationCount;
uniform vec3 u_Color;
uniform int u_LightBounces;

const float PI = 3.1415926535f;
const float EPSILON = 0.00005f;

const int MENGER_SPONGE = 0;
const int JERUSALEM_CUBE = 1;
const int CANTOR_DUST = 2;

struct RaymarchData
{
	float d;
	float mn;
	vec3 c;
	int it;
};

mat2 rot2(const float a)
{
	float cos = cos(a);
	float sin = sin(a);
	return mat2(
		cos, -sin,
		sin,  cos
	);
}

float sdf_sphere(const vec3 p, const float r)
{
	return length(p) - r;
}

float sdf_box(const vec3 p, const vec3 e)
{
	vec3 q = abs(p) - e;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

float sdf_box2(const vec2 p, const vec2 e)
{
	vec2 q = abs(p) - e;
	return length(max(q, 0.f)) + min(max(q.x, q.y), 0.f);
}

float sdf_infinitecross(const vec3 p, const vec3 e)
{
	return min(
		sdf_box2(p.xy, e.xy),
		min(sdf_box2(p.xz, e.xz), sdf_box2(p.yz, e.yz))
	);
}

float sdf_mengersponge(const vec3 p, const vec3 e)
{
	float d = sdf_box(p, e);
	float s = 1.f;

	for (int i = 0; i < u_FractalIterationCount; i++)
	{
		vec3 q = mod(p + vec3(e / s), vec3(2.f * e / s)) - vec3(e / s);
		float c = sdf_infinitecross(q, vec3(e / (s * 3.f)));
		d = max(d, -c);
		s *= 3.f;
	}

	return d;
}

float sdf_jerusalemcube(in vec3 p, const vec3 e)
{
	// I found this algorithm on the internet and was too lazy to optimize it, but it's so heavy it crashes when we get too close
	const float vB = 0.4f;
	const float vA = 1.f - 2.f * vB;
	float s = 1.f;
	p *= 0.5f;

	for (int i = 0; i < u_FractalIterationCount; i++)
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
			p *= e / vB;
			s *= vB;
		}
		else
		{
			p -= vec3(vec2(0.5f - 0.5f * vA), 0.f);
			p *= e / vA;
			s *= vA;
		}
	}

	return sdf_box(p, vec3(0.5f)) * s;
}

float sdf_infinite_cantor_cross(const vec3 p, const vec3 s)
{
	return min(min(
		abs(p.x) - s.x,
		abs(p.y) - s.y),
		abs(p.z) - s.z
	);
}

float sdf_cantor_dust(in vec3 p, const vec3 s)
{
	float d = sdf_box(p, s);
	float n = 1.f;

	for (int i = 0; i < u_FractalIterationCount; i++)
	{
		vec3 q = mod(p + s / n, 2.f * s / n) - s / n;
		d = max(d, -sdf_infinite_cantor_cross(q, s / (n * 3.f)));
		n *= 3.f;
	}

	return d;
}

//float sdf_sierpinskitetrahedron(in vec3 p, const float s)
//{
	//float o = 3.f;
	//float r;
	//int n = 0;

	//while (n < u_IterationCount)
	//{
		//if (p.x + p.y < 0.f)
		//{
			//p.xy = -p.yx;
		//}

		//if (p.x + p.z < 0.f)
		//{
			//p.xz = -p.zx;
		//}

		//if (p.y + p.z < 0.f)
		//{
			//p.zy = -p.yz;
		//}

		//p = p * s - vec3(o) * (s - 1.f);
		//n++;
	//}

	//return length(p) * pow(s, -n);
//}

//float sdf_kochcurve(in vec3 p)
//{
	//const float C1 = 1.73205081f;
	//const float C2 = 1.15470053839f;

	//const float cos = cos(PI / 3.f);
	//const float sin = sin(PI / 3.f);
	//const mat2 rot60 = mat2(
		//cos, -sin,
		//sin,  cos
	//);
	//const mat2 rotm60 = mat2(
		// cos, sin,
		//-sin, cos
	//);

	//float s = 1.f;

	//for (int i = 0; i < u_IterationCount; i++)
	//{
		//const float x1 = 2.f / 3.f;
		//s *= x1;
		//p /= x1;

		//if (abs(p.z) > -p.x * C1)
		//{
			//p.x *= -1.f;
			//p.xz = (p.z > 0 ? rotm60 : rot60) * p.xz;
		//}

		//p.zy = p.yz;
		//p.x++;
	//}

	//if (abs(p.z) > p.x * C1)
	//{
		//p.x *= -1.f;
		//p.xz = (p.z > 0 ? rot60 : rotm60) * p.xz;
	//}

	//float d = abs(p.y) + C2 * p.x - C2;
	//d *= 1.f / sqrt(1.f + C2 * C2) * s;
	//return d;
//}

vec4 get_dist(const vec3 p)
{
	float d = u_MaxDistance;

	switch (u_Fractal)
	{
		case MENGER_SPONGE:
			d = sdf_mengersponge(p, vec3(1.f));
			break;
		case JERUSALEM_CUBE:
			d = sdf_jerusalemcube(p, vec3(1.f));
			break;
		case CANTOR_DUST:
			d = sdf_cantor_dust(p, vec3(1.f));
			break;
		default:
			break;
	}

	return vec4(u_Color, d);
}

vec3 get_normal(const vec3 p)
{
	const vec2 e = vec2(EPSILON, 0.f);
	return vec3(get_dist(p).w) - vec3(
		get_dist(p - e.xyy).w,
		get_dist(p - e.yxy).w,
		get_dist(p - e.yyx).w
	) / EPSILON;
}

float softshadow(const vec3 p, const vec3 dir, float mint, float maxt, float k)
{
	float r = 1.f;
	float ph = 1e20;

	for (float t = mint; t < maxt;)
	{
		float h = get_dist(p + dir * t).w;

		if (h < u_MinDistance)
		{
			return 0.f;
		}

		float y = h * h / (2.f * ph);
		float d = sqrt(h * h - y * y);
		r = min(r, k * d / max(0.f, t - y));
		ph = h;
		t += h;
	}

	return r;
}

RaymarchData raymarch(const vec3 p, const vec3 dir)
{
	float d = 0.f;
	float mn = u_MaxDistance;
	vec3 c = vec3(0.f);
	int i = 0;

	for (; i < u_IterationCount; i++)
	{
		vec4 r = get_dist(p + dir * d);
		d += r.w;
		c = r.rgb;
		mn = min(mn, r.w);

		if (r.w <= u_MinDistance || d >= u_MaxDistance)
		{
			break;
		}
	}

	return RaymarchData(d, mn, c, i);
}

float osc(const float v, const float o)
{
	return clamp((-abs(mod(v + o, 3.f) - 1.f) + 1.f) * 2.f, 0.f, 1.f);
}

vec3 get_rainbow()
{
	float t = u_Time * 0.25f;

	return vec3(
		osc(t, -1.f),
		osc(t, 0.f),
		osc(t, 1.f)
	);
}

void main()
{
	color = vec4(vec3(0.f), 1.f);

	vec3 rayorigin = u_CameraPos;
	vec3 raydir = normalize(vec3(v_UV * 0.5f, 1.f));
	raydir.yz = rot2(u_CameraRot.x) * raydir.yz;
	raydir.xz = rot2(u_CameraRot.y) * raydir.xz;

	if (u_DebugIterations)
	{
		color = vec4(vec3(raymarch(rayorigin, raydir).it / (u_IterationCount - 1.f)), 1.f);
		return;
	}

	const vec3 lightDir = normalize(vec3(4.f, 2.f, -6.f));
	vec3 c = vec3(1.f);

	for (int i = 0; i < u_LightBounces; i++)
	{
		RaymarchData data = raymarch(rayorigin, raydir);
		vec3 p = rayorigin + raydir * data.d;
		vec3 n = get_normal(p);
		float shad = softshadow(p + (u_MinDistance * 3.f) * n, lightDir, 0.f, 50.f, 6.f);

		float diffuse = max(0.f, dot(n, lightDir));
		float specular = pow(clamp(dot(reflect(-lightDir, n), -raydir), 0.f, 1.f), 8.f);

		if (data.d < u_MaxDistance && data.mn <= u_MinDistance)
		{
			color.rgb += c * (diffuse + specular) * data.c * u_LightColor * shad;
			c *= data.c * mix(0.2f, 0.65f, 1.f - max(0.f, dot(-raydir, n)));
			rayorigin = p + n * (EPSILON * 3.f);
			raydir = reflect(raydir, n);
		}
		else
		{
			color.rgb += c * exp(1.f - data.mn * 50.f) * get_rainbow() * 0.1f;
			break;
		}
	}
}

