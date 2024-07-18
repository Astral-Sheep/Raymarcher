#include "FractalRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Fractal
{
	SierpinskiTriangle = 0,
	MengerCarpet = 1,
	KochCurve = 2,
	Max = 3
};

static const char *const fractals[Max] = {
	"Sierpinski Triangle",
	"Menger Carpet",
	"Koch Curve",
};

namespace _2D
{
	FractalRaymarcher::FractalRaymarcher()
		: Raymarcher2D(), mFractal(SierpinskiTriangle), mIterations(3), mShowDistanceField(false)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/fractals.glsl"));
		InitShader();
	}

	void FractalRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Fractals"))
		{
			ImGui::Combo("Fractal", &mFractal, fractals, Max);
			ImGui::SliderInt("Iterations", &mIterations, 0, 10);
			ImGui::Checkbox("Show distance field", &mShowDistanceField);
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void FractalRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		mShader->SetUniform1i("u_Fractal", mFractal);
		mShader->SetUniform1i("u_Iterations", mIterations);
		mShader->SetUniform1i("u_ShowDistanceField", mShowDistanceField);
		Raymarcher2D::_Render(pDelta);
	}
}

