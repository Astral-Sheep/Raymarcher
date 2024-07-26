#pragma once

#include "2d/Raymarcher2D.hpp"
#include "math/Vector2.hpp"

namespace _2D
{
	class FractalRaymarcher : public Raymarcher2D
	{
	private:
		static constexpr float MOVEMENT_DURATION = 5.f;
		static const Math::Vector2F CAMERA_POS;

		int mFractal;
		int mIterations;
		bool mShowDistanceField;
		bool mAutoCamera;
		float mCameraState;

	private:
		void RenderImGuiParameters() override;
		void _Process(const float pDelta) override;
		void _Render(const float pDelta) override;
		void _OnEvent(Event &pEvent) override;

	public:
		FractalRaymarcher();
		RAYMARCHER(Fractals2D)
	};
}

