#include "RayMarcher.hpp"
#include "Engine/Application.hpp"
#include "Engine/Time.hpp"
#include "Engine/Window.hpp"
#include "Engine/events/KeyCodes.h"
#include "Engine/events/KeyboardEvent.hpp"
#include "Engine/events/WindowEvent.hpp"
#include "math/Math.hpp"
#include "GLCore/core/GLRenderer.hpp"
#include "GLFW/glfw3.h"
#include "imgui/imgui.h"

using namespace GL;
using namespace Math;

Raymarcher::Raymarcher()
	: mVArray(), mVBuffer(sVertices, sizeof(sVertices)), mLayout(),
	mIBuffer(sIndices, 2 * 3),
	mShader(nullptr),
	mShowImGui(true),
	mDelta(0.f), mFramerate(0.f), mFramerateUpdateDelay(0.1f)
{
	mLayout.Push<float>(2);
	mVArray.AddBuffer(mVBuffer, mLayout);
}

Raymarcher::~Raymarcher() {}

void Raymarcher::InitShader()
{
	Window &lWindow = Application::Get().GetWindow();
	mShader->SetUniform2i("u_ScreenSize", lWindow.GetWidth(), lWindow.GetHeight());
}

void Raymarcher::RenderImGuiParameters() {}

void Raymarcher::_Render(const float pDelta)
{
	if (!mShader)
	{
		return;
	}

	GLRenderer::DrawTriangles(mVArray, mIBuffer, *mShader);
}

void Raymarcher::_RenderImGUI(const float pDelta)
{
	if (!mShowImGui)
	{
		return;
	}

	constexpr float WINDOW_WIDTH = 500.f;
	mDelta += pDelta;

	if (mDelta >= mFramerateUpdateDelay)
	{
		mFramerate = Time::GetFrameRate();
		mDelta = Math::EuclidianRemainder(mDelta, mFramerateUpdateDelay);
	}

	ImGui::Begin("Raymarcher", nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove);
	ImGui::SetWindowSize(ImVec2(WINDOW_WIDTH, 250.f));
	ImGui::SetWindowPos(ImVec2(Application::Get().GetWindow().GetWidth() - 25.f - WINDOW_WIDTH, 25.f));

	ImGui::Text("Frame rate: %.1f fps", mFramerate);

	ImGui::Text("Options:");
	ImGui::Separator();
	RenderImGuiParameters();
	ImGui::End();
}

void Raymarcher::_OnEvent(Event &pEvent)
{
	if (pEvent.GetEventType() == EventType::WindowResize)
	{
		WindowResizeEvent &lWREvent = pEvent.Cast<WindowResizeEvent>();
		mShader->SetUniform2i("u_ScreenSize", lWREvent.GetWidth(), lWREvent.GetHeight());
		lWREvent.handled = true;
	}
	else if (pEvent.GetEventType() == EventType::KeyReleased)
	{
		KeyReleasedEvent &lKREvent = pEvent.Cast<KeyReleasedEvent>();

		if (lKREvent.GetKeyCode() == (int)KeyCode::F6)
		{
			mShowImGui = !mShowImGui;
		}
	}
}

