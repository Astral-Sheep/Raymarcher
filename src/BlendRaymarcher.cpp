#include "BlendRaymarcher.hpp"
#include "imgui/imgui.h"
#include <cmath>

using namespace GL;

enum Blend
{
	Union = 0,
	Subtraction = 1,
	Intersection = 2,
	XOR = 3,
	Max = 4,
};

static const char *blends[Max] = {
	"Union",
	"Subtraction",
	"Intersection",
	"XOR",
};

BlendRaymarcher::BlendRaymarcher()
	: Raymarcher(), mCurrentBlend(Union), mSmooth(false), mBlendFactor(1.f), mMove(true), mDistance(2.f), mRatio(0.f), mBackgroundColor(1.f)
{
	mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/blend.glsl"));
	InitShader();
}

void BlendRaymarcher::RenderImGuiParameters()
{
	if (ImGui::CollapsingHeader("Blending"))
	{
		ImGui::Combo("Blend mode", &mCurrentBlend, blends, Max);
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

		ImGui::ColorEdit3("Background color", (float*)&mBackgroundColor);
	}

	/* ImGui::LabelText("", "Blend options:"); */
	/* ImGui::Separator(); */

	/* ImGui::Combo("Blend mode", &mCurrentBlend, blends, Max); */
	/* ImGui::Checkbox("Smooth blend", &mSmooth); */

	/* if (mSmooth) */
	/* { */
	/* 	ImGui::DragFloat("Blend factor", &mBlendFactor, 0.01f, 0.f); */
	/* } */

	/* bool lMove = mMove; */
	/* ImGui::Checkbox("Move", &mMove); */

	/* if (mMove) */
	/* { */
	/* 	if (!lMove) */
	/* 	{ */
	/* 		mRatio = std::asin(mDistance / MAX_DIST * 2.f - 1.f); */
	/* 	} */
	/* } */
	/* else */
	/* { */
	/* 	ImGui::SliderFloat("Distance", &mDistance, 0.f, MAX_DIST); */
	/* } */

	/* ImGui::ColorEdit3("Background color", (float*)&mBackgroundColor); */
}

void BlendRaymarcher::_Process(const float pDelta)
{
	Raymarcher::_Process(pDelta);

	if (!mMove)
	{
		return;
	}

	mRatio += pDelta * 0.5f;
	mDistance = (std::sin(mRatio) + 1.f) * 0.5f * MAX_DIST;
}

void BlendRaymarcher::_Render(const float pDelta)
{
	mShader->SetUniform1i("u_BlendMode", mCurrentBlend + mSmooth * Max);
	mShader->SetUniform1f("u_BlendFactor", mBlendFactor);
	mShader->SetUniform1f("u_Distance", mDistance);
	mShader->SetUniform3f("u_BackgroundColor", mBackgroundColor.r, mBackgroundColor.g, mBackgroundColor.b);
	Raymarcher::_Render(pDelta);
}

