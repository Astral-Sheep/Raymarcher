#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class ShapesRaymarcher : public Raymarcher
{
private:
	Math::Vector3F mBackgroundColor;
	int mCurrentShape;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	ShapesRaymarcher();
	RAYMARCHER(Shapes)
};

