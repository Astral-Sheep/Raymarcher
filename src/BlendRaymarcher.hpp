#pragma once

#include "RayMarcher.hpp"
#include "math/Vector3.hpp"

class BlendRaymarcher : public Raymarcher
{
private:
	static constexpr float MAX_DIST = 1.5f;

	Math::Vector3F mBackgroundColor;
	int mCurrentBlend;
	bool mSmooth;
	float mBlendFactor;
	bool mMove;
	float mDistance;
	float mRatio;

	void RenderImGuiParameters() override;
	void _Process(const float pDelta) override;
	void _Render(const float pDelta) override;

public:
	BlendRaymarcher();
	RAYMARCHER(BlendRaymarcher)
};

