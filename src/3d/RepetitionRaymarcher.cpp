#include "RepetitionRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum Shapes
{
	Sphere = 0,
	Box = 1,
	BoxFrame = 2,
	Max = 3,
};

static const char *shapes[Max] = {
	"Sphere",
	"Box",
	"Box Frame",
};

namespace _3D
{
	RepetitionRaymarcher::RepetitionRaymarcher()
		: Raymarcher3D(), mColor(1.f), mShape(Sphere), mUniform(true), mMod(10.f)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/3d/repetition.glsl"));
		InitShader();
		mMinDistance = 1e-5;
		mMaxDistance = 200.f;
	}

	void RepetitionRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Repetitions"))
		{
			ImGui::Checkbox("Uniform repetition", &mUniform);

			if (mUniform)
			{
				ImGui::DragFloat("Modulus", &mMod.x, 0.01f);
				mMod.x = std::max(0.5f, mMod.x);
				mMod.y = mMod.x;
				mMod.z = mMod.x;
			}
			else
			{
				ImGui::DragFloat3("Modulus", (float*)&mMod, 0.01f);
				mMod.x = std::max(0.5f, mMod.x);
				mMod.y = std::max(0.5f, mMod.y);
				mMod.z = std::max(0.5f, mMod.z);
			}

			ImGui::Combo("Shape", &mShape, shapes, Max);
			ImGui::ColorEdit3("Color", (float*)&mColor);
		}

		Raymarcher3D::RenderImGuiParameters();
	}

	void RepetitionRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform3f("u_Color", mColor.r, mColor.g, mColor.b);
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		mShader->SetUniform3f("u_Mod", mMod.x, mMod.y, mMod.z);
		mShader->SetUniform1i("u_Shape", mShape);
		Raymarcher3D::_Render(pDelta);
	}
}

