#pragma once

#include "Raymarcher2D.hpp"
#include "math/Vector2.hpp"
#include "math/Vector3.hpp"
#include "math/Vector4.hpp"

namespace _2D
{
	class ShapesRaymarcher : public Raymarcher2D
	{
	private:
		Math::Vector3F mInColor;
		Math::Vector3F mOutColor;
		int mCurrentShape;

		float mCircleRadius;

		Math::Vector2F mSquareExtent;
		Math::Vector4F mSquareRound;

		Math::Vector2F mSegment[2];

		Math::Vector2F mRhombusSize;

		float mIsoscelesTrapezoidR0;
		float mIsoscelesTrapezoidR1;
		float mIsoscelesTrapezoidHeight;

		float mParallelogramWidth;
		float mParallelogramHeight;
		float mParallelogramSkew;

		float mEquilateralTriangleRadius;

		float mIsoscelesTriangleBase;
		float mIsoscelesTriangleHeight;

		Math::Vector2F mTriangle[3];

		float mUnevenCapsuleBottomRadius;
		float mUnevenCapsuleTopRadius;
		float mUnevenCapsuleHeight;

		float mRegularPentagonRadius;

		float mRegularHexagonRadius;

		float mRegularOctogonRadius;

		float mHexagramRadius;

		float mStar5Radius;
		float mStar5Angle;

		float mRegularStarRadius;
		int mRegularStarBranches;
		float mRegularStarInnerRadius;

		float mPieRadius;
		float mPieAngle;

		float mCutDiskRadius;
		float mCutDiskHeight;

		float mArcAngle;
		float mArcRadius;
		float mArcWidth;

		float mRingAngle;
		float mRingRadius;
		float mRingWidth;

		float mHorseshoeAngle;
		float mHorseshoeRadius;
		float mHorseshoeWidth;

		float mVesicaRadius;
		float mVesicaWidth;

		float mMoonRadius;
		float mMoonInnerRadius;
		float mMoonInnerCenter;

		float mCircleCrossRadius;

		float mSimpleEggMinRadius;
		float mSimpleEggMaxRadius;

		float mCrossOuterSize;
		float mCrossInnerRadius;
		float mCrossOuterRadius;

		float mRoundedxLength;
		float mRoundedxRadius;

		Math::Vector2F mEllipseSize;

		float mParabolaDirection;

		float mParabolaWidth;
		float mParabolaHeight;

		Math::Vector2F mQuadraticBezier[3];

		float mBobblyCrossRadius;

		Math::Vector2F mTunnelSize;

		Math::Vector2F mStairsStepSize;
		float mStairsStepCount;

		float mHyperbolaMidSpace;
		float mHyperbolaExtent;

		float mCircleWaveAngle;
		float mCircleWaveRadius;

	private:
		void RenderImGuiParameters() override;
		void _Render(const float pDelta) override;

	public:
		ShapesRaymarcher();
		RAYMARCHER(Shapes2D)
	};
}

