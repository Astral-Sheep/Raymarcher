#pragma once

#include "RayMarcher.hpp"

class SierpinskiTetrahedron : public Raymarcher
{
private:
	Math::Vector3F mColor;
	Math::Vector3F mBackgroundColor;
	int mIterationCount;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	SierpinskiTetrahedron();
	RAYMARCHER(SierpinskiTetrahedron)
};

