#pragma once

#include "Engine/Object.hpp"
#include "Engine/utils/Memory.hpp"

using namespace Engine;

class Manager : public Object
{
private:
	Utils::SharedPtr<Object> mRaymarcher;

	void _RenderImGUI(const float pDelta) override;

	template<typename T, typename U>
	inline T Cast(const U &pVal)
	{
		return *(T*)&pVal;
	}

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

