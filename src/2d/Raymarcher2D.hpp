#pragma once

#include "RayMarcher.hpp"

namespace _2D
{
	class Raymarcher2D : public Raymarcher
	{
	protected:
		// -- Camera control --
		Math::Vector2F mCameraPos;
		float mCameraSpeed;
		float mCameraSpeedMultiplier;
		float mZoom;
		Math::Vector2F mMousePos;

	protected:
		virtual void _Process(const float pDelta) override;
		virtual void _Render(const float pDelta) override;
		virtual void _OnEvent(Event &pEvent) override;
		virtual void RenderImGuiParameters() override;

	public:
		Raymarcher2D();
		virtual ~Raymarcher2D();

		virtual RaymarcherType GetType() const override = 0;

		inline virtual const char *GetName() const override
		{
			return "Raymarcher2D";
		}
	};
}

