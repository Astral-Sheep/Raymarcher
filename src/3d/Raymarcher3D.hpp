#pragma once

#include "RayMarcher.hpp"
#include "math/Vector2.hpp"
#include "math/Vector3.hpp"

namespace _3D
{
	class Raymarcher3D : public Raymarcher
	{
	protected:
		// -- Camera control --
		Math::Vector3F mCameraPos;
		Math::Vector2F mCameraRot;
		float mCameraSpeed;
		float mCameraSpeedMultiplier;
		float mCameraRotationMultiplier;
		Math::Vector2F mMousePos;

		// -- Parameters --
		int mIterations;
		float mMinDistance;
		float mMaxDistance;
		bool mDebugIterations;
		Math::Vector3F mLightColor;
		int mLightBounces;

	protected:
		virtual void _Process(const float pDelta) override;
		virtual void _Render(const float pDelta) override;
		virtual void _OnEvent(Event &pEvent) override;
		virtual void RenderImGuiParameters() override;

	public:
		Raymarcher3D();
		virtual ~Raymarcher3D();

		virtual RaymarcherType GetType() const override = 0;

		inline virtual const char *GetName() const override
		{
			return "Raymarcher3D";
		}
	};
}

