#pragma once

#include "Raymarcher2D.hpp"
#include "math/Vector3.hpp"

namespace _2D
{
	class RepetitionRaymarcher : public Raymarcher2D
	{
	private:
		Math::Vector3F mInColor;
		Math::Vector3F mOutColor;
		bool mUniform;
		Math::Vector2F mMod;
		int mShape;

	private:
		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		RepetitionRaymarcher();
		RAYMARCHER(Repetition2D)
	};
}

