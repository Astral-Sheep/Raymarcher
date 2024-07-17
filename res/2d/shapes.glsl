#version 330 core

const float PI = 3.1415926535f;
const float EPSILON = 0.00002f;

const int CIRCLE = 0;
const int SQUARE = 1;
const int ROUNDED_SQUARE = 2;
const int SEGMENT = 3;
const int RHOMBUS = 4;
const int ISOSCELES_TRAPEZOID = 5;
const int PARALLELOGRAM = 6;
const int EQUILATERAL_TRIANGLE = 7;
const int ISOSCELES_TRIANGLE = 8;
const int TRIANGLE = 9;
const int UNEVEN_CAPSULE = 10;
const int REGULAR_PENTAGON = 11;
const int REGULAR_HEXAGON = 12;
const int REGULAR_OCTOGON = 13;
const int HEXAGRAM = 14;
const int STAR5 = 15;
const int REGULAR_STAR = 16;
const int PIE = 17;
const int CUT_DISK = 18;
const int ARC = 19;
const int RING = 20;
const int HORSESHOE = 21;
const int VESICA = 22;
const int MOON = 23;
const int CIRCLE_CROSS = 24;
const int SIMPLE_EGG = 25;
const int HEART = 26;
const int CROSS = 27;
const int ROUNDEDX = 28;
const int ELLIPSE = 29;
const int PARABOLA = 30;
const int PARABOLA_SEGMENT = 31;
const int QUADRATIC_BEZIER = 32;
const int BOBBLY_CROSS = 33;
const int TUNNEL = 34;
const int STAIRS = 35;
const int QUADRATIC_CIRCLE = 36;
const int HYPERBOLA = 37;
const int CIRCLE_WAVE = 38;

layout(location = 0) out vec4 color;

in vec2 v_UV;

// -- Default parameters --
uniform float u_AspectRatio;
uniform vec2 u_CameraPos;
uniform float u_Zoom;
uniform vec2 u_MousePos;
uniform bool u_ShowMouseDistance;

// -- Specific parameters --
uniform int u_Shape;
uniform vec3 u_InColor;
uniform vec3 u_OutColor;
uniform float u_Time;

// -- Shapes parameters --
// Circle
uniform float u_CircleRadius;
// Square
uniform vec2 u_SquareExtent;
// Rounded Square
uniform vec4 u_SquareRadius;
// Segment
uniform vec2 u_Segment[2];
// Rhombus
uniform vec2 u_RhombusSize;
// Isosceles trapezoid
uniform float u_IsoscelesTrapezoidR0;
uniform float u_IsoscelesTrapezoidR1;
uniform float u_IsoscelesTrapezoidHeight;
// Parallelogram
uniform float u_ParallelogramWidth;
uniform float u_ParallelogramHeight;
uniform float u_ParallelogramSkew;
// Equilateral triangle
uniform float u_EquilateralTriangleRadius;
// Isosceles triangle
uniform float u_IsoscelesTriangleBase;
uniform float u_IsoscelesTriangleHeight;
// Triangle
uniform vec2 u_Triangle[3];
// Uneven capsule
uniform float u_UnevenCapsuleTopRadius;
uniform float u_UnevenCapsuleBotRadius;
uniform float u_UnevenCapsuleHeight;
// Regular pentagon
uniform float u_RegularPentagonRadius;
// Regular hexagon
uniform float u_RegularHexagonRadius;
// Regular octogon
uniform float u_RegularOctogonRadius;
// Hexagram
uniform float u_HexagramRadius;
// Star 5
uniform float u_Star5Radius;
uniform float u_Star5Angle;
// Regular star
uniform float u_RegularStarRadius;
uniform int u_RegularStarBranches;
uniform float u_RegularStarInnerRadius;
// Pie
uniform float u_PieRadius;
uniform float u_PieAngle;
// Cut disk
uniform float u_CutDiskRadius;
uniform float u_CutDiskHeight;
// Arc
uniform float u_ArcAngle;
uniform float u_ArcRadius;
uniform float u_ArcWidth;
// Ring
uniform float u_RingAngle = PI * 0.6f;
uniform float u_RingRadius;
uniform float u_RingWidth;
// Horseshoe
uniform float u_HorseshoeAngle;
uniform float u_HorseshoeRadius;
uniform float u_HorseshoeWidth;
// Vesica
uniform float u_VesicaRadius;
uniform float u_VesicaWidth;
// Moon
uniform float u_MoonRadius;
uniform float u_MoonInnerRadius;
uniform float u_MoonInnerCenter;
// Circle cross
uniform float u_CircleCrossRadius;
// Simple egg
uniform float u_SimpleEggMinRadius;
uniform float u_SimpleEggMaxRadius;
// Cross
uniform float u_CrossOuterSize;
uniform float u_CrossInnerRadius;
uniform float u_CrossOuterRadius;
// Rounded x
uniform float u_RoundedxLength;
uniform float u_RoundedxRadius;
// Ellipse
uniform vec2 u_EllipseSize;
// Parabola
uniform float u_ParabolaDirection;
// Parabola segment
uniform float u_ParabolaWidth;
uniform float u_ParabolaHeight;
// Quadratic bezier
uniform vec2 u_QuadraticBezier[3];
// Bobbly cross
uniform float u_BobblyCrossRadius;
// Tunnel
uniform vec2 u_TunnelSize;
// Stairs
uniform vec2 u_StairsStepSize;
uniform float u_StairsStepCount;
// Hyperbola
uniform float u_HyperbolaMidSpace;
uniform float u_HyperbolaExtent;
// Circle wave
uniform float u_CircleWaveAngle;
uniform float u_CircleWaveRadius;

