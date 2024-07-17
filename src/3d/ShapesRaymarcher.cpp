#include "ShapesRaymarcher.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Shape
{
	Sphere = 0,
	Box = 1,
	RoundedBox = 2,
	BoxFrame = 3,
	Torus = 4,
	CappedTorus = 5,
	Link = 6,
	Cylinder = 7,
	HexagonalPrism = 8,
	TriangularPrism = 9,
	SolidAngle = 10,
	CutSphere = 11,
	CutHollowSphere = 12,
	Ellipsoid = 13,
	Octahedron = 14,
	Pyramid = 15,
	Max = 16
};

static const char *shapes[Max] = {
	"Sphere",
	"Box",
	"Rounded Box",
	"Box Frame",
	"Torus",
	"Capped Torus",
	"Link",
	"Cylinder",
	"Hexagonal Prism",
	"Triangular Prism",
	"Solid Angle",
	"Cut Sphere",
	"Cut Hollow Sphere",
	"Ellipsoid",
	"Octahedron",
	"Pyramid",
};

namespace _3D
{
	ShapesRaymarcher::ShapesRaymarcher()
		: Raymarcher3D(), mBackgroundColor(1.f), mCurrentShape(Sphere)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/3d/shapes.glsl"));
		InitShader();
	}

	void ShapesRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Shapes"))
		{
			ImGui::Combo("Displayed shape", &mCurrentShape, shapes, Max);
			ImGui::ColorEdit3("Background color", (float*)&mBackgroundColor);
		}

		Raymarcher3D::RenderImGuiParameters();
	}

	void ShapesRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform3f("u_BackgroundColor", mBackgroundColor.r, mBackgroundColor.g, mBackgroundColor.b);
		mShader->SetUniform1i("u_Shape", mCurrentShape);
		Raymarcher3D::_Render(pDelta);
	}
}

