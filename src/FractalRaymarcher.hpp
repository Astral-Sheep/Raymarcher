#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class FractalRaymarcher : public Raymarcher
{
private:
	int mFractal;
	int mFractalIterations;
	Math::Vector3F mColor;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	FractalRaymarcher();
	RAYMARCHER(FractalRaymarcher)
};