float dot2(const vec2 v)
{
	return v.x * v.x + v.y * v.y;
}

float ndot(const vec2 a, const vec2 b)
{
	return a.x * b.x - a.y * b.y;
}

float sdf_circle(const vec2 p, const float r)
{
	return length(p) - r;
}

float sdf_square(const vec2 p, const vec2 s)
{
	const vec2 d = abs(p) - s;
	return length(max(d, 0.f)) + min(max(d.x, d.y), 0.f);
}

float sdf_rounded_square(const vec2 p, const vec2 s, in vec4 r)
{
	r.xy = p.x > 0.f ? r.xy : r.zw;
	r.x = p.y > 0.f ? r.x : r.y;
	vec2 q = abs(p) - s + r.x;
	return min(max(q.x, q.y), 0.f) + length(max(q, vec2(0.f))) - r.x;
}

float sdf_segment(const vec2 p, const vec2 a, const vec2 b)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.f, 1.f);
	return length(pa - ba * h);
}

float sdf_rhombus(in vec2 p, const vec2 s)
{
	p = abs(p);
	float h = clamp(ndot(s - 2.f * p, s) / dot(s, s), -1.f, 1.f);
	float d = length(p - 0.5f * s * vec2(1.f - h, 1.f + h));
	return d * sign(p.x * s.y + p.y * s.x - s.x * s.y);
}

float sdf_isosceles_trapezoid(in vec2 p, const float r1, const float r2, const float he)
{
	vec2 k1 = vec2(r2, he);
	vec2 k2 = vec2(r2 - r1, 2.f * he);
	p.x = abs(p.x);
	vec2 ca = vec2(
		p.x - min(p.x, (p.y < 0.f ? r1 : r2)),
		abs(p.y) - he
	);
	vec2 cb = p - k1 + k2 * clamp(dot(k1 - p, k2) / dot(k2, k2), 0.f, 1.f);
	float s = (cb.x < 0.f && ca.y < 0.f) ? -1.f : 1.f;
	return s * sqrt(min(dot(ca, ca), dot(cb, cb)));
}

float sdf_parallelogram(in vec2 p, const float wi, const float he, const float sk)
{
	vec2 e = vec2(sk, he);
	p = (p.y < 0.f) ? -p : p;
	vec2 w = p - e;
	w.x -= clamp(w.x, -wi, wi);
	vec2 d = vec2(dot(w, w), -w.y);
	float s = p.x * e.y - p.y * e.x;
	p = s < 0.f ? -p : p;
	vec2 v = p - vec2(wi, 0.f);
	v -= e * clamp(dot(v, e) / dot(e, e), -1.f, 1.f);
	d = min(d, vec2(dot(v, v), wi * he - abs(s)));
	return sqrt(d.x) * sign(-d.y);
}

float sdf_equilateral_triangle(in vec2 p, const float r)
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

