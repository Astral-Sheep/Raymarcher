#include "FractalRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Fractal
{
	MengerSponge = 0,
	JerusalemCube = 1,
	Max = 3,
};

static const char *fractals[Max] = {
	"Menger Sponge",
	"Jerusalem Cube",
};

namespace _3D
{
	FractalRaymarcher::FractalRaymarcher()
		: Raymarcher3D(), mFractal(MengerSponge), mFractalIterations(0), mColor(0.75f)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/3d/fractals.glsl"));
		InitShader();
	}

	void FractalRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Fractals"))
		{
			ImGui::Combo("Fractal", &mFractal, fractals, Max);
			ImGui::SliderInt("Iterations", &mFractalIterations, 0, 10);
			ImGui::ColorEdit3("Color", (float*)&mColor);
		}

		Raymarcher3D::RenderImGuiParameters();
	}

	void FractalRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());

		mShader->SetUniform1i("u_Fractal", mFractal);
		mShader->SetUniform1i("u_FractalIterationCount", mFractalIterations);
		mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
		Raymarcher3D::_Render(pDelta);
	}
}
