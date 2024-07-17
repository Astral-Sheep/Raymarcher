#include "ShapesRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "imgui/imgui.h"
#include "math/Math.hpp"

using namespace GL;
using namespace Math;

enum Shape
{
	Circle = 0,
	Square = 1,
	RoundedSquare = 2,
	Segment = 3,
	Rhombus = 4,
	IsoscelesTrapezoid = 5,
	Parallelogram = 6,
	EquilateralTriangle = 7,
	IsoscelesTriangle = 8,
	Triangle = 9,
	UnevenCapsule = 10,
	RegularPentagon = 11,
	RegularHexagon = 12,
	RegularOctogon = 13,
	Hexagram = 14,
	Star5 = 15,
	RegularStar = 16,
	Pie = 17,
	CutDisk = 18,
	Arc = 19,
	Ring = 20,
	Horseshoe = 21,
	Vesica = 22,
	Moon = 23,
	CircleCross = 24,
	SimpleEgg = 25,
	Heart = 26,
	Cross = 27,
	RoundedX = 28,
	Ellipse = 29,
	Parabola = 30,
	ParabolaSegment = 31,
	QuadraticBezier = 32,
	BobblyCross = 33,
	Tunnel = 34,
	Stairs = 35,
	QuadraticCircle = 36,
	Hyperbola = 37,
	CircleWave = 38,
	Max = 39
};

static const char *const shapes[Max] = {
	"Circle",
	"Square",
	"Rounded Square",
	"Segment",
	"Rhombus",
	"Isosceles Trapezoid",
	"Parallelogram",
	"Equilateral Triangle",
	"Isosceles Triangle",
	"Triangle",
	"Uneven Capsule",
	"Regular Pentagon",
	"Regular Hexagon",
	"Regular Octogon",
	"Hexagram",
	"Star 5",
	"Regular Star",
	"Pie",
	"Cut Disk",
	"Arc",
	"Ring",
	"Horseshoe",
	"Vesica",
	"Moon",
	"Circle Cross",
	"Simple Egg",
	"Heart",
	"Cross",
	"Rounded X",
	"Ellipse",
	"Parabola",
	"Parabola Segment",
	"Quadratic Bezier",
	"Bobbly Cross",
	"Tunnel",
	"Stairs",
	"Quadratic Circle",
	"Hyperbola",
	"Circle Wave",
};

namespace _2D
{
	ShapesRaymarcher::ShapesRaymarcher()
		: Raymarcher2D(), mInColor(0.65f, 0.85f, 1.f), mOutColor(0.9f, 0.6f, 0.3f), mCurrentShape(Circle),
		mCircleRadius(1.f),
		mSquareExtent(1.f), mSquareRound(0.2f),
		mSegment{ Vector2F(-1.f, 0.f), Vector2F(1.f, 0.f) },
		mRhombusSize(1.f, 0.75f),
		mIsoscelesTrapezoidR0(1.5f), mIsoscelesTrapezoidR1(0.5f), mIsoscelesTrapezoidHeight(1.f),
		mParallelogramWidth(1.f), mParallelogramHeight(0.5f), mParallelogramSkew(0.5f),
		mEquilateralTriangleRadius(1.f),
		mIsoscelesTriangleBase(1.f), mIsoscelesTriangleHeight(1.f),
		mTriangle{ Vector2F(-0.5f, 0.f), Vector2F(0.f, 0.5f), Vector2F(-1.f, 1.f) },
		mUnevenCapsuleTopRadius(0.1f), mUnevenCapsuleBottomRadius(0.5f), mUnevenCapsuleHeight(1.f),
		mRegularPentagonRadius(1.f),
		mRegularHexagonRadius(1.f),
		mRegularOctogonRadius(1.f),
		mHexagramRadius(1.f),
		mStar5Radius(1.f), mStar5Angle(0.4f),
		mRegularStarRadius(1.f), mRegularStarBranches(7), mRegularStarInnerRadius(3.f),
		mPieRadius(1.f), mPieAngle(45.f),
		mCutDiskRadius(1.f), mCutDiskHeight(0.25f),
		mArcAngle(270.f), mArcRadius(1.f), mArcWidth(0.2f),
		mRingAngle(270.f), mRingRadius(1.f), mRingWidth(0.3f),
		mHorseshoeAngle(270.f), mHorseshoeRadius(1.f), mHorseshoeWidth(0.2f),
		mVesicaRadius(1.f), mVesicaWidth(0.5f),
		mMoonInnerCenter(0.5f), mMoonRadius(1.f), mMoonInnerRadius(0.75f),
		mCircleCrossRadius(0.5f),
		mSimpleEggMaxRadius(1.f), mSimpleEggMinRadius(0.5f),
		mCrossOuterSize(1.f), mCrossInnerRadius(0.5f), mCrossOuterRadius(0.25f),
		mRoundedxLength(1.f), mRoundedxRadius(0.2f),
		mEllipseSize(1.f, 0.5f),
		mParabolaDirection(-1.f),
		mParabolaWidth(0.5f), mParabolaHeight(1.f),
		mQuadraticBezier{ Vector2F(-1.f, 0.f), Vector2F(-0.75f, -1.f), Vector2F(1.f, 0.f) },
		mBobblyCrossRadius(0.75f),
		mTunnelSize(0.5f, 1.f),
		mStairsStepSize(0.2f, 0.2f), mStairsStepCount(5.f),
		mHyperbolaMidSpace(1.f), mHyperbolaExtent(1.f),
		mCircleWaveAngle(1.f), mCircleWaveRadius(1.f)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/shapes.glsl"));
		InitShader();

