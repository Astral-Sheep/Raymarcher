#pragma once

#include "Raymarcher3D.hpp"
#include "math/Vector3.hpp"

namespace _3D
{
	class ShapesRaymarcher : public Raymarcher3D
	{
	private:
		Math::Vector3F mBackgroundColor;
		int mCurrentShape;

		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		ShapesRaymarcher();
		RAYMARCHER(Shapes3D)
	};
}

