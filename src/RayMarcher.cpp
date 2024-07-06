#include "RayMarcher.hpp"
#include "Engine/Application.hpp"
#include "Engine/Input.hpp"
#include "Engine/events/MouseEvent.hpp"
#include "math/Matrix2.hpp"
#include "GLCore/core/GLRenderer.hpp"
#include "GLFW/glfw3.h"
#include <cmath>

using namespace GL;
using namespace Math;

Raymarcher::Raymarcher()
	: mVArray(), mVBuffer(sVertices, sizeof(sVertices)), mLayout(),
	mIBuffer(sIndices, 2 * 3),
	mShader(nullptr),
	mCameraPos(0.f), mCameraRot(0.f), mCameraSpeed(2.f)
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
	) * mCameraSpeed * pDelta;
}

void Raymarcher::_Render(const float pDelta)
{
	mShader->SetUniform3f("u_CameraPos", mCameraPos.x, mCameraPos.y, mCameraPos.z);
	mShader->SetUniform2f("u_CameraRot", mCameraRot.x, mCameraRot.y);
	mShader->SetUniform1f("u_Time", (float)glfwGetTime());
	GLRenderer::DrawTriangles(mVArray, mIBuffer, *mShader);
}

void Raymarcher::_OnEvent(Event &pEvent)
{
	if (pEvent.GetEventType() == EventType::MouseMoved)
	{
		MouseMovedEvent lMouseMovedEvent = *(MouseMovedEvent*)&pEvent;

		if (Input::IsMouseButtonPressed(MouseButton::Right))
		{
			mCameraRot.x -= (lMouseMovedEvent.GetY() - mMousePos.y) / 500.f * (90.f * Math::DEG2RAD);
			mCameraRot.y += (lMouseMovedEvent.GetX() - mMousePos.x) / 500.f * (90.f * Math::DEG2RAD);
		}

		mMousePos.x = lMouseMovedEvent.GetX();
		mMousePos.y = lMouseMovedEvent.GetY();
	}
}

