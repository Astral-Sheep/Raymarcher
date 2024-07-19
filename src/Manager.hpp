#pragma once

#include "RayMarcher.hpp"
#include "Engine/Object.hpp"
#include "Engine/utils/Memory.hpp"

using namespace Engine;

class Manager : public Object
{
private:
	Memory::SharedPtr<Raymarcher> mRaymarcher;
	bool mShowImGui;

	void _RenderImGUI(const float pDelta) override;
	void _OnEvent(Event &pEvent) override;

	template<typename T>
	void SetRaymarcher()
	{
		if (mRaymarcher.Get())
		{
			RemoveChild(*mRaymarcher);
			mRaymarcher->QueueFree();
		}

		mRaymarcher = new T();
		AddChild(*mRaymarcher);
	}

public:
	Manager();
};