float sdf_isosceles_triangle(in vec2 p, const vec2 q)
{
	p.x = abs(p.x);
	vec2 a = p - q * clamp(dot(p, q) / dot(q, q), 0.f, 1.f);
	vec2 b = p - q * vec2(clamp(p.x / q.x, 0.f, 1.f), 1.f);
	float s = -sign(q.y);
	vec2 d = min(
		vec2(dot(a, a), s * (p.x * q.y - p.y * q.x)),
		vec2(dot(b, b), s * (p.y - q.y))
	);
	return -sqrt(d.x) * sign(d.y);
}

float sdf_triangle(const vec2 p, const vec2 p0, const vec2 p1, const vec2 p2)
{
	vec2 e0 = p1 - p0;
	vec2 e1 = p2 - p1;
	vec2 e2 = p0 - p2;
	vec2 v0 = p - p0;
	vec2 v1 = p - p1;
	vec2 v2 = p - p2;
	vec2 pq0 = v0 - e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.f, 1.f);
	vec2 pq1 = v1 - e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.f, 1.f);
	vec2 pq2 = v2 - e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.f, 1.f);
	float s = sign(e0.x * e2.y - e0.y * e2.x);
	vec2 d = min(min(
		vec2(dot(pq0, pq0), s * (v0.x * e0.y - v0.y * e0.x)),
		vec2(dot(pq1, pq1), s * (v1.x * e1.y - v1.y * e1.x))),
		vec2(dot(pq2, pq2), s * (v2.x * e2.y - v2.y * e2.x))
	);
	return -sqrt(d.x) * sign(d.y);
}

float sdf_uneven_capsule(in vec2 p, const float r1, const float r2, const float h)
{
	p.x = abs(p.x);
	float b = (r1 - r2) / h;
	float a = sqrt(1.f - b * b);
	float k = dot(p, vec2(-b, a));

	if (k < 0.f)
	{
		return length(p) - r1;
	}

	if (k > a * h)
	{
		return length(p - vec2(0.f, h)) - r2;
	}

	return dot(p, vec2(a, b)) - r1;
}

float sdf_regular_pentagon(in vec2 p, const float r)
{
	const vec3 k = vec3(0.809016994f, 0.587785252f, 0.726542528f);
	p.x = abs(p.x);
	p -= 2.f * min(dot(vec2(-k.x, k.y), p), 0.f) * vec2(-k.x, k.y);
	p -= 2.f * min(dot(vec2(k.x, k.y), p), 0.f) * vec2(k.x, k.y);
	p -= vec2(clamp(p.x, -r * k.z, r * k.z), r);
	return length(p) * sign(p.y);
}

float sdf_regular_hexagon(in vec2 p, const float r)
{
	const vec3 k = vec3(-0.866025404f, 0.5f, 0.577350269f);
	p = abs(p);
	p -= 2.f * min(dot(k.xy, p), 0.f) * k.xy;
	p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
	return length(p) * sign(p.y);
}

float sdf_regular_octogon(in vec2 p, const float r)
{
	const vec3 k = vec3(-0.9238795325f, 0.3826834323f, 0.4142135623f);
	p = abs(p);
	p -= 2.f * min(dot(vec2(k.x, k.y), p), 0.f) * vec2(k.x, k.y);
	p -= 2.f * min(dot(vec2(-k.x, k.y), p), 0.f) * vec2(-k.x, k.y);
	p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
	return length(p) * sign(p.y);
}

float sdf_hexagram(in vec2 p, const float r)
{
	const vec4 k = vec4(-0.5f, 0.8660254038f, 0.5773502692f, 1.7320508076f);
	p = abs(p);
	p -= 2.f * min(dot(k.xy, p), 0.f) * k.xy;
	p -= 2.f * min(dot(k.yx, p), 0.f) * k.yx;
	p -= vec2(clamp(p.x, r * k.z, r * k.w), r);
	return length(p) * sign(p.y);
}

float sdf_star5(in vec2 p, const float r, const float rf)
{
	const vec2 k1 = vec2(0.809016994375f, -0.587785252292f);
	const vec2 k2 = vec2(-k1.x, k1.y);
	p.x = abs(p.x);
	p -= 2.f * max(dot(k1, p), 0.f) * k1;
	p -= 2.f * max(dot(k2, p), 0.f) * k2;
	p.x = abs(p.x);
	p.y -= r;
	vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.f, 1.f);
	float h = clamp(dot(p, ba) / dot(ba, ba), 0.f, r);
	return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

