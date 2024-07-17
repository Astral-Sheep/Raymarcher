#include "ShapesRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Shape
{
	Circle = 0,
	Square = 1,
	RoundedSquare = 2,
	Segment = 3,
	Rhombus = 4,
	IsoscelesTrapezoid = 5,
	Parallelogram = 6,
	EquilateralTriangle = 7,
	IsoscelesTriangle = 8,
	Triangle = 9,
	UnevenCapsule = 10,
	RegularPentagon = 11,
	RegularHexagon = 12,
	RegularOctogon = 13,
	Hexagram = 14,
	Star5 = 15,
	RegularStar = 16,
	Pie = 17,
	CutDisk = 18,
	Arc = 19,
	Ring = 20,
	HorseShoe = 21,
	Vesica = 22,
	Moon = 23,
	CircleCross = 24,
	SimpleEgg = 25,
	Heart = 26,
	Cross = 27,
	RoundedX = 28,
	Polygon = 29,
	Ellipse = 30,
	Parabola = 31,
	ParabolaSegment = 32,
	QuadraticBezier = 33,
	BobblyCross = 34,
	Tunnel = 35,
	Stairs = 36,
	QuadraticCircle = 37,
	Hyperbola = 38,
	CircleWave = 39,
	Max = 40
};

static const char *shapes[Max] = {
	"Circle",
	"Square",
	"Rounded Square",
	"Segment",
	"Rhombus",
	"Isosceles Trapezoid",
	"Parallelogram",
	"Equilateral Triangle",
	"Isosceles Triangle",
	"Triangle",
	"Uneven Capsule",
	"Regular Pentagon",
	"Regular Hexagon",
	"Regular Octogon",
	"Hexagram",
	"Star 5",
	"Regular Star",
	"Pie",
	"Cut Disk",
	"Arc",
	"Ring",
	"Horse Shoe",
	"Vesica",
	"Moon",
	"Circle Cross",
	"Simple Egg",
	"Heart",
	"Cross",
	"Rounded X",
	"Polygon",
	"Ellipse",
	"Parabola",
	"Parabola Segment",
	"Quadratic Bezier",
	"Bobbly Cross",
	"Tunnel",
	"Stairs",
	"Quadratic Circle",
	"Hyperbola",
	"Circle Wave",
};

namespace _2D
{
	ShapesRaymarcher::ShapesRaymarcher()
		: Raymarcher2D(), mInColor(0.65f, 0.85f, 1.f), mOutColor(0.9f, 0.6f, 0.3f), mCurrentShape(Circle)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/shapes.glsl"));
		InitShader();
	}

	void ShapesRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Shapes"))
		{
			ImGui::Combo("Displayed shape", &mCurrentShape, shapes, Max);
			ImGui::ColorEdit3("In color", (float*)&mInColor);
			ImGui::ColorEdit3("Out color", (float*)&mOutColor);
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void ShapesRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform3f("u_InColor", mInColor.r, mInColor.g, mInColor.b);
		mShader->SetUniform3f("u_OutColor", mOutColor.r, mOutColor.g, mOutColor.b);
		mShader->SetUniform1i("u_Shape", mCurrentShape);
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		Raymarcher2D::_Render(pDelta);
	}
}

