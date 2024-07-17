#pragma once

#include "Raymarcher2D.hpp"

namespace _2D
{
	class BlendRaymarcher : public Raymarcher2D
	{
	private:
		static constexpr float MAX_DIST = 1.5f;

		Math::Vector3F mInColor;
		Math::Vector3F mOutColor;
		int mBlendMode;
		bool mSmooth;
		float mBlendFactor;
		bool mMove;
		float mDistance;
		float mRatio;

	private:
		void RenderImGuiParameters() override;
		void _Process(const float pDelta) override;
		void _Render(const float pDelta) override;

	public:
		BlendRaymarcher();
		RAYMARCHER(Blend2D)
	};
}

