#include "FractalRaymarcher.hpp"
#include "RayMarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Fractal
{
	MengerSponge = 0,
	JerusalemCube = 1,
	Max = 2,
};

static const char *fractals[Max] = {
	"Menger Sponge",
	"Jerusalem Cube",
};

FractalRaymarcher::FractalRaymarcher()
	: Raymarcher(), mFractal(MengerSponge), mFractalIterations(0), mColor(0.75f)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/fractals.glsl"));
	InitShader();
}

void FractalRaymarcher::RenderImGuiParameters()
{
	if (ImGui::CollapsingHeader("Fractals settings:"))
	{
		ImGui::Combo("Fractal", &mFractal, fractals, Max);
		ImGui::SliderInt("Iterations", &mFractalIterations, 0, 10);
		ImGui::ColorEdit3("Color", (float*)&mColor);
	}
}

void FractalRaymarcher::_Render(const float pDelta)
{
	mShader->SetUniform1f("u_Time", Time::GetElapsedTime());

	mShader->SetUniform1i("u_Fractal", mFractal);
	mShader->SetUniform1i("u_FractalIterationCount", mFractalIterations);
	mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
	Raymarcher::_Render(pDelta);
}

