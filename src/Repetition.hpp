#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class Repetition : public Raymarcher
{
private:
	Math::Vector3F mColor;
	Math::Vector3F mMod;
	int mShape;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	Repetition();
	RAYMARCHER(Repetition)
};
