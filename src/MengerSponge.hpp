#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class MengerSponge : public Raymarcher
{
private:
	Math::Vector3F mColor;
	Math::Vector3F mLightColor;
	int mIterationCount;

	void _Render(const float pDelta) override;
	void _RenderImGUI(const float pDelta) override;

public:
	MengerSponge();

	inline RaymarcherType GetType() const override
	{
		return RaymarcherType::MengerSponge;
	}

	inline const char *GetName() const override
	{
		return "MengerSponge";
	}
};

