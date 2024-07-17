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

struct RoundBox
{
	Box box;
	float radius;
};

struct BoxFrame
{
	Box box;
	float width;
};

struct Torus
{
	vec3 pos;
	float outer_radius;
	float inner_radius;
};

struct CappedTorus
{
	Torus torus;
	float min_angle;
	float max_angle;
};

struct Link
{
	vec3 pos;
	float outer_radius;
	float inner_radius;
	float length;
};

struct Cylinder
{
	vec3 pos;
	float radius;
	float length;
};

struct Cone
{
	vec3 pos;
	vec2 c;
	float height;
};

struct Plane
{
	vec3 pos;
	vec3 normal;
	float height;
};

struct HexagonalPrism
{
	vec3 pos;
	vec2 height;
};

struct TriangularPrism
{
	vec3 pos;
	vec2 height;
};

struct SolidAngle
{
	vec3 pos;
	vec2 c;
	float ra;
};

struct CutSphere
{
	vec3 pos;
	float radius;
	float height;
};

struct CutHollowSphere
{
	vec3 pos;
	float radius;
	float height;
	float t;
};

struct Ellipsoid
{
	vec3 pos;
	vec3 radius;
};

struct Octahedron
{
	vec3 pos;
	float size;
};

struct Pyramid
{
	vec3 pos;
	float height;
};

// 0
float sdf_sphere(const Sphere pSphere)
{
	return length(pSphere.pos) - pSphere.radius;
}

// 1
float sdf_box(const Box pBox)
{
	vec3 q = abs(pBox.pos) - pBox.extent;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f);
}

// 2
float sdf_roundbox(const RoundBox pRoundBox)
{
	vec3 q = abs(pRoundBox.box.pos) - pRoundBox.box.extent + pRoundBox.radius;
	return length(max(q, vec3(0.f))) + min(max(q.x, max(q.y, q.z)), 0.f) - pRoundBox.radius;
}

// 3
float sdf_boxframe(const BoxFrame pBoxFrame)
{
	vec3 p = abs(pBoxFrame.box.pos) - pBoxFrame.box.extent;
	vec3 q = abs(p + vec3(pBoxFrame.width)) - vec3(pBoxFrame.width);
	return min(min(
		length(max(vec3(p.x, q.y, q.z), vec3(0.f))) + min(max(p.x, max(q.y, q.z)), 0.f),
		length(max(vec3(q.x, p.y, q.z), vec3(0.f))) + min(max(q.x, max(p.y, q.z)), 0.f)),
		length(max(vec3(q.x, q.y, p.z), vec3(0.f))) + min(max(q.x, max(q.y, p.z)), 0.f)
	);
}

// 4
float sdf_torus(const Torus pTorus)
{
	vec2 q = vec2(length(pTorus.pos.xz) - pTorus.outer_radius, pTorus.pos.y);
	return length(q) - pTorus.inner_radius;
}

// TODO: // 5
//float sdf_cappedtorus(const CappedTorus pCappedTorus)
//{
	//vec3 p = pCappedTorus.pos;
	//p.x = abs(p.x);
	//float k =
//}

// 6
float sdf_link(const Link pLink)
{
	vec3 q = vec3(pLink.pos.x, max(abs(pLink.pos.y) - pLink.length, 0.f), pLink.pos.z);
	return length(vec2(length(q.xy) - pLink.outer_radius, q.z)) - pLink.inner_radius;
}

// 8
float sdf_hexagonalprism(const HexagonalPrism pPrism)
{
	const vec3 k = vec3(-0.8660254f, 0.5f, 0.57735f);
	vec3 p = abs(pPrism.pos);
	p.xy -= 2.f * min(dot(k.xy, p.xy), 0.f) * k.xy;
	vec2 d = vec2(
		length(p.xy - vec2(clamp(p.x, -k.z * pPrism.height.x, k.z * pPrism.height.x), pPrism.height.x)) * sign(p.y - pPrism.height.x),
		p.z - pPrism.height.y
	);
	return min(max(d.x, d.y), 0.f) + length(max(d, 0.f));
}

