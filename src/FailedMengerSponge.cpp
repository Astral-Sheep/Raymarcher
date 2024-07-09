#include "FailedMengerSponge.hpp"
#include "imgui/imgui.h"

using namespace GL;

FailedMengerSponge::FailedMengerSponge()
	: Raymarcher(), mColor(1.f, 0.5f, 0.f), mBackgroundColor(1.f), mIterationCount(2)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/failedmengersponge.glsl"));
	InitShader();
}

void FailedMengerSponge::RenderImGuiParameters()
{
	ImGui::LabelText("", "Menger Sponge settings:");
	ImGui::Separator();

	ImGui::SliderInt("Iteration Count", &mIterationCount, 0, 6);
	ImGui::ColorEdit3("Color", (float*)&mColor);
	ImGui::ColorEdit3("Background Color", (float*)&mBackgroundColor);
}

void FailedMengerSponge::_Render(const float pDelta)
{
	mShader->SetUniform1i("u_IterationCount", mIterationCount);
	mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
	mShader->SetUniform3f("u_BackgroundColor", mBackgroundColor.r, mBackgroundColor.g, mBackgroundColor.b);
	Raymarcher::_Render(pDelta);
}


