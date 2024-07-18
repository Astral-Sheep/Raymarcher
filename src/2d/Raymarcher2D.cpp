#include "Raymarcher2D.hpp"
#include "Engine/Application.hpp"
#include "Engine/Input.hpp"
#include "Engine/events/Event.hpp"
#include "Engine/events/MouseButtons.hpp"
#include "Engine/events/MouseEvent.hpp"
#include "imgui/imgui.h"
#include "math/Math.hpp"
#include "math/Vector2.hpp"

using namespace GL;
using namespace Math;

namespace _2D
{
	Raymarcher2D::Raymarcher2D()
		: Raymarcher(),
		mCameraPos(0.f), mCameraSpeed(2.f), mCameraSpeedMultiplier(1.f), mZoom(0.f)
	{

	}

	Raymarcher2D::~Raymarcher2D() {}

	void Raymarcher2D::_Process(const float pDelta)
	{
		Raymarcher::_Process(pDelta);

		mCameraPos += Vector2F(
			Input::IsKeyPressed(KeyCode::D) - Input::IsKeyPressed(KeyCode::A),
			Input::IsKeyPressed(KeyCode::W) - Input::IsKeyPressed(KeyCode::S)
		).Normalized() * (mCameraSpeed * mCameraSpeedMultiplier * std::pow(1.25f, -mZoom) * pDelta);
	}

	void Raymarcher2D::_Render(const float pDelta)
	{
		mShader->SetUniform2f("u_CameraPos", mCameraPos.x, mCameraPos.y);
		mShader->SetUniform1f("u_Zoom", mZoom);
		Raymarcher::_Render(pDelta);
	}

	void Raymarcher2D::_OnEvent(Event &pEvent)
	{
		Raymarcher::_OnEvent(pEvent);

		if (pEvent.handled)
		{
			return;
		}

		switch (pEvent.GetEventType())
		{
			case EventType::MouseMoved:
			{
				MouseMovedEvent &lMMEvent = pEvent.Cast<MouseMovedEvent>();

				if (Input::IsMouseButtonPressed(MouseButton::Right))
				{
					const float p = std::pow(1.25f, -mZoom);
					mCameraPos += Vector2F(
						(lMMEvent.GetX() - mMousePos.x) * -0.0055f * p, // I'm too lazy to get a global value, this one only works in 1280x720
						(lMMEvent.GetY() - mMousePos.y) * 0.0055f * p
					);
				}

				mMousePos.x = lMMEvent.GetX();
				mMousePos.y = lMMEvent.GetY();
				mShader->SetUniform2f(
					"u_MousePos",
					mMousePos.x / Application::Get().GetWindow().GetHeight(),
					-mMousePos.y / Application::Get().GetWindow().GetHeight()
				);

				pEvent.handled = true;
				break;
			}
			case EventType::MouseScrolled:
			{
				MouseScrolledEvent lMSEvent = pEvent.Cast<MouseScrolledEvent>();
				mZoom = Math::Clamp(mZoom + lMSEvent.GetYOffset(), -10.f, 20.f);
				pEvent.handled = true;
				break;
			}
			case EventType::MouseButtonPressed:
			{
				MouseButtonPressedEvent lMBPEvent = pEvent.Cast<MouseButtonPressedEvent>();

				if (lMBPEvent.GetMouseButton() == (int)MouseButton::Left)
				{
					mShader->SetUniform1i("u_ShowMouseDistance", true);
				}

				pEvent.handled = true;
				break;
			}
			case EventType::MouseButtonReleased:
			{
				MouseButtonReleasedEvent lMBREvent = pEvent.Cast<MouseButtonReleasedEvent>();

				if (lMBREvent.GetMouseButton() == (int)MouseButton::Left)
				{
					mShader->SetUniform1i("u_ShowMouseDistance", false);
				}

				pEvent.handled = true;
				break;
			}
			default:
				break;
		}
	}

	void Raymarcher2D::RenderImGuiParameters()
	{
		ImGui::Text("Left click to show distance to mouse");

		if (ImGui::CollapsingHeader("Camera"))
		{
			ImGui::DragFloat("Camera movement multiplier", &mCameraSpeedMultiplier);
			ImGui::DragFloat("Zoom", &mZoom, 0.1f, -10.f, 20.f, "%.1f");
		}
	}
}

