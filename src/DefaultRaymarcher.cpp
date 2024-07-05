#include "DefaultRaymarcher.hpp"
#include "imgui/imgui.h"

using namespace GL;

DefaultRaymarcher::DefaultRaymarcher()
	: Raymarcher(), mLightColor(1.f)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/fragment.glsl"));
	InitShader();
}

void DefaultRaymarcher::_Render(const float pDelta)
{
	mShader->SetUniform3f("u_LightColor", mLightColor.r, mLightColor.g, mLightColor.b);
	Raymarcher::_Render(pDelta);
}

void DefaultRaymarcher::_RenderImGUI(const float pDelta)
{
	ImGui::Begin("Options", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(300.f, 150.f));
	ImGui::SetWindowPos(ImVec2(250.f, 25.f));
	ImGui::LabelText("", "Default Raymarcher settings:");
	ImGui::Separator();

	ImGui::ColorEdit3("Light Color", (float*)&mLightColor);

	ImGui::End();
}

