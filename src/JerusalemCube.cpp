#include "JerusalemCube.hpp"
#include "imgui/imgui.h"

using namespace GL;

JerusalemCube::JerusalemCube()
	: Raymarcher(), mColor(1.f, 0.5f, 0.f), mBackgroundColor(1.f), mIterationCount(2)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/jerusalemcube.glsl"));
	InitShader();
}

void JerusalemCube::RenderImGuiParameters()
{
	ImGui::LabelText("", "Jerusalem cube settings:");
	ImGui::Separator();

	ImGui::SliderInt("Iteration count", &mIterationCount, 0, 6);
	ImGui::ColorEdit3("Color", (float*)&mColor);
	ImGui::ColorEdit3("Background color", (float*)&mBackgroundColor);
}

void JerusalemCube::_Render(const float pDelta)
{
	mShader->SetUniform1i("u_IterationCount", mIterationCount);
	mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
	mShader->SetUniform3f("u_BackgroundColor", mBackgroundColor.r, mBackgroundColor.g, mBackgroundColor.b);
	Raymarcher::_Render(pDelta);
}

