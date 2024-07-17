#pragma once

#include "Raymarcher3D.hpp"
#include "math/Vector3.hpp"

namespace _3D
{
	class RepetitionRaymarcher : public Raymarcher3D
	{
	private:
		Math::Vector3F mColor;
		bool mUniform;
		Math::Vector3F mMod;
		int mShape;

		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		RepetitionRaymarcher();
		RAYMARCHER(Repetition3D)
	};
}
