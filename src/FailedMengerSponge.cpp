#include "FailedMengerSponge.hpp"
#include "imgui/imgui.h"

using namespace GL;

FailedMengerSponge::FailedMengerSponge()
	: Raymarcher(), mColor(1.f), mLightColor(1.f), mIterationCount(2)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/failedmengersponge.glsl"));
	InitShader();
}

void FailedMengerSponge::_Render(const float pDelta)
{
	mShader->SetUniform1i("u_IterationCount", mIterationCount);
	mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
	mShader->SetUniform3f("u_LightColor", mLightColor.r, mLightColor.g, mLightColor.b);
	Raymarcher::_Render(pDelta);
}

void FailedMengerSponge::_RenderImGUI(const float pDelta)
{
	ImGui::Begin("Options", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(300.f, 150.f));
	ImGui::SetWindowPos(ImVec2(250.f, 25.f));
	ImGui::LabelText("", "Menger Sponge settings:");
	ImGui::Separator();

	ImGui::SliderInt("Iteration Count", &mIterationCount, 0, 10);
	ImGui::ColorEdit3("Color", (float*)&mColor);
	ImGui::ColorEdit3("Light Color", (float*)&mLightColor);

	ImGui::End();
}


