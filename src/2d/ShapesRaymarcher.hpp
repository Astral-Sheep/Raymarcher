#pragma once

#include "Raymarcher2D.hpp"
#include "math/Vector3.hpp"

namespace _2D
{
	class ShapesRaymarcher : public Raymarcher2D
	{
	private:
		Math::Vector3F mInColor;
		Math::Vector3F mOutColor;
		int mCurrentShape;

		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		ShapesRaymarcher();
		RAYMARCHER(Shapes2D)
	};
}

