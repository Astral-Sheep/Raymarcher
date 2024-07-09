#pragma once

#include "RayMarcher.hpp"

class DefaultRaymarcher : public Raymarcher
{
private:
	void RenderImGuiParameters() override;
	void _Render(const float pDelta) override;

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

