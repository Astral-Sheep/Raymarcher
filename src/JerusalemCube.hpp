#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class JerusalemCube : public Raymarcher
{
private:
	Math::Vector3F mColor;
	Math::Vector3F mBackgroundColor;
	int mIterationCount;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	JerusalemCube();
	RAYMARCHER(JerusalemCube)
};
