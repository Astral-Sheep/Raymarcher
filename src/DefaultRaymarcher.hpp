#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class DefaultRaymarcher : public Raymarcher
{
private:
	Math::Vector3F mLightColor;

	void _Render(const float pDelta) override;
	void _RenderImGUI(const float pDelta) override;

public:
	DefaultRaymarcher();

	inline RaymarcherType GetType() const override
	{
		return RaymarcherType::Default;
	}

	inline const char *GetName() const override
	{
		return "DefaultRaymarcher";
	}
};

