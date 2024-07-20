#include "Manager.hpp"
#include "2d/BlendRaymarcher.hpp"
#include "2d/FractalRaymarcher.hpp"
#include "2d/RepetitionRaymarcher.hpp"
#include "2d/ShapesRaymarcher.hpp"
#include "3d/ShapesRaymarcher.hpp"
#include "3d/BlendRaymarcher.hpp"
#include "3d/RepetitionRaymarcher.hpp"
#include "3d/FractalRaymarcher.hpp"
#include "imgui/imgui.h"
#include "Engine/Application.hpp"
#include "Engine/events/KeyboardEvent.hpp"
#include "Engine/events/KeyCodes.h"

Manager::Manager()
	: mRaymarcher(new _2D::ShapesRaymarcher()), mShowImGui(true)
{
	AddChild(*mRaymarcher);
}

#define RAYMARCHER_BUTTON(T, Class)\
	if (mRaymarcher->GetType() != RaymarcherType::T)\
	{\
		if (ImGui::Button(#T))\
		{\
			SetRaymarcher<Class>();\
		}\
	}

void Manager::_RenderImGUI(const float pDelta)
{
	if (!mShowImGui)
	{
		return;
	}

	ImGui::Begin("Selection", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(200.f, 250.f));
	ImGui::SetWindowPos(ImVec2(25.f, 25.f));
	ImGui::LabelText("", "Raymarchers:");
	ImGui::Separator();

	if (ImGui::CollapsingHeader("2D"))
	{
		RAYMARCHER_BUTTON(Shapes2D, _2D::ShapesRaymarcher)
		RAYMARCHER_BUTTON(Blend2D, _2D::BlendRaymarcher)
		RAYMARCHER_BUTTON(Repetition2D, _2D::RepetitionRaymarcher)
		RAYMARCHER_BUTTON(Fractals2D, _2D::FractalRaymarcher)
	}

	if (ImGui::CollapsingHeader("3D"))
	{
		RAYMARCHER_BUTTON(Shapes3D, _3D::ShapesRaymarcher)
		RAYMARCHER_BUTTON(Blend3D, _3D::BlendRaymarcher)
		RAYMARCHER_BUTTON(Repetition3D, _3D::RepetitionRaymarcher)
		RAYMARCHER_BUTTON(Fractals3D, _3D::FractalRaymarcher)
	}

	ImGui::End();
}

void Manager::_OnEvent(Event &pEvent)
{
	if (pEvent.GetEventType() == EventType::KeyReleased)
	{
		KeyReleasedEvent &lKREvent = pEvent.Cast<KeyReleasedEvent>();

		if (lKREvent.GetKeyCode() == (int)KeyCode::F11)
		{
			Window &lWindow = Application::Get().GetWindow();
			lWindow.SetFullscreen(!lWindow.IsFullscreen());
			lKREvent.handled = true;
		}
		else if (lKREvent.GetKeyCode() == (int)KeyCode::F6)
		{
			mShowImGui = !mShowImGui;
		}
	}
}

