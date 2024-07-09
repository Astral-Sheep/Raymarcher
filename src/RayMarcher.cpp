#include "RayMarcher.hpp"
#include "Engine/Application.hpp"
#include "Engine/Input.hpp"
#include "Engine/Time.hpp"
#include "Engine/events/MouseEvent.hpp"
#include "Engine/events/WindowEvent.hpp"
#include "math/Math.hpp"
#include "math/Matrix2.hpp"
#include "GLCore/core/GLRenderer.hpp"
#include "GLFW/glfw3.h"
#include "imgui/imgui.h"
#include <algorithm>
#include <cmath>
#include <iostream>

using namespace GL;
using namespace Math;

Raymarcher::Raymarcher()
	: mVArray(), mVBuffer(sVertices, sizeof(sVertices)), mLayout(),
	mIBuffer(sIndices, 2 * 3),
	mShader(nullptr),
	mLightColor(1.f), mLightBounces(2),
	mCameraPos(0.f, 0.f, -3.f), mCameraRot(0.f), mCameraSpeed(2.f), mCameraSpeedMultiplier(1.f), mCameraRotationMultiplier(1.f),
	mIterations(200), mMinDistance(1e-6f), mMaxDistance(100.f), mDebugIterations(false),
	mDelta(0.f), mFramerate(0.f), mFramerateUpdateDelay(0.1f)
{
	mLayout.Push<float>(2);
	mVArray.AddBuffer(mVBuffer, mLayout);
}

Raymarcher::~Raymarcher() {}

void Raymarcher::InitShader()
{
	mShader->SetUniform1f("u_AspectRatio", (float)Application::Get().GetWindow().GetWidth() / Application::Get().GetWindow().GetHeight());
}

void Raymarcher::_Process(const float pDelta)
{
	Vector2F mHorizontalVelocity = Matrix2(
		std::cos(mCameraRot.y), std::sin(mCameraRot.y),
		-std::sin(mCameraRot.y), std::cos(mCameraRot.y)
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

void Raymarcher::RenderImGuiParameters() {}

void Raymarcher::_Render(const float pDelta)
{
	mShader->SetUniform3f("u_CameraPos", mCameraPos.x, mCameraPos.y, mCameraPos.z);
	mShader->SetUniform2f("u_CameraRot", mCameraRot.x, mCameraRot.y);

	mShader->SetUniform3f("u_LightColor", mLightColor.r, mLightColor.g, mLightColor.b);
	mShader->SetUniform1i("u_LightBounces", mLightBounces);

	mShader->SetUniform1i("u_IterationCount", mIterations);
	mShader->SetUniform1f("u_MinDistance", mMinDistance);
	mShader->SetUniform1f("u_MaxDistance", mMaxDistance);
	mShader->SetUniform1i("u_DebugIterations", mDebugIterations);

	GLRenderer::DrawTriangles(mVArray, mIBuffer, *mShader);
}

void Raymarcher::_RenderImGUI(const float pDelta)
{
	constexpr float WINDOW_WIDTH = 500.f;
	mDelta += pDelta;

	if (mDelta >= mFramerateUpdateDelay)
	{
		mFramerate = Time::GetFrameRate();
		mDelta = Math::EuclidianRemainder(mDelta, mFramerateUpdateDelay);
	}

	ImGui::Begin("Raymarcher", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(WINDOW_WIDTH, 250.f));
	ImGui::SetWindowPos(ImVec2(Application::Get().GetWindow().GetWidth() - 25.f - WINDOW_WIDTH, 25.f));

	ImGui::Text("Frame rate: %.1f fps", mFramerate);

	ImGui::Text("Options:");
	ImGui::Separator();

	if (ImGui::CollapsingHeader("Raymarching"))
	{
		ImGui::Checkbox("Show iteration count debug", &mDebugIterations);

		ImGui::DragInt("Iteration count", &mIterations, 1);
		mIterations = std::max(mIterations, 1);

		ImGui::DragFloat("Minimum distance", &mMinDistance, 1e-7f, 0.f, 0.f, "%.6f");
		mMinDistance = std::max(mMinDistance, 1e-7f);

		ImGui::DragFloat("Maximum distance", &mMaxDistance, 1.f, 1.f);
		mMaxDistance = std::max(mMaxDistance, mMinDistance + 0.1f);
	}

	RenderImGuiParameters();

	if (ImGui::CollapsingHeader("Lighting"))
	{
		ImGui::ColorEdit3("Light color", (float*)&mLightColor);

		ImGui::DragInt("Light bounces", &mLightBounces, 1);
		mLightBounces = std::max(mLightBounces, 1);
	}

	if (ImGui::CollapsingHeader("Camera"))
	{
		ImGui::DragFloat("Camera movement multiplier", &mCameraSpeedMultiplier, 1.f, 0.01f, 10.f);
		ImGui::DragFloat("Camera rotation multiplier", &mCameraRotationMultiplier, 1.f, 0.01f, 10.f);
	}

	ImGui::End();
}

void Raymarcher::_OnEvent(Event &pEvent)
{
	if (pEvent.GetEventType() == EventType::MouseMoved)
	{
		MouseMovedEvent lMouseMovedEvent = *(MouseMovedEvent*)&pEvent;

		if (Input::IsMouseButtonPressed(MouseButton::Right))
		{
			mCameraRot.x -= (lMouseMovedEvent.GetY() - mMousePos.y) / 500.f * (90.f * Math::DEG2RAD) * mCameraRotationMultiplier;
			mCameraRot.y += (lMouseMovedEvent.GetX() - mMousePos.x) / 500.f * (90.f * Math::DEG2RAD) * mCameraRotationMultiplier;
		}

		mMousePos.x = lMouseMovedEvent.GetX();
		mMousePos.y = lMouseMovedEvent.GetY();
		pEvent.handled = true;
	}
	else if (pEvent.GetEventType() == EventType::WindowResize)
	{
		WindowResizeEvent lWindowResizeEvent = *(WindowResizeEvent*)&pEvent;
		mShader->SetUniform1f("u_AspectRatio", (float)lWindowResizeEvent.GetWidth() / lWindowResizeEvent.GetHeight());
		pEvent.handled = true;
	}
}

