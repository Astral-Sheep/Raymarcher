#include "RayMarcher.hpp"
#include "Engine/Application.hpp"
#include "Engine/Input.hpp"
#include "GLCore/core/GLRenderer.hpp"

using namespace GL;
using namespace Math;

RayMarcher::RayMarcher()
	: mVArray(), mVBuffer(sVertices, sizeof(sVertices)), mLayout(),
	mIBuffer(sIndices, 2 * 3),
	mShader(Shader::FromGLSLTextFiles("res/vertex.glsl", "res/fragment.glsl")),
	mCameraPos(0.f), mCameraRot(0.f), mCameraSpeed(2.f)
{
	mLayout.Push<float>(2);
	mVArray.AddBuffer(mVBuffer, mLayout);
	mShader->SetUniform1f("u_AspectRatio", (float)Application::Get().GetWindow().GetWidth() / Application::Get().GetWindow().GetHeight());
}

RayMarcher::~RayMarcher()
{

}

void RayMarcher::_Process(const float pDelta)
{
	Vector2 mHorizontalVelocity = Vector2(
		Input::IsKeyPressed(KeyCode::D) - Input::IsKeyPressed(KeyCode::A),
		Input::IsKeyPressed(KeyCode::W) - Input::IsKeyPressed(KeyCode::S)
	).Normalized();

	Vector3 mVelocity = Vector3(
		mHorizontalVelocity.x,
		Input::IsKeyPressed(KeyCode::Space) - Input::IsKeyPressed(KeyCode::LeftShift),
		mHorizontalVelocity.y
	) * mCameraSpeed * pDelta;

	mCameraPos += mVelocity;
}

void RayMarcher::_Render(const float pDelta)
{
	mShader->SetUniform3f("u_CameraPos", mCameraPos.x, mCameraPos.y, mCameraPos.z);
	mShader->SetUniform2f("u_CameraRot", mCameraRot.x, mCameraRot.y);
	GLRenderer::DrawTriangles(mVArray, mIBuffer, *mShader);
}

