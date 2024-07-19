#include "Raymarcher3D.hpp"
#include "Engine/Input.hpp"
#include "Engine/events/MouseEvent.hpp"
#include "math/Math.hpp"
#include "math/Matrix2.hpp"
#include "math/Vector2.hpp"
#include "imgui/imgui.h"

using namespace GL;
using namespace Math;

namespace _3D
{
	Raymarcher3D::Raymarcher3D()
		: Raymarcher(),
		mCameraPos(0.f, 0.f, -3.f), mCameraRot(0.f), mCameraSpeed(2.f), mCameraSpeedMultiplier(1.f), mCameraRotationMultiplier(1.f),
		mIterations(200), mMinDistance(1e-6f), mMaxDistance(100.f), mDebugIterations(false),
		mLightColor(1.f), mLightBounces(2)
	{

	}

	Raymarcher3D::~Raymarcher3D() {}

	void Raymarcher3D::_Process(const float pDelta)
	{
		float cos = std::cos(mCameraRot.y);
		float sin = std::sin(mCameraRot.y);
		Vector2F mHorizontalVelocity = Matrix2(
			 cos, sin,
			-sin, cos
		) * Vector2F(
			Input::IsKeyPressed(KeyCode::D) - Input::IsKeyPressed(KeyCode::A),
			Input::IsKeyPressed(KeyCode::W) - Input::IsKeyPressed(KeyCode::S)
		).Normalized();

		mCameraPos += Vector3F(
			mHorizontalVelocity.x,
			Input::IsKeyPressed(KeyCode::Space) - Input::IsKeyPressed(KeyCode::LeftShift),
			mHorizontalVelocity.y
		) * (mCameraSpeed * mCameraSpeedMultiplier * pDelta);
	}

	void Raymarcher3D::_Render(const float pDelta)
	{
		mShader->SetUniform3f("u_CameraPos", mCameraPos.x, mCameraPos.y, mCameraPos.z);
		mShader->SetUniform2f("u_CameraRot", mCameraRot.x, mCameraRot.y);

		mShader->SetUniform1i("u_IterationCount", mIterations);
		mShader->SetUniform1f("u_MinDistance", mMinDistance);
		mShader->SetUniform1f("u_MaxDistance", mMaxDistance);
		mShader->SetUniform1i("u_DebugIterations", mDebugIterations);

		mShader->SetUniform3f("u_LightColor", mLightColor.r, mLightColor.g, mLightColor.b);
		mShader->SetUniform1i("u_LightBounces", mLightBounces);
		Raymarcher::_Render(pDelta);
	}

	void Raymarcher3D::_OnEvent(Event &pEvent)
	{
		Raymarcher::_OnEvent(pEvent);

		if (pEvent.handled)
		{
			return;
		}

		if (pEvent.GetEventType() == EventType::MouseMoved)
		{
			MouseMovedEvent &lMouseMovedEvent = pEvent.Cast<MouseMovedEvent>();

			if (Input::IsMouseButtonPressed(MouseButton::Right))
			{
				mCameraRot.x -= (lMouseMovedEvent.GetY() - mMousePos.y) / 500.f * (90.f * Math::DEG2RAD) * mCameraRotationMultiplier;
				mCameraRot.y += (lMouseMovedEvent.GetX() - mMousePos.x) / 500.f * (90.f * Math::DEG2RAD) * mCameraRotationMultiplier;
			}

			mMousePos.x = lMouseMovedEvent.GetX();
			mMousePos.y = lMouseMovedEvent.GetY();
			pEvent.handled = true;
		}
	}

	void Raymarcher3D::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Raymarching"))
		{
			ImGui::Checkbox("Show iteration count debug", &mDebugIterations);

			ImGui::DragInt("Iteration count", &mIterations, 1);
			mIterations = std::max(mIterations, 1);

			ImGui::DragFloat("Minimum distance", &mMinDistance, 1e-7f, 0.f, 0.f,"%.6f");
			mMinDistance = std::max(mMinDistance, 1e-7f);

			ImGui::DragFloat("Maximum distance", &mMaxDistance, 1.f);
			mMaxDistance = std::max(mMaxDistance, std::min(mMinDistance + 0.1f, 1.f));
		}

		if (ImGui::CollapsingHeader("Lighting"))
		{
			ImGui::ColorEdit3("Light color", (float*)&mLightColor);

			ImGui::DragInt("Light bounces", &mLightBounces, 1);
			mLightBounces = std::max(mLightBounces, 1);
		}

		if (ImGui::CollapsingHeader("Camera"))
		{
			ImGui::DragFloat("Camera movement multiplier", &mCameraSpeedMultiplier, 0.01f);
			ImGui::DragFloat("Camera rotation multiplier", &mCameraRotationMultiplier, 0.01f);
		}
	}
}