float sdf_regular_star(in vec2 p, const float r, const int n, const float m)
{
	float an = PI / n;
	float en = PI / m;
	vec2 acs = vec2(cos(an), sin(an));
	vec2 ecs = vec2(cos(en), sin(en));

	float bn = mod(atan(p.x, p.y), 2.f * an) - an;
	p = length(p) * vec2(cos(bn), abs(sin(bn)));
	p -= r * acs;
	p += ecs * clamp(-dot(p, ecs), 0.f, r * acs.y / ecs.y);
	return length(p) * sign(p.x);
}

float sdf_pie(in vec2 p, const vec2 c, const float r)
{
	p.x = abs(p.x);
	float l = length(p) - r;
	float m = length(p - c * clamp(dot(p, c), 0.f, r));
	return max(l, m * sign(c.y * p.x - c.x * p.y));
}

float sdf_cut_disk(in vec2 p, const float r, const float h)
{
	float w = sqrt(r * r - h * h);
	p.x = abs(p.x);
	float s = max((h - r) * p.x * p.x + w * w * (h + r - 2.f * p.y), h * p.x - w * p.y);
	return	s < 0.f ?	length(p) - r :
			p.x < w ?	h - p.y :
						length(p - vec2(w, h));
}

float sdf_arc(in vec2 p, const vec2 sc, const float ra, const float rb)
{
	p.x = abs(p.x);
	return ((sc.y * p.x > sc.x * p.y) ? length(p - sc * ra) : abs(length(p) - ra)) - rb;
}

float sdf_ring(in vec2 p, const vec2 n, const float r, const float th)
{
	p.x = abs(p.x);
	p = mat2(n.x, n.y, -n.y, n.x) * p;
	return max(
		abs(length(p) - r) - th * 0.5f,
		length(vec2(p.x, max(0.f, abs(r - p.y) - th * 0.5f))) * sign(p.x)
	);
}

float sdf_horseshoe(in vec2 p, const vec2 c, const float r, const float w)
{
	p.x = abs(p.x);
	float l = length(p);
	p = mat2(-c.x, c.y, c.y, c.x) * p;
	p = vec2(
		p.y > 0.f || p.x > 0.f ? p.x : l * sign(-c.x),
		p.x > 0.f ? p.y : l
	);
	p = vec2(p.x, abs(p.y - r)) - w;
	return length(max(p, 0.f)) + min(0.f, max(p.x, p.y));
}

float sdf_vesica(in vec2 p, const float r, const float d)
{
	p = abs(p);
	float b = sqrt(r * r - d * d);
	return (p.y - b) * d > p.x * b ? length(p - vec2(0.f, b)) : length(p - vec2(-d, 0.f)) - r;
}

float sdf_moon(in vec2 p, const float d, const float ra, const float rb)
{
	p.y = abs(p.y);
	float a = (ra * ra - rb * rb + d * d) / (2.f * d);
	float b = sqrt(max(ra * ra - a * a, 0.f));

	if (d * (p.x * b - p.y * a) > d * d * max(b - p.y, 0.f))
	{
		return length(p - vec2(a, b));
	}

	return max(length(p) - ra, -(length(p - vec2(d, 0.f)) - rb));
}

float sdf_circle_cross(in vec2 p, const float h)
{
	float k = 0.5f * (h + 1.f / h);
	p = abs(p);
	return	(p.x < 1.f && p.y < p.x * (k - h) + h) ?
			k - sqrt(dot2(p - vec2(1.f, k))) :
			sqrt(min(dot2(p - vec2(0.f, h)), dot2(p - vec2(1.f, 0.f))));
}

float sdf_simple_egg(in vec2 p, const float ra, const float rb)
{
	const float k = sqrt(3.f);
	p.x = abs(p.x);
	float r = ra - rb;
	return ((p.y < 0.f)				? length(vec2(p.x, p.y)) - r :
			(k * (p.x + r) < p.y)	? length(vec2(p.x, p.y - k * r)) :
									  length(vec2(p.x + r, p.y)) - 2.f * r) - rb;
}