// 9
float sdf_triangularprism(const TriangularPrism pPrism)
{
	vec3 q = abs(pPrism.pos);
	return max(q.z - pPrism.height.y, max(q.x * 0.866025f + pPrism.pos.y * 0.5f, -pPrism.pos.y) - pPrism.height.x * 0.5f);
}

// 10
float sdf_solidangle(const SolidAngle pSolidAngle)
{
	vec2 q = vec2(length(pSolidAngle.pos.xz), pSolidAngle.pos.y);
	float l = length(q) - pSolidAngle.ra;
	float m = length(q - pSolidAngle.c * clamp(dot(q, pSolidAngle.c), 0.f, pSolidAngle.ra));
	return max(l, m * sign(pSolidAngle.c.y * q.x - pSolidAngle.c.x * q.y));
}

// 11
float sdf_cutsphere(const CutSphere pSphere)
{
	float w = sqrt(pSphere.radius * pSphere.radius - pSphere.height * pSphere.height);
	vec2 q = vec2(length(pSphere.pos.xz), pSphere.pos.y);
	float s = max((pSphere.height - pSphere.radius) * q.x * q.x + w * w * (pSphere.height + pSphere.radius - 2.f * q.y), pSphere.height * q.x - w * q.y);
	return	(s < 0.f) ? length(q) - pSphere.radius	:
			(q.x < w) ? pSphere.height - q.y		:
						length(q - vec2(w, pSphere.height));
}

// 12
float sdf_cuthollowsphere(const CutHollowSphere pSphere)
{
	float w = sqrt(pSphere.radius * pSphere.radius - pSphere.height * pSphere.height);
	vec2 q = vec2(length(pSphere.pos.xz), pSphere.pos.y);
	return ((pSphere.height * q.x < w * q.y) ?	length(q - vec2(w, pSphere.height)) :
												abs(length(q) - pSphere.radius)
	) - pSphere.t;
}

// 13
float sdf_ellipsoid(const Ellipsoid pEllipsoid)
{
	float k0 = length(pEllipsoid.pos / pEllipsoid.radius);
	float k1 = length(pEllipsoid.pos / (pEllipsoid.radius * pEllipsoid.radius));
	return k0 * (k0 - 1.f) / k1;
}

// 14
float sdf_octahedron(const Octahedron pOctahedron)
{
	vec3 p = abs(pOctahedron.pos);
	float m = p.x + p.y + p.z - pOctahedron.size;
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

	float k = clamp(0.5f * (q.z - q.y + pOctahedron.size), 0.f, pOctahedron.size);
	return length(vec3(q.x, q.y - pOctahedron.size + k, q.z - k));
}

// 15
float sdf_pyramid(const Pyramid pPyramid)
{
	float m2 = pPyramid.height * pPyramid.height + 0.25f;

	vec3 p = pPyramid.pos;
	p.xz = abs(p.xz);
	p.xz = (p.z > p.x) ? p.zx : p.xz;
	p.xz -= 0.5f;

	vec3 q = vec3(p.z, pPyramid.height * p.y - 0.5f * p.x, pPyramid.height * p.x + 0.5f * p.y);

	float s = max(-q.x, 0.f);
	float t = clamp((q.y - 0.5f * p.z) / (m2 + 0.25f), 0.f, 1.f);

	float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
	float b = m2 * (q.x + 0.5f * t) * (q.x + 0.5f * t) + (q.y - m2 * t) * (q.y - m2 * t);

	float d2 = min(q.y, -q.x * m2 - q.y * 0.5f) > 0.f ? 0.f : min(a, b);

	return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
}

vec4 op_union(const vec4 pLhs, const vec4 pRhs)
{
	float res = min(pLhs.w, pRhs.w);
	return vec4(res == pLhs.w ? pLhs.rgb : pRhs.rgb, res);
}

