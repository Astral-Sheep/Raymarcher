#include "Manager.hpp"
#include "DefaultRaymarcher.hpp"
#include "FailedMengerSponge.hpp"
#include "MengerSponge.hpp"
#include "imgui/imgui.h"
#include <iostream>

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

	Raymarcher *lRaymarcher = Cast<Raymarcher*>(mRaymarcher.Get());

	if (lRaymarcher->GetType() != RaymarcherType::Default)
	{
		if (ImGui::Button("Default"))
		{
			SetRaymarcher<DefaultRaymarcher>();
			std::cout << "OK Default" << std::endl;
		}
	}

	if (lRaymarcher->GetType() != RaymarcherType::MengerSponge)
	{
		if (ImGui::Button("Menger Sponge"))
		{
			SetRaymarcher<MengerSponge>();
			std::cout << "OK Sponge" << std::endl;
		}
	}

	if (lRaymarcher->GetType() != RaymarcherType::FailedMengerSponge)
	{
		if (ImGui::Button("Failed Menger Sponge"))
		{
			SetRaymarcher<FailedMengerSponge>();
			std::cout << "OK Failed Sponge" << std::endl;
		}
	}

	ImGui::End();
	std::cout << "ImGui completed" << std::endl;
}