float sdf_heart(in vec2 p)
{
	p.x = abs(p.x);

	if (p.y + p.x > 1.f)
	{
		return sqrt(dot2(p - vec2(0.25f, 0.75f))) - sqrt(2.f) / 4.f;
	}

	return sqrt(min(dot2(p - vec2(0.f, 1.f)), dot2(p - 0.5f * max(p.x + p.y, 0.f)))) * sign(p.x - p.y);
}

float sdf_cross(in vec2 p, const vec2 b, const float r)
{
	p = abs(p);
	p = p.y > p.x ? p.yx : p.xy;
	vec2 q = p - b;
	float k = max(q.y, q.x);
	vec2 w = k > 0.f ? q : vec2(b.y - p.x, -k);
	return sign(k) * length(max(w, 0.f)) + r;
}

float sdf_roundedx(in vec2 p, const float w, const float r)
{
	p = abs(p);
	return length(p - min(p.x + p.y, w) * 0.5f) - r;
}

float sdf_ellipse(in vec2 p, in vec2 ab)
{
	p = abs(p);

	if (p.x > p.y)
	{
		p = p.yx;
		ab = ab.yx;
	}

	float l = ab.y * ab.y - ab.x * ab.x;
	float m = ab.x * p.x / l;
	float m2 = m * m;
	float n = ab.y * p.y / l;
	float n2 = n * n;
	float c = (m2 + n2 - 1.f) / 3.f;
	float c3 = c * c * c;
	float q = c3 + m2 * n2 * 2.f;
	float d = c3 + m2 * n2;
	float g = m + m * n2;
	float co;

	if (d < 0.f)
	{
		float h = acos(q / c3) / 3.f;
		float s = cos(h);
		float t = sin(h) * sqrt(3.f);
		float rx = sqrt(-c * (s + t + 2.f) + m2);
		float ry = sqrt(-c * (s - t + 2.f) + m2);
		co = (ry + sign(l) * rx + abs(g) / (rx * ry) - m) * 0.5f;
	}
	else
	{
		float h = 2.f * m * n * sqrt(d);
		float s = sign(q + h) * pow(abs(q + h), 1.f / 3.f);
		float u = sign(q - h) * pow(abs(q - h), 1.f / 3.f);
		float rx = -s - u - c * 4.f + 2.f * m2;
		float ry = (s - u) * sqrt(3.f);
		float rm = sqrt(rx * rx + ry * ry);
		co = (ry / sqrt(rm - rx) + 2.f * g / rm - m) * 0.5f;
	}

	vec2 r = ab * vec2(co, sqrt(1.f - co * co));
	return length(r - p) * sign(p.y - r.y);
}

float sdf_parabola(in vec2 pos, const float k)
{
	pos.x = abs(pos.x);
	float ik = 1.f / k;
	float p = ik * (pos.y - 0.5f * ik) / 3.f;
	float q = 0.25f * ik * ik * pos.x;
	float h = q * q - p * p * p;
	float r = sqrt(abs(h));
	float x = h > 0.f ?
		pow(q + r, 1.f / 3.f) - pow(abs(q - r), 1.f / 3.f) * sign(r - q):
		2.f * cos(atan(r, q) / 3.f) * sqrt(p);
	return length(pos - vec2(x, k * x * x)) * sign(pos.x - x);
}

float sdf_parabola_segment(in vec2 P, const float wi, const float he)
{
	P.x = abs(P.x);
	float ik = wi * wi / he;
	float p = ik * (he - P.y - 0.5f * ik) / 3.f;
	float q = P.x * ik * ik * 0.25f;
	float h = q * q - p * p * p;
	float r = sqrt(abs(h));
	float x = h > 0.f ?
		pow(q + r, 1.f / 3.f) - pow(abs(q - r), 1.f / 3.f) * sign(r - q) :
		2.f * cos(atan(r / q) / 3.f) * sqrt(p);
	x = min(x, wi);
	return length(P - vec2(x, he - x * x / ik)) * sign(ik * (P.y - he) + P.x * P.x);
}

