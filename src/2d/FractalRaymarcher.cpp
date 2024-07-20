#include "FractalRaymarcher.hpp"
#include "Engine/Time.hpp"
#include "Engine/events/Event.hpp"
#include "Engine/events/KeyCodes.h"
#include "Engine/events/KeyboardEvent.hpp"
#include "imgui/imgui.h"

using namespace GL;

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

	FractalRaymarcher::FractalRaymarcher()
		: Raymarcher2D(), mFractal(SierpinskiTriangle), mIterations(3), mShowDistanceField(false)
	{
		mShader.reset(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/2d/fractals.glsl"));
		InitShader();
	}

	void FractalRaymarcher::RenderImGuiParameters()
	{
		if (ImGui::CollapsingHeader("Fractals"))
		{
			ImGui::Combo("Fractal", &mFractal, fractals, Max);
			ImGui::SliderInt("Iterations", &mIterations, 0, 10);
			ImGui::Checkbox("Show distance field", &mShowDistanceField);
		}

		Raymarcher2D::RenderImGuiParameters();
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

		if (pEvent.GetEventType() == EventType::KeyPressed)
		{
			KeyPressedEvent &lKPEvent = pEvent.Cast<KeyPressedEvent>();

			if (lKPEvent.GetKeyCode() == (int)KeyCode::Up)
			{
				mIterations = Math::Clamp(mIterations + 1, 0, 10);
				lKPEvent.handled = true;
			}
			else if (lKPEvent.GetKeyCode() == (int)KeyCode::Down)
			{
				mIterations = Math::Clamp(mIterations - 1, 0, 10);
				lKPEvent.handled = true;
			}
		}
	}
}

