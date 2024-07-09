#include "DefaultRaymarcher.hpp"
/* #include "imgui/imgui.h" */

using namespace GL;

DefaultRaymarcher::DefaultRaymarcher()
	: Raymarcher()
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/fragment.glsl"));
	InitShader();
}

void DefaultRaymarcher::RenderImGuiParameters()
{
	/* ImGui::LabelText("", "Default Raymarcher settings:"); */
	/* ImGui::Separator(); */
}

void DefaultRaymarcher::_Render(const float pDelta)
{
	Raymarcher::_Render(pDelta);
}

