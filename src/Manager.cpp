#include "Manager.hpp"
/* #include "DefaultRaymarcher.hpp" */
#include "FractalRaymarcher.hpp"
#include "ShapesRaymarcher.hpp"
#include "BlendRaymarcher.hpp"
/* #include "MengerSponge.hpp" */
/* #include "FailedMengerSponge.hpp" */
/* #include "SierpinskiTetrahedron.hpp" */
/* #include "JerusalemCube.hpp" */
#include "imgui/imgui.h"

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
	RAYMARCHER_BUTTON(ShapesRaymarcher, ShapesRaymarcher)
	RAYMARCHER_BUTTON(BlendRaymarcher, BlendRaymarcher)
	/* RAYMARCHER_BUTTON(FailedMengerSponge, FailedMengerSponge) */
	/* RAYMARCHER_BUTTON(SierpinskiTetrahedron, SierpinskiTetrahedron) */
	RAYMARCHER_BUTTON(FractalRaymarcher, FractalRaymarcher)

	ImGui::End();
}

