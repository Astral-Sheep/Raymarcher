#include "RepetitionRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Shape
{
	Circle = 0,
	Square = 1,
	Max = 2
};

static const char *const shapes[Max] = {
	"Circle",
	"Square",
};

namespace _2D
{
	RepetitionRaymarcher::RepetitionRaymarcher()
		: Raymarcher2D(),
		mInColor(0.65f, 0.85f, 1.f), mOutColor(0.9f, 0.6f, 0.3f),
		mUniform(true), mMod(2.f),
		mShape(Circle)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/repetition.glsl"));
		InitShader();
	}

	void RepetitionRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Repetition"))
		{
			ImGui::Checkbox("Uniform repetition", &mUniform);

			if (mUniform)
			{
				ImGui::DragFloat("Modulus", (float*)&mMod.x, 0.01f);
				mMod.x = std::max(0.1f, mMod.x);
				mMod.y = mMod.x;
			}
			else
			{
				ImGui::DragFloat2("Modulus", (float*)&mMod, 0.01f);
				mMod.x = std::max(0.1f, mMod.x);
				mMod.y = std::max(0.1f, mMod.y);
			}

			ImGui::Combo("Shape", &mShape, shapes, Max);
			ImGui::ColorEdit3("In color", (float*)&mInColor);
			ImGui::ColorEdit3("Out color", (float*)&mOutColor);
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void RepetitionRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform2f("u_Mod", mMod.x, mMod.y);
		mShader->SetUniform1i("u_Shape", mShape);
		mShader->SetUniform3f("u_InColor", mInColor.r, mInColor.g, mInColor.b);
		mShader->SetUniform3f("u_OutColor", mOutColor.r, mOutColor.g, mOutColor.b);
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		Raymarcher2D::_Render(pDelta);
	}
}

