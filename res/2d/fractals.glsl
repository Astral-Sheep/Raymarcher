#version 330 core

const float PI = 3.1415926535f;

const int SIERPINSKI_TRIANGLE = 0;
const int MENGER_CARPET = 1;
const int CANTOR_DUST = 2;
const int KOCH_CURVE = 3;

layout(location = 0) out vec4 color;

in vec2 v_UV;
in float v_AspectRatio;
in float v_SizeFactor;

// -- Default parameters --
uniform vec2 u_CameraPos;
uniform float u_Zoom;
uniform vec2 u_MousePos;
uniform bool u_ShowMouseDistance;

// -- Specific parameters --
uniform float u_Time;
uniform int u_Fractal;
uniform int u_Iterations;
uniform bool u_ShowDistanceField;

vec2 rotate(const vec2 p, const float angle)
{
	float cs = cos(angle);
	float sn = sin(angle);
	return mat2(
		 cs, sn,
		-sn, cs
	) * p;
}

float sdf_square(in vec2 p, const vec2 s)
{
	vec2 d = abs(p) - s;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float sdf_triangle(in vec2 p, const float r)
{
	const float k = sqrt(3.f);
	p.x = abs(p.x) - r;
	p.y = p.y + r / k;

	if (p.x + k * p.y > 0.f)
	{
		p = vec2(p.x - k * p.y, -k * p.x - p.y) * 0.5f;
	}

	p.x -= clamp(p.x, -2.f * r, 0.f);
	return -length(p) * sign(p.y);
}

float sdf_sierpinski_triangle(const vec2 p)
{
	float d = sdf_triangle(p, 1.f);
	const float h = sqrt(3.f) * 0.5f;
	const float h1 = 2.f * h / 3.f;
	float s = 1.f;
	float o = 0.f;

	for (int i = 0; i < u_Iterations; i++)
	{
		vec2 m = vec2(0.5f / s, 1.5f * h1 / s);
		vec2 q = mod(vec2(p.x, p.y + o) + m, m * 2.f) - m;
		float c = sdf_triangle(rotate(vec2(q.x, q.y), PI), 0.5f / s);
		d = max(d, -c);
		o -= h1 / s;
		s *= 2.f;
	}

	return d;
}

float sdf_menger_carpet(const vec2 p)
{
	float d = sdf_square(p, vec2(1.f));
	float s = 1.f;

	for (int i = 0; i < u_Iterations; i++)
	{
		vec2 q = mod(p + vec2(1.f / s), vec2(2.f / s)) - vec2(1.f / s);
		s *= 3.f;
		float c = sdf_square(q, vec2(1.f / s));
		d = max(d, -c);
	}

	return d;
}

float sdf_cantor_dust(const vec2 p)
{
	float d = sdf_square(p, vec2(1.f));
	float s = 1.f;

	for (int i = 0; i < u_Iterations; i++)
	{
		vec2 q = mod(p + vec2(1.f / s), vec2(2.f / s)) - vec2(1.f / s);
		s *= 3.f;
		float c = min(abs(q.x), abs(q.y)) - 1.f / s;
		d = max(d, -c);
	}

	return d;
}

//float sdf_koch_curve(in vec2 p)
//{
	//float r = length(p);
	//float th = mod(
		//atan(p.y, p.x),
		//2.f * PI / 3.f
	//);
	//p = vec2(r * cos(th), r * sin(th));

	//float d = sdf_triangle(p, 1.f);
	//const float h = sqrt(3.f) * 0.5f;

	//for (int i = 0; i < u_Iterations; i++)
	//{
		//float c = sdf_triangle(rotate(p, PI / (3.f * (i + 1.f))), 1.f);
		//d = min(d, c);
	//}

	//return d;
//}

float get_dist(const vec2 p)
{
	switch (u_Fractal)
	{
		case SIERPINSKI_TRIANGLE:
			return sdf_sierpinski_triangle(p);
		case MENGER_CARPET:
			return sdf_menger_carpet(p);
		case CANTOR_DUST:
			return sdf_cantor_dust(p);
		//case KOCH_CURVE:
			//return sdf_koch_curve(p);
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
	float t = u_Time * 0.25f + mix(0.f, 3.f, o);

	return vec3(
		osc(t, -1.f),
		osc(t, 0.f),
		osc(t, 1.f)
	);
}

void main()
{
	vec2 uv = v_UV * 2.f;
	vec2 ro = u_CameraPos + uv;
	float zoom = pow(1.25f, -u_Zoom);

	if (u_ShowMouseDistance)
	{
		vec2 mpos = u_MousePos;
		mpos += vec2(-0.5f, 0.5f);
		mpos.x *= v_AspectRatio;
		mpos *= 4.f * v_SizeFactor; // 2 (default) x 2 (UV multiplier)

		float d = abs(get_dist(u_CameraPos + mpos * zoom));
		float l = length(uv * zoom - mpos * zoom);

		if (l <= 0.02f * zoom)
		{
			color = vec4(1.f);
			return;
		}
		else if (l >= d - 0.005f * zoom && l <= d + 0.005f * zoom)
		{
			color = vec4(get_rainbow(atan(uv.y - mpos.y, uv.x - mpos.x) / (2.f * PI)), 1.f);
			return;
		}
	}

	float d = get_dist(u_CameraPos + uv * zoom);
	vec3 c;

	if (u_ShowDistanceField)
	{
		d *= pow(1.25f, u_Zoom);
		c = d > 0.f ? vec3(1.f) : get_rainbow(uv.x * 0.025f + uv.y * 0.025f);
		c *= 1.f - exp(-25.f * abs(d));
		c *= 0.8f + 0.2f * cos(150.f * d);
		c = mix(c, vec3(1.f), 1.f - smoothstep(0.f, 0.01f, abs(d)));
	}
	else
	{
		c = get_rainbow(uv.x * 0.025f + uv.y * 0.025f) * (1.f - clamp(ceil(d), 0.f, 1.f));
	}

	color = vec4(c, 1.f);
}