float sdf_quadratic_bezier(const vec2 P, const vec2 A, const vec2 B, const vec2 C)
{
	vec2 a = B - A;
	vec2 b = A - 2.f * B + C;
	vec2 c = a * 2.f;
	vec2 d = A - P;
	float kk = 1.f / dot(b, b);
	float kx = kk * dot(a, b);
	float ky = kk * (2.f * dot(a, a) + dot(d, b)) / 3.f;
	float kz = kk * dot(d, a);
	float res = 0.f;
	float p = ky - kx * kx;
	float p3 = p * p * p;
	float q = kx * (2.f * kx * kx - 3.f * ky) + kz;
	float h = q * q + 4.f * p3;

	if (h >= 0.f)
	{
		h = sqrt(h);
		vec2 x = (vec2(h, -h) - q) * 0.5f;
		vec2 uv = sign(x) * pow(abs(x), vec2(1.f / 3.f));
		float t = clamp(uv.x + uv.y - kx, 0.f, 1.f);
		res = dot2(d + (c + b * t) * t);
	}
	else
	{
		float z = sqrt(-p);
		float v = acos(q / (p * z * 2.f)) / 3.f;
		float m = cos(v);
		float n = sin(v) * 1.732050808f;
		vec3 t = clamp(vec3(m + m, -n - m, n - m) * z - kx, 0.f, 1.f);
		res = min(
			dot2(d + (c + b * t.x) * t.x),
			dot2(d + (c + b * t.y) * t.y)
		);
	}

	return sqrt(res);
}

float sdf_bobbly_cross(in vec2 P, const float he)
{
	P = abs(P);
	P = vec2(abs(P.x - P.y), 1.f - P.x - P.y) / sqrt(2.f);

	float p = (he - P.y - 0.25f / he) / (6.f * he);
	float q = P.x / (he * he * 16.f);
	float h = q * q - p * p * p;

	float x;

	if (h > 0.f)
	{
		float r = sqrt(h);
		x = pow(q + r, 1.f / 3.f) - pow(abs(q - r), 1.f / 3.f) * sign(r - q);
	}
	else
	{
		float r = sqrt(p);
		x = 2.f * r * cos(acos(q / (p * r)) / 3.f);
	}

	x = min(x, sqrt(2.f) * 0.5f);
	vec2 z = vec2(x, he * (1.f - 2.f * x * x)) - P;
	return length(z) * sign(z.y) - 0.4f;
}

float sdf_tunnel(in vec2 p, const vec2 wh)
{
	p.x = abs(p.x);
	p.y = -p.y;
	vec2 q = p - wh;
	q.x = p.y > 0.f ? q.x : length(p) - wh.x;
	float d = sqrt(min(
		dot2(vec2(max(q.x, 0.f), q.y)),
		dot2(vec2(q.x, max(q.y, 0.f)))
	));
	return max(q.x, q.y) < 0.f ? -d : d;
}

float sdf_stairs(in vec2 p, const vec2 wh, const float n)
{
	vec2 ba = wh * n;
	float d = min(
		dot2(p - vec2(clamp(p.x, 0.f, ba.x), 0.f)),
		dot2(p - vec2(ba.x, clamp(p.y, 0.f, ba.y)))
	);
	float s = sign(max(-p.y, p.x - ba.x));
	float dia = length(wh);
	p = mat2(wh.x, -wh.y, wh.y, wh.x) * p / dia;
	float id = clamp(round(p.x / dia), 0.f, n - 1.f);
	p.x = p.x - id * dia;
	p = mat2(wh.x, wh.y, -wh.y, wh.x) * p / dia;

	float hh = wh.y * 0.5f;
	p.y -= hh;

	if (p.y > hh * sign(p.x))
	{
		s = 1.f;
	}

	p = id < 0.5f || p.x > 0.f ? p : -p;
	d = min(d, dot2(p - vec2(0.f, clamp(p.y, -hh, hh))));
	d = min(d, dot2(p - vec2(clamp(p.x, 0.f, wh.x), hh)));
	return sqrt(d) * s;
}

