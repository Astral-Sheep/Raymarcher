#include "Manager.hpp"
/* #include "DefaultRaymarcher.hpp" */
#include "Repetition.hpp"
#include "ShapesRaymarcher.hpp"
#include "BlendRaymarcher.hpp"
#include "FractalRaymarcher.hpp"
/* #include "MengerSponge.hpp" */
/* #include "FailedMengerSponge.hpp" */
/* #include "SierpinskiTetrahedron.hpp" */
/* #include "JerusalemCube.hpp" */
#include "imgui/imgui.h"
#include "Engine/Application.hpp"
#include "Engine/events/KeyboardEvent.hpp"
#include "Engine/events/KeyCodes.h"

Manager::Manager()
	: mRaymarcher(new ShapesRaymarcher())
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
	ImGui::Begin("Selection", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(200.f, 250.f));
	ImGui::SetWindowPos(ImVec2(25.f, 25.f));
	ImGui::LabelText("", "Raymarchers:");
	ImGui::Separator();

	/* RAYMARCHER_BUTTON(Default, DefaultRaymarcher) */
	RAYMARCHER_BUTTON(Shapes, ShapesRaymarcher)
	RAYMARCHER_BUTTON(Blend, BlendRaymarcher)
	RAYMARCHER_BUTTON(Repetition, Repetition)
	/* RAYMARCHER_BUTTON(FailedMengerSponge, FailedMengerSponge) */
	/* RAYMARCHER_BUTTON(SierpinskiTetrahedron, SierpinskiTetrahedron) */
	RAYMARCHER_BUTTON(Fractals, FractalRaymarcher)

	ImGui::End();
}

void Manager::_OnEvent(Event &pEvent)
{
	if (pEvent.GetEventType() == EventType::KeyReleased)
	{
		auto &lEvent = pEvent.Cast<KeyReleasedEvent>();

		if (lEvent.GetKeyCode() == (int)KeyCode::F11)
		{
			Application::Get().GetWindow().SetFullscreen(!Application::Get().GetWindow().IsFullscreen());
		}
	}
}

