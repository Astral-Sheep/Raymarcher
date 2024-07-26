#include "FractalRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "Engine/events/Event.hpp"
#include "Engine/events/KeyCodes.h"
#include "Engine/events/KeyboardEvent.hpp"
#include "imgui/imgui.h"
#include "math/Math.hpp"
#include <cmath>

using namespace GL;
using namespace Math;

namespace _2D
{
	enum Fractal
	{
		SierpinskiTriangle = 0,
		MengerCarpet = 1,
		CantorDust = 2,
		/* KochCurve = 2, */
		Max = 3
	};

	static const char *const fractals[Max] = {
		"Sierpinski Triangle",
		"Menger Carpet",
		"Cantor Dust"
		/* "Koch Curve", */
	};

	static const int maxIterations[Max] = {
		21,
		15,
		14,
	};

	static const float maxZoom[Max] = {
		50.f,
		57.f,
		54.f,
	};

	const Vector2F FractalRaymarcher::CAMERA_POS = Vector2F(0.0265505f, 0.288753f);

	FractalRaymarcher::FractalRaymarcher()
		: Raymarcher2D(), mFractal(SierpinskiTriangle), mIterations(3), mShowDistanceField(false),
		mAutoCamera(false), mCameraState(0.f)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/fractals.glsl"));
		InitShader();
	}

	void FractalRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Fractals"))
		{
			ImGui::Combo("Fractal", &mFractal, fractals, Max);
			ImGui::SliderInt("Iterations", &mIterations, 0, 100);
			ImGui::Checkbox("Show distance field", &mShowDistanceField);
		}

		Raymarcher2D::RenderImGuiParameters();
	}

	void FractalRaymarcher::_Process(const float pDelta)
	{
		if (mAutoCamera)
		{
			mCameraState += pDelta;
			mZoom = Math::Lerp(0.f, maxZoom[mFractal], (std::cos((mCameraState + Math::PI) / MOVEMENT_DURATION + Math::PI) + 1.f) * 0.5f);
			mIterations = (int)std::round(Math::Lerp(0.f, (float)maxIterations[mFractal], mZoom / maxZoom[mFractal]));
		}
		else
		{
			Raymarcher2D::_Process(pDelta);
		}
	}

	void FractalRaymarcher::_Render(const float pDelta)
	{
		mShader->SetUniform1f("u_Time", Time::GetElapsedTime());
		mShader->SetUniform1i("u_Fractal", mFractal);
		mShader->SetUniform1i("u_Iterations", mIterations);
		mShader->SetUniform1i("u_ShowDistanceField", mShowDistanceField);
		Raymarcher2D::_Render(pDelta);
	}

	void FractalRaymarcher::_OnEvent(Event &pEvent)
	{
		Raymarcher2D::_OnEvent(pEvent);

		if (pEvent.handled)
		{
			return;
		}

		if (pEvent.GetEventType() == EventType::KeyReleased)
		{
			KeyReleasedEvent &lKREvent = pEvent.Cast<KeyReleasedEvent>();

			switch (lKREvent.GetKeyCode())
			{
				case (int)KeyCode::Up:
					mIterations = Math::Clamp(mIterations + 1, 0, 100);
					lKREvent.handled = true;
					break;
				case (int)KeyCode::Down:
					mIterations = Math::Clamp(mIterations - 1, 0, 100);
					lKREvent.handled = true;
					break;
				case (int)KeyCode::F7:
					mAutoCamera = !mAutoCamera;

					if (mAutoCamera)
					{
						/* float lRatio = mZoom / maxZoom[mFractal]; */
						/* mCameraState = Math::Abs(MOVEMENT_DURATION / Math::PI * (std::acos(lRatio * 2.f - 1.f) - Math::PI)); */
						mCameraState = 0.f;
					}

					lKREvent.handled = true;
					break;
				default:
					break;
			}
		}
	}
}

