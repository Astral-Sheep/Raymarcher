#include "Manager.hpp"
#include "DefaultRaymarcher.hpp"
#include "MengerSponge.hpp"
#include "imgui/imgui.h"

Manager::Manager()
	: mRaymarcher(new MengerSponge())
{
	AddChild(*mRaymarcher);
}

void Manager::_RenderImGUI(const float pDelta)
{
	ImGui::Begin("Selection", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(200.f, 125.f));
	ImGui::SetWindowPos(ImVec2(25.f, 25.f));
	ImGui::LabelText("", "Raymarchers:");
	ImGui::Separator();

	if (mRaymarcher->GetType() != RaymarcherType::Default)
	{
		if (ImGui::Button("Default"))
		{
			SetRaymarcher<DefaultRaymarcher>();
		}
	}

	if (mRaymarcher->GetType() != RaymarcherType::MengerSponge)
	{
		if (ImGui::Button("Menger Sponge"))
		{
			SetRaymarcher<MengerSponge>();
		}
	}

	ImGui::End();
}

