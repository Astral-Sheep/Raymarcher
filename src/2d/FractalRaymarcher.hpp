#pragma once

#include "2d/Raymarcher2D.hpp"

namespace _2D
{
	class FractalRaymarcher : public Raymarcher2D
	{
	private:
		int mFractal;
		int mIterations;
		bool mShowDistanceField;

	private:
		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		FractalRaymarcher();
		RAYMARCHER(Fractals2D)
	};
}

