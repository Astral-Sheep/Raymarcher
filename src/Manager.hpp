#pragma once

#include "RayMarcher.hpp"
#include "Engine/Object.hpp"

using namespace Engine;

class Manager : public Object
{
private:
	std::shared_ptr<Raymarcher> mRaymarcher;

	void _RenderImGUI(const float pDelta) override;

	template<typename T>
	void SetRaymarcher()
	{
		if (mRaymarcher.get())
		{
			mRaymarcher->QueueFree();
		}

		mRaymarcher.reset(new T());
		AddChild(*mRaymarcher);
	}

public:
	Manager();
};

