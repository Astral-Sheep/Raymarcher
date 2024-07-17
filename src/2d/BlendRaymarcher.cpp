#include "BlendRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"

using namespace GL;

enum BlendMode
{
	Union = 0,
	Subtract = 1,
	Intersect = 2,
	XOR = 3,
	Max = 4
};

static const char *const blendModes[Max] = {
	"Union",
	"Subtract",
	"Intersect",
	"XOR",
};

namespace _2D
{
	BlendRaymarcher::BlendRaymarcher()
		: Raymarcher2D(),
		mInColor(0.65f, 0.85f, 1.f), mOutColor(0.9f, 0.6f, 0.3f),
		mBlendMode(Union), mSmooth(false), mBlendFactor(1.f), mMove(true), mDistance(2.f), mRatio(0.f)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/blend.glsl"));
		InitShader();
	}

	void BlendRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Blending"))
		{
			ImGui::Combo("Blend mode", &mBlendMode, blendModes, Max);
			ImGui::Checkbox("Smooth blend", &mSmooth);

			if (mSmooth)
			{
				ImGui::DragFloat("Blend factor", &mBlendFactor, 0.01f);
			}

			bool lMove = mMove;
			ImGui::Checkbox("Move", &mMove);

			if (mMove)
			{
				if (!lMove)
				{
					mRatio = std::asin(mDistance / MAX_DIST * 2.f - 1.f);
				}
			}
			else
			{
				ImGui::SliderFloat("Distance", &mDistance, 0.f, MAX_DIST);
			}

			ImGui::ColorEdit3("In color", (float*)&mInColor);
			ImGui::ColorEdit3("Out color", (float*)&mOutColor);
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void BlendRaymarcher::_Process(const float pDelta)
	{
		Raymarcher2D::_Process(pDelta);

		if (!mMove)
		{
			return;
		}

		mRatio += pDelta * 0.5f;
		mDistance = (std::sin(mRatio) + 1.f) * 0.5f * MAX_DIST;
	}

	void BlendRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform1i("u_BlendMode", mBlendMode + mSmooth * Max);
		mShader->SetUniform1f("u_BlendFactor", mBlendFactor);
		mShader->SetUniform1f("u_Distance", mDistance);
		mShader->SetUniform3f("u_InColor", mInColor.r, mInColor.g, mInColor.b);
		mShader->SetUniform3f("u_OutColor", mOutColor.r, mOutColor.g, mOutColor.b);
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		Raymarcher2D::_Render(pDelta);
	}
}

