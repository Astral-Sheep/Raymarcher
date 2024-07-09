#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class MengerSponge : public Raymarcher
{
private:
	Math::Vector3F mColor;
	Math::Vector3F mBackgroundColor;
	int mIterationCount;

	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

public:
	MengerSponge();

	RAYMARCHER(MengerSponge);
};