		mShader->SetUniform3f("u_InColor", mInColor.r, mInColor.g, mInColor.b);
		mShader->SetUniform3f("u_OutColor", mOutColor.r, mOutColor.g, mOutColor.b);
		mShader->SetUniform1i("u_Shape", mCurrentShape);
		mShader->SetUniform1f("u_CircleRadius", mCircleRadius);
	}

	void ShapesRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Shapes"))
		{
			ImGui::Combo("Displayed shape", &mCurrentShape, shapes, Max);
			ImGui::ColorEdit3("In color", (float*)&mInColor);
			ImGui::ColorEdit3("Out color", (float*)&mOutColor);
			mShader->SetUniform1i("u_Shape", mCurrentShape);
			mShader->SetUniform3f("u_InColor", mInColor.r, mInColor.g, mInColor.b);
			mShader->SetUniform3f("u_OutColor", mOutColor.r, mOutColor.g, mOutColor.b);

			switch (mCurrentShape)
			{
				case Circle:
					ImGui::DragFloat("Radius", &mCircleRadius, 0.01f);
					mCircleRadius = std::max(0.01f, mCircleRadius);

					mShader->SetUniform1f("u_CircleRadius", mCircleRadius);
					break;
				case RoundedSquare:
					ImGui::DragFloat4("Rounding radius", (float*)&mSquareRound, 0.01f);

					mShader->SetUniform4f("u_SquareRadius", mSquareRound.x, mSquareRound.y, mSquareRound.z, mSquareRound.w);
				case Square:
					ImGui::DragFloat2("Square extent", (float*)&mSquareExtent, 0.01f);
					mSquareExtent.x = std::max(0.01f, mSquareExtent.x);
					mSquareExtent.y = std::max(0.01f, mSquareExtent.y);

					mShader->SetUniform2f("u_SquareExtent", mSquareExtent.x, mSquareExtent.y);
					break;
				case Segment:
					ImGui::DragFloat2("Segment point 1", (float*)&mSegment[0], 0.01f);
					ImGui::DragFloat2("Segment point 2", (float*)&mSegment[1], 0.01f);

					mShader->SetUniform2fv("u_Segment", 2, (float*)&mSegment);
					break;
				case Rhombus:
					ImGui::DragFloat2("Rhombus size", (float*)&mRhombusSize, 0.01f);
					mRhombusSize.x = std::max(0.01f, mRhombusSize.x);
					mRhombusSize.y = std::max(0.01f, mRhombusSize.y);

					mShader->SetUniform2f("u_RhombusSize", mRhombusSize.x, mRhombusSize.y);
					break;
				case IsoscelesTrapezoid:
					ImGui::DragFloat("Trapezoid bottom length", &mIsoscelesTrapezoidR0, 0.01f);
					ImGui::DragFloat("Trapezoid top length", &mIsoscelesTrapezoidR1, 0.01f);
					ImGui::DragFloat("Trapezoid height", &mIsoscelesTrapezoidHeight, 0.01f);
					mIsoscelesTrapezoidR0 = std::max(0.01f, mIsoscelesTrapezoidR0);
					mIsoscelesTrapezoidR1 = std::max(0.01f, mIsoscelesTrapezoidR1);
					mIsoscelesTrapezoidHeight = std::max(0.01f, mIsoscelesTrapezoidHeight);

					mShader->SetUniform1f("u_IsoscelesTrapezoidR0", mIsoscelesTrapezoidR0);
					mShader->SetUniform1f("u_IsoscelesTrapezoidR1", mIsoscelesTrapezoidR1);
					mShader->SetUniform1f("u_IsoscelesTrapezoidHeight", mIsoscelesTrapezoidHeight);
					break;
				case Parallelogram:
					ImGui::DragFloat("Parallelogram width", &mParallelogramWidth, 0.01f);
					ImGui::DragFloat("Parallelogram height", &mParallelogramHeight, 0.01f);
					ImGui::DragFloat("Parallelogram skew", &mParallelogramSkew, 0.01f);
					mParallelogramWidth = std::max(0.01f, mParallelogramWidth);
					mParallelogramHeight = std::max(0.01f, mParallelogramHeight);

					mShader->SetUniform1f("u_ParallelogramWidth", mParallelogramWidth);
					mShader->SetUniform1f("u_ParallelogramHeight", mParallelogramHeight);
					mShader->SetUniform1f("u_ParallelogramSkew", mParallelogramSkew);
					break;
				case EquilateralTriangle:
					ImGui::DragFloat("Triangle radius", &mEquilateralTriangleRadius, 0.01f);
					mEquilateralTriangleRadius = std::max(0.01f, mEquilateralTriangleRadius);

					mShader->SetUniform1f("u_EquilateralTriangleRadius", mEquilateralTriangleRadius);
					break;
				case IsoscelesTriangle:
					ImGui::DragFloat("Triangle base", &mIsoscelesTriangleBase, 0.01f);
					ImGui::DragFloat("Triangle height", &mIsoscelesTriangleHeight, 0.01f);
					mIsoscelesTriangleBase = std::max(0.01f, mIsoscelesTriangleBase);
					mIsoscelesTriangleHeight = std::max(0.01f, mIsoscelesTriangleHeight);

					mShader->SetUniform1f("u_IsoscelesTriangleBase", mIsoscelesTriangleBase);
					mShader->SetUniform1f("u_IsoscelesTriangleHeight", mIsoscelesTriangleHeight);
					break;
				case Triangle:
					ImGui::DragFloat3("Triangle point 1", (float*)&mTriangle[0], 0.01f);
					ImGui::DragFloat3("Triangle point 2", (float*)&mTriangle[1], 0.01f);
					ImGui::DragFloat3("Triangle point 3", (float*)&mTriangle[2], 0.01f);

					mShader->SetUniform2fv("u_Triangle", 3, (float*)&mTriangle);
					break;
				case UnevenCapsule:
					ImGui::DragFloat("Uneven capsule top radius", &mUnevenCapsuleTopRadius, 0.01f);
					ImGui::DragFloat("Uneven capsule bottom radius", &mUnevenCapsuleBottomRadius, 0.01f);
					ImGui::DragFloat("Uneven capsule height", &mUnevenCapsuleHeight, 0.01f);
					mUnevenCapsuleTopRadius = std::max(0.01f, mUnevenCapsuleTopRadius);
					mUnevenCapsuleBottomRadius = std::max(0.01f, mUnevenCapsuleBottomRadius);
					mUnevenCapsuleHeight = std::max(Math::Abs(mUnevenCapsuleTopRadius - mUnevenCapsuleBottomRadius), mUnevenCapsuleHeight);

					mShader->SetUniform1f("u_UnevenCapsuleTopRadius", mUnevenCapsuleTopRadius);
					mShader->SetUniform1f("u_UnevenCapsuleBotRadius", mUnevenCapsuleBottomRadius);
					mShader->SetUniform1f("u_UnevenCapsuleHeight", mUnevenCapsuleHeight);
					break;
				case RegularPentagon:
					ImGui::DragFloat("Pentagon radius", &mRegularPentagonRadius, 0.01f);
					mRegularPentagonRadius = std::max(0.01f, mRegularPentagonRadius);

					mShader->SetUniform1f("u_RegularPentagonRadius", mRegularPentagonRadius);
					break;
				case RegularHexagon:
					ImGui::DragFloat("Hexagon radius", &mRegularHexagonRadius, 0.01f);
					mRegularHexagonRadius = std::max(0.01f, mRegularHexagonRadius);

					mShader->SetUniform1f("u_RegularHexagonRadius", mRegularHexagonRadius);
					break;
				case RegularOctogon:
					ImGui::DragFloat("Octogon radius", &mRegularOctogonRadius, 0.01f);
					mRegularOctogonRadius = std::max(0.01f, mRegularOctogonRadius);

					mShader->SetUniform1f("u_RegularOctogonRadius", mRegularOctogonRadius);
					break;
				case Hexagram:
					ImGui::DragFloat("Hexagram radius", &mHexagramRadius, 0.01f);
					mHexagramRadius = std::max(0.01f, mHexagramRadius);

					mShader->SetUniform1f("u_HexagramRadius", mHexagramRadius);
					break;
				case Star5:
					ImGui::DragFloat("Star5 radius", &mStar5Radius, 0.01f);
					ImGui::DragFloat("Star5 angle", &mStar5Angle, 0.01f);
					mStar5Radius = std::max(0.01f, mStar5Radius);

					mShader->SetUniform1f("u_Star5Radius", mStar5Radius);
					mShader->SetUniform1f("u_Star5Angle", mStar5Angle);
					break;
				case RegularStar:
					ImGui::DragFloat("Regular star radius", &mRegularStarRadius, 0.01f);
					ImGui::DragInt("Regular star branches", &mRegularStarBranches, 1);
					ImGui::DragFloat("Regular star inner radius", &mRegularStarInnerRadius, 0.01f);
					mRegularStarRadius = std::max(0.01f, mRegularStarRadius);
					mRegularStarBranches = std::max(3, mRegularStarBranches);

					mShader->SetUniform1f("u_RegularStarRadius", mRegularStarRadius);
					mShader->SetUniform1i("u_RegularStarBranches", mRegularStarBranches);
					mShader->SetUniform1f("u_RegularStarInnerRadius", mRegularStarInnerRadius);
					break;
				case Pie:
					ImGui::DragFloat("Pie radius", &mPieRadius, 0.01f);
					ImGui::DragFloat("Pie angle", &mPieAngle, 0.5f, 0.f, 360.f);
					mPieRadius = std::max(0.01f, mPieRadius);

					mShader->SetUniform1f("u_PieRadius", mPieRadius);
					mShader->SetUniform1f("u_PieAngle", mPieAngle * 0.5f * Math::DEG2RAD);
					break;
				case CutDisk:
					ImGui::DragFloat("Cut disk radius", &mCutDiskRadius, 0.01f);
					ImGui::DragFloat("Cut disk height", &mCutDiskHeight, 0.01f);
					mCutDiskRadius = std::max(0.01f, mCutDiskRadius);

					mShader->SetUniform1f("u_CutDiskRadius", mCutDiskRadius);
					mShader->SetUniform1f("u_CutDiskHeight", mCutDiskHeight);
					break;
				case Arc:
					ImGui::DragFloat("Arc angle", &mArcAngle, 0.5f, 0.f, 360.f);
					ImGui::DragFloat("Arc radius", &mArcRadius, 0.01f);
					ImGui::DragFloat("Arc width", &mArcWidth, 0.01f);
					mArcRadius = std::max(0.01f, mArcRadius);
					mArcWidth = Math::Clamp(mArcWidth, 0.01f, mArcRadius);

					mShader->SetUniform1f("u_ArcAngle", mArcAngle * 0.5f * Math::DEG2RAD);
					mShader->SetUniform1f("u_ArcRadius", mArcRadius);
					mShader->SetUniform1f("u_ArcWidth", mArcWidth);
					break;
				case Ring:
					ImGui::DragFloat("Ring angle", &mRingAngle, 0.5f, 0.f, 360.f);
					ImGui::DragFloat("Ring radius", &mRingRadius, 0.01f);
					ImGui::DragFloat("Ring width", &mRingWidth, 0.01f);
					mRingRadius = std::max(0.01f, mRingRadius);
					mRingWidth = Math::Clamp(mRingWidth, 0.01f, mRingRadius * 2.f);

					mShader->SetUniform1f("u_RingAngle", mRingAngle * 0.5f * Math::DEG2RAD);
					mShader->SetUniform1f("u_RingRadius", mRingRadius);
					mShader->SetUniform1f("u_RingWidth", mRingWidth);
					break;
				case Horseshoe:
					ImGui::DragFloat("Horseshoe angle", &mHorseshoeAngle, 0.5f, 0.f, 360.f);
					ImGui::DragFloat("Horseshoe radius", &mHorseshoeRadius, 0.01f);
					ImGui::DragFloat("Horseshoe width", &mHorseshoeWidth, 0.01f);
					mHorseshoeRadius = std::max(0.01f, mHorseshoeRadius);
					mHorseshoeWidth = Math::Clamp(mHorseshoeWidth, 0.01f, mHorseshoeRadius);

					mShader->SetUniform1f("u_HorseshoeAngle", mHorseshoeAngle * 0.5f * Math::DEG2RAD);
					mShader->SetUniform1f("u_HorseshoeRadius", mHorseshoeRadius);
					mShader->SetUniform1f("u_HorseshoeWidth", mHorseshoeWidth);
					break;
				case Vesica:
					ImGui::DragFloat("Vesica radius", &mVesicaRadius, 0.01f);
					ImGui::DragFloat("Vesica width", &mVesicaWidth, 0.01f);
					mVesicaRadius = std::max(0.01f, mVesicaRadius);
					mVesicaWidth = std::max(0.01f, mVesicaWidth);

					mShader->SetUniform1f("u_VesicaRadius", mVesicaRadius);
					mShader->SetUniform1f("u_VesicaWidth", mVesicaWidth);
					break;
				case Moon:
					ImGui::DragFloat("Moon radius", &mMoonRadius, 0.01f);
					ImGui::DragFloat("Moon inner radius", &mMoonInnerRadius, 0.01f);
					ImGui::DragFloat("Moon inner center", &mMoonInnerCenter, 0.01f);
					mMoonRadius = std::max(0.01f, mMoonRadius);
					mMoonInnerRadius = std::max(0.01f, mMoonInnerRadius);

					mShader->SetUniform1f("u_MoonInnerCenter", mMoonInnerCenter);
					mShader->SetUniform1f("u_MoonRadius", mMoonRadius);
					mShader->SetUniform1f("u_MoonInnerRadius", mMoonInnerRadius);
					break;
				case CircleCross:
					ImGui::DragFloat("Circle cross radius", &mCircleCrossRadius, 0.01f);
					mCircleCrossRadius = std::max(0.01f, mCircleCrossRadius);

					mShader->SetUniform1f("u_CircleCrossRadius", mCircleCrossRadius);
					break;
				case SimpleEgg:
					ImGui::DragFloat("Simple egg min radius", &mSimpleEggMinRadius, 0.01f);
					ImGui::DragFloat("Simple egg max radius", &mSimpleEggMaxRadius, 0.01f);
					mSimpleEggMinRadius = std::max(0.01f, mSimpleEggMinRadius);
					mSimpleEggMaxRadius = std::max(0.01f, mSimpleEggMaxRadius);

					mShader->SetUniform1f("u_SimpleEggMinRadius", mSimpleEggMinRadius);
					mShader->SetUniform1f("u_SimpleEggMaxRadius", mSimpleEggMaxRadius);
					break;
				case Cross:
					ImGui::DragFloat("Cross outer size", &mCrossOuterSize, 0.01f);
					ImGui::DragFloat("Cross outer radius", &mCrossOuterRadius, 0.01f);
					ImGui::DragFloat("Cross inner radius", &mCrossInnerRadius, 0.01f);
					mCrossOuterSize = std::max(0.01f, mCrossOuterSize);
					mCrossInnerRadius = std::max(0.01f, mCrossInnerRadius);
					mCrossOuterRadius = std::max(0.01f, mCrossOuterRadius);

					mShader->SetUniform1f("u_CrossOuterSize", mCrossOuterSize);
					mShader->SetUniform1f("u_CrossInnerRadius", mCrossInnerRadius);
					mShader->SetUniform1f("u_CrossOuterRadius", mCrossOuterRadius);
					break;
				case RoundedX:
					ImGui::DragFloat("Rounded x length", &mRoundedxLength, 0.01f);
					ImGui::DragFloat("Rounded x radius", &mRoundedxRadius, 0.01f);
					mRoundedxLength = std::max(0.01f, mRoundedxLength);
					mRoundedxRadius = std::max(0.01f, mRoundedxRadius);

					mShader->SetUniform1f("u_RoundedxLength", mRoundedxLength);
					mShader->SetUniform1f("u_RoundedxRadius", mRoundedxRadius);
					break;
				case Ellipse:
					ImGui::DragFloat2("Ellipse size", (float*)&mEllipseSize, 0.01f);
					mEllipseSize.x = std::max(0.01f, mEllipseSize.x);
					mEllipseSize.y = std::max(0.01f, mEllipseSize.y);

					mShader->SetUniform2f("u_EllipseSize", mEllipseSize.x, mEllipseSize.y);
				case Parabola:
					ImGui::DragFloat("Parabola direction", &mParabolaDirection, 0.01f);

					mShader->SetUniform1f("u_ParabolaDirection", mParabolaDirection);
				case ParabolaSegment:
					ImGui::DragFloat("Parabola width", &mParabolaWidth, 0.01f);
					ImGui::DragFloat("Parabola height", &mParabolaHeight, 0.01f);

					mShader->SetUniform1f("u_ParabolaWidth", mParabolaWidth);
					mShader->SetUniform1f("u_ParabolaHeight", mParabolaHeight);
				case QuadraticBezier:
					ImGui::DragFloat2("Quadratic bezier point 1", (float*)&mQuadraticBezier[0], 0.01f);
					ImGui::DragFloat2("Quadratic bezier point 2", (float*)&mQuadraticBezier[1], 0.01f);
					ImGui::DragFloat2("Quadratic bezier point 3", (float*)&mQuadraticBezier[2], 0.01f);

					mShader->SetUniform2fv("u_QuadraticBezier", 3, (float*)&mQuadraticBezier);
					break;
				case BobblyCross:
					ImGui::DragFloat("Bobbly cross radius", &mBobblyCrossRadius, 0.01f);

					mShader->SetUniform1f("u_BobblyCrossRadius", mBobblyCrossRadius);
					break;
				case Tunnel:
					ImGui::DragFloat2("Tunnel size", (float*)&mTunnelSize, 0.01f);
					mTunnelSize.x = std::max(0.01f, mTunnelSize.x);
					mTunnelSize.y = std::max(0.01f, mTunnelSize.y);

					mShader->SetUniform2f("u_TunnelSize", mTunnelSize.x, mTunnelSize.y);
					break;
				case Stairs:
					ImGui::DragFloat2("Stairs step size", (float*)&mStairsStepSize, 0.01f);
					ImGui::DragFloat("Stairs step count", &mStairsStepCount, 0.1f);
					mStairsStepSize.x = std::max(0.01f, mStairsStepSize.x);
					mStairsStepSize.y = std::max(0.01f, mStairsStepSize.y);
					mStairsStepCount = std::max(0.1f, mStairsStepCount);

					mShader->SetUniform2f("u_StairsStepSize", mStairsStepSize.x, mStairsStepSize.y);
					mShader->SetUniform1f("u_StairsStepCount", mStairsStepCount);
					break;
				case Hyperbola:
					ImGui::DragFloat("Hyperbola mid space", &mHyperbolaMidSpace, 0.01f);
					ImGui::DragFloat("Hyperbola extent", &mHyperbolaExtent, 0.01f);
					mHyperbolaMidSpace = std::max(-0.5f, mHyperbolaMidSpace);

					if (mHyperbolaMidSpace != 0.f)
					{
						mShader->SetUniform1f("u_HyperbolaMidSpace", mHyperbolaMidSpace);
					}

					mShader->SetUniform1f("u_HyperbolaExtent", mHyperbolaExtent);
					break;
				case CircleWave:
					ImGui::DragFloat("Circle wave angle", &mCircleWaveAngle, 0.01f);
					ImGui::DragFloat("Circle wave radius", &mCircleWaveRadius, 0.01f);

					mShader->SetUniform1f("u_CircleWaveAngle", mCircleWaveAngle);
					mShader->SetUniform1f("u_CircleWaveRadius", mCircleWaveRadius);
					break;
				default:
					break;
			}
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void ShapesRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		Raymarcher2D::_Render(pDelta);
	}
}