float sdf_quadratic_circle(in vec2 p)
{
	p = abs(p);

	if (p.y > p.x)
	{
		p = p.yx;
	}

	float a = p.x - p.y;
	float b = p.x + p.y;
	float c = (2.f * b - 1.f) / 3.f;
	float h = a * a + c * c * c;
	float t;

	if (h >= 0.f)
	{
		h = sqrt(h);
		t = sign(h - a) * pow(abs(h - a), 1.f / 3.f) - pow(h + a, 1.f / 3.f);
	}
	else
	{
		float z = sqrt(-c);
		float v = acos(a / (c * z)) / 3.f;
		t = -z * (cos(v) + sin(v) * 1.732050808);
	}

	t *= 0.5f;
	vec2 w = vec2(-t, t) + 0.75f - t * t - p;
	return length(w) * sign(a * a * 0.5f + b - 1.5f);
}

float sdf_hyperbola(in vec2 p, const float k, const float he)
{
	p = abs(p);
	p = vec2(p.x - p.y, p.x + p.y) / sqrt(2.f);

	float x2 = p.x * p.x / 16.f;
	float y2 = p.y * p.y / 16.f;
	float r = k * (4.f * k - p.x * p.y) / 12.f;
	float q = (x2 - y2) * k * k;
	float h = q * q + r * r * r;
	float u;

	if (h < 0.f)
	{
		float m = sqrt(-r);
		u = m * cos(acos(q / (r * m)) / 3.f);
	}
	else
	{
		float m = pow(sqrt(h) - q, 1.f / 3.f);
		u = (m - r / m) * 0.5f;
	}

	float w = sqrt(u + x2);
	float b = k * p.y - x2 * p.x * 2.f;
	float t = p.x * 0.25f - w + sqrt(2.f * x2 - u + b / w * 0.25f);
	t = max(t, sqrt(he * he * 0.5f + k) - he / sqrt(2.f));
	float d = length(p - vec2(t, k / t));
	return p.x * p.y < k ? d : -d;
}

float sdf_circle_wave(in vec2 p, in float tb, const float ra)
{
	tb = PI * 5.f / 6.f * max(tb, 0.0001f);
	vec2 co = ra * vec2(sin(tb), cos(tb));
	p.x = abs(mod(p.x, co.x * 4.f) - co.x * 2.f);
	vec2 p1 = p;
	vec2 p2 = vec2(abs(p.x - 2.f * co.x), -p.y + 2.f * co.y);
	float d1 = ((co.y * p1.x > co.x * p1.y) ? length(p1 - co) : abs(length(p1) - ra));
	float d2 = ((co.y * p2.x > co.x * p2.y) ? length(p2 - co) : abs(length(p2) - ra));
	return min(d1, d2);
}

