#include "RayMarcher.hpp"
#include "Engine/Application.hpp"
#include "Engine/Input.hpp"
#include "Engine/events/MouseEvent.hpp"
#include "math/Matrix2.hpp"
#include "GLCore/core/GLRenderer.hpp"
#include "GLFW/glfw3.h"
#include "imgui/imgui.h"
#include <cmath>

using namespace GL;
using namespace Math;

Raymarcher::Raymarcher()
	: mVArray(), mVBuffer(sVertices, sizeof(sVertices)), mLayout(),
	mIBuffer(sIndices, 2 * 3),
	mShader(nullptr),
	mCameraPos(0.f), mCameraRot(0.f), mCameraSpeed(2.f),
	mCameraSpeedMultiplier(1.f), mCameraRotationMultiplier(1.f)
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
	mShader->SetUniform1f("u_Time", (float)glfwGetTime());
	GLRenderer::DrawTriangles(mVArray, mIBuffer, *mShader);
}

void Raymarcher::_RenderImGUI(const float pDelta)
{
	constexpr float WINDOW_WIDTH = 500.f;

	ImGui::Begin("Options", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(WINDOW_WIDTH, 250.f));
	ImGui::SetWindowPos(ImVec2(Application::Get().GetWindow().GetWidth() - 25.f - WINDOW_WIDTH, 25.f));

	ImGui::LabelText("", "Camera options:");
	ImGui::Separator();
	ImGui::DragFloat("Camera movement multiplier", &mCameraSpeedMultiplier, 1.f, 0.01f, 10.f);
	ImGui::DragFloat("Camera rotation multiplier", &mCameraRotationMultiplier, 1.f, 0.01f, 10.f);
	ImGui::Dummy(ImVec2(0.f, 20.f));

	RenderImGuiParameters();

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
	}
}

