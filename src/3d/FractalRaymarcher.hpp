#pragma once

#include "Raymarcher3D.hpp"
#include "math/Vector3.hpp"

namespace _3D
{
	class FractalRaymarcher : public Raymarcher3D
	{
	private:
		int mFractal;
		int mFractalIterations;
		Math::Vector3F mColor;

		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;
		void _OnEvent(Event &pEvent) override;

	public:
		FractalRaymarcher();
		RAYMARCHER(Fractals3D)
	};
}