vec4 get_dist(const vec3 p)
{
	vec4 shape = vec4(vec3(1.f), u_MaxDistance);

	switch (u_Shape)
	{
		case SPHERE:
			shape = vec4(vec3(0.f, 0.5f, 1.f), sdf_sphere(Sphere(p, 1.f)));
			break;
		case BOX:
			shape = vec4(vec3(0.25f, 1.f, 0.f), sdf_box(Box(p, vec3(1.f))));
			break;
		case ROUNDED_BOX:
			shape = vec4(vec3(0.25f, 1.f, 0.f), sdf_roundbox(RoundBox(Box(p, vec3(1.f)), 0.25f)));
			break;
		case BOX_FRAME:
			shape = vec4(vec3(1.f, 0.5f, 0.f), sdf_boxframe(BoxFrame(Box(p, vec3(1.f)), 0.1f)));
			break;
		case TORUS:
			shape = vec4(vec3(1.f, 0.f, 0.5f), sdf_torus(Torus(p, 1.f, 0.25f)));
			break;
		case CAPPED_TORUS:
			break;
		case LINK:
			shape = vec4(vec3(1.f, 0.f, 0.f), sdf_link(Link(p, 0.5f, 0.2f, 0.5f)));
			break;
		case HEXAGONAL_PRISM:
			shape = vec4(vec3(0.5f, 0.f, 1.f), sdf_hexagonalprism(HexagonalPrism(p, vec2(1.f, 0.25f))));
			break;
		case TRIANGULAR_PRISM:
			shape = vec4(vec3(1.f, 0.f, 0.f), sdf_triangularprism(TriangularPrism(p, vec2(1.f, 0.25f))));
			break;
		//case SOLID_ANGLE:
			//shape = vec4(vec3(0.f, 1.f, 0.f), sdf_solidangle(SolidAngle(p, vec2(tan(PI * 0.5f)), 1.f)));
			//break;
		case CUT_SPHERE:
			shape = vec4(vec3(0.f, 1.f, 0.f), sdf_cutsphere(CutSphere(p, 1.f, 0.25f)));
			break;
		case CUT_HOLLOW_SPHERE:
			shape = vec4(vec3(0.f, 0.f, 1.f), sdf_cuthollowsphere(CutHollowSphere(p, 1.f, 0.f, 0.1f)));
			break;
		case ELLIPSOID:
			shape = vec4(vec3(0.5f, 1.f, 0.f), sdf_ellipsoid(Ellipsoid(p, vec3(1.f, 0.5f, 0.25f))));
			break;
		case OCTAHEDRON:
			shape = vec4(vec3(1.f, 1.f, 0.f), sdf_octahedron(Octahedron(p, 1.f)));
			break;
		case PYRAMID:
			shape = vec4(vec3(0.f, 1.f, 1.f), sdf_pyramid(Pyramid(p, 1.f)));
			break;
		default:
			break;
	}

	return op_union(
		vec4(vec3(0.75f), sdf_box(Box(p - vec3(0.f, -2.f, 0.f), vec3(5.f, 0.5f, 5.f)))),
		shape
	);
}

struct RaymarchData
{
	float d;
	float mn;
	vec3 c;
	int it;
};

RaymarchData raymarch(const vec3 p, const vec3 dir)
{
	vec3 c = vec3(0.f);
	float d = 0.f;
	float mn = u_MaxDistance;
	int i = 0;

	for (; i < u_IterationCount; i++)
	{
		vec4 r = get_dist(p + dir * d);
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

vec3 get_light(const vec3 pPos, const vec3 pColor)
{
	vec3 lightDir = normalize(vec3(4.f, 5.f, -6.f));
	vec3 normal = get_normal(pPos);
	float dif = clamp(dot(normal, lightDir), 0.f, 1.f);
	float distance = raymarch(pPos + normal * u_MinDistance * 2.f, lightDir).d;

	if (distance < u_MaxDistance)
	{
		dif *= 0.1f;
	}

	return pColor * dif;
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
		vec3 lColor = data.c * get_light(u_CameraPos + rd * data.d, u_LightColor);
		lColor += data.c * vec3(0.15f);
		color = vec4(lColor, 1.f);
	}
	else
	{
		color = vec4(u_BackgroundColor, 1.f);
	}
}