float get_dist(const vec2 p)
{
	switch (u_Shape)
	{
		case CIRCLE:
			return sdf_circle(p, u_CircleRadius);
		case SQUARE:
			return sdf_square(p, u_SquareExtent);
		case ROUNDED_SQUARE:
			return sdf_rounded_square(p, u_SquareExtent, u_SquareRadius);
		case SEGMENT:
			return sdf_segment(p, u_Segment[0], u_Segment[1]);
		case RHOMBUS:
			return sdf_rhombus(p, u_RhombusSize);
		case ISOSCELES_TRAPEZOID:
			return sdf_isosceles_trapezoid(p, u_IsoscelesTrapezoidR0, u_IsoscelesTrapezoidR1, u_IsoscelesTrapezoidHeight);
		case PARALLELOGRAM:
			return sdf_parallelogram(p, u_ParallelogramWidth, u_ParallelogramHeight, u_ParallelogramSkew);
		case EQUILATERAL_TRIANGLE:
			return sdf_equilateral_triangle(p, u_EquilateralTriangleRadius);
		case ISOSCELES_TRIANGLE:
			return sdf_isosceles_triangle(p, vec2(u_IsoscelesTriangleBase, -u_IsoscelesTriangleHeight));
		case TRIANGLE:
			return sdf_triangle(p, u_Triangle[0], u_Triangle[1], u_Triangle[2]);
		case UNEVEN_CAPSULE:
			return sdf_uneven_capsule(p, u_UnevenCapsuleBotRadius, u_UnevenCapsuleTopRadius, u_UnevenCapsuleHeight);
		case REGULAR_PENTAGON:
			return sdf_regular_pentagon(p, u_RegularPentagonRadius);
		case REGULAR_HEXAGON:
			return sdf_regular_hexagon(p, u_RegularHexagonRadius);
		case REGULAR_OCTOGON:
			return sdf_regular_octogon(p, u_RegularOctogonRadius);
		case HEXAGRAM:
			return sdf_hexagram(p, u_HexagramRadius);
		case STAR5:
			return sdf_star5(p, u_Star5Radius, u_Star5Angle);
		case REGULAR_STAR:
			return sdf_regular_star(p, u_RegularStarRadius, u_RegularStarBranches, u_RegularStarInnerRadius);
		case PIE:
			return sdf_pie(p, vec2(sin(u_PieAngle), cos(u_PieAngle)), u_PieRadius);
		case CUT_DISK:
			return sdf_cut_disk(p, u_CutDiskRadius, u_CutDiskHeight);
		case ARC:
			return sdf_arc(p, vec2(sin(u_ArcAngle), cos(u_ArcAngle)), u_ArcRadius, u_ArcWidth);
		case RING:
			return sdf_ring(p, vec2(cos(u_RingAngle), sin(u_RingAngle)), u_RingRadius, u_RingWidth);
		case HORSESHOE:
			return sdf_horseshoe(p, vec2(cos(u_HorseshoeAngle), sin(u_HorseshoeAngle)), u_HorseshoeRadius, u_HorseshoeWidth);
		case VESICA:
			return sdf_vesica(p, u_VesicaRadius, u_VesicaWidth);
		case MOON:
			return sdf_moon(p, u_MoonInnerCenter, u_MoonRadius, u_MoonInnerRadius);
		case CIRCLE_CROSS:
			return sdf_circle_cross(p, u_CircleCrossRadius);
		case SIMPLE_EGG:
			return sdf_simple_egg(p, u_SimpleEggMaxRadius, u_SimpleEggMinRadius);
		case HEART:
			return sdf_heart(p);
		case CROSS:
			return sdf_cross(p, vec2(u_CrossOuterSize, u_CrossInnerRadius), u_CrossOuterRadius);
		case ROUNDEDX:
			return sdf_roundedx(p, u_RoundedxLength, u_RoundedxRadius);
		case ELLIPSE:
			return sdf_ellipse(p, u_EllipseSize);
		case PARABOLA:
			return sdf_parabola(p, u_ParabolaDirection);
		case PARABOLA_SEGMENT:
			return sdf_parabola_segment(p, u_ParabolaWidth, u_ParabolaHeight);
		case QUADRATIC_BEZIER:
			return sdf_quadratic_bezier(p, u_QuadraticBezier[0], u_QuadraticBezier[1], u_QuadraticBezier[2]);
		case BOBBLY_CROSS:
			return sdf_bobbly_cross(p, u_BobblyCrossRadius);
		case TUNNEL:
			return sdf_tunnel(p, u_TunnelSize);
		case STAIRS:
			return sdf_stairs(p, u_StairsStepSize, u_StairsStepCount);
		case QUADRATIC_CIRCLE:
			return sdf_quadratic_circle(p);
		case HYPERBOLA:
			return sdf_hyperbola(p, u_HyperbolaMidSpace, u_HyperbolaExtent);
		case CIRCLE_WAVE:
			return sdf_circle_wave(p, u_CircleWaveAngle, u_CircleWaveRadius);
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
	float t = u_Time * 0.5f + mix(0.f, 3.f, o);

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
		mpos.x -= u_AspectRatio * 0.5f;
		mpos.y += 0.5f;
		mpos *= 4.f; // 2 (default) x 2 (UV multiplier)

		float d = abs(get_dist(u_CameraPos + mpos * zoom));
		float l = length(uv * zoom - mpos * zoom);

		if (l <= 0.02f * zoom)
		{
			color = vec4(1.f);
			return;
		}
		else if (l >= d - 0.0075f * zoom && l <= d + 0.0075f * zoom)
		{
			color = vec4(get_rainbow(atan(uv.y - mpos.y, uv.x - mpos.x) / (2.f * PI)), 1.f);
			return;
		}
	}

	float d = get_dist(u_CameraPos + uv * zoom);
	vec3 c = d > 0.f ? u_OutColor : u_InColor;
	c *= 1.f - exp(-6.f * abs(d));
	c *= 0.8f + 0.2f * cos(150.f * d);
	c = mix(c, vec3(1.f), 1.f - smoothstep(0.f, 0.01f, abs(d)));

	color = vec4(c, 1.f);
}

