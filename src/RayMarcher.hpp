#pragma once

#include "Engine/Object.hpp"
#include "Engine/events/Event.hpp"
#include "Engine/utils/Memory.hpp"
#include "math/Vector2.hpp"
#include "math/Vector3.hpp"
#include "GLCore/core/buffers/VertexArray.hpp"
#include "GLCore/core/buffers/IndexBuffer.hpp"
#include "GLCore/core/Shader.hpp"

using namespace Engine;

enum class RaymarcherType
{
	/* Default, */
	Shapes,
	Blend,
	Repetition,
	/* MengerSponge, */
	/* FailedMengerSponge, */
	/* SierpinskiTetrahedron, */
	/* JerusalemCube, */
	/* CantorDust, */
	Fractals,
};

class Raymarcher : public Object
{
private:
	// -- OpenGL --
	static constexpr float sVertices[4 * 2] = {
		-1.f, -1.f,
		 1.f, -1.f,
		 1.f,  1.f,
		-1.f,  1.f,
	};

	static constexpr unsigned int sIndices[2 * 3] = {
		0, 1, 2,
		0, 2, 3,
	};

	GL::VertexArray mVArray;
	GL::VertexBuffer mVBuffer;
	GL::VertexBufferLayout mLayout;
	GL::IndexBuffer mIBuffer;

	// -- Camera control --
	Math::Vector3F mCameraPos;
	Math::Vector2F mCameraRot;
	float mCameraSpeed;
	float mCameraSpeedMultiplier;
	float mCameraRotationMultiplier;
	Math::Vector2F mMousePos;

	// -- Framerate --
	float mDelta;
	float mFramerate;
	float mFramerateUpdateDelay;

protected:
	// -- Parameters --
	int mIterations;
	float mMinDistance;
	float mMaxDistance;
	bool mDebugIterations;
	Math::Vector3F mLightColor;
	int mLightBounces;

protected:
	Memory::UniquePtr<GL::Shader> mShader;

	void InitShader();
	virtual void RenderImGuiParameters();
	virtual void _Process(const float pDelta) override;
	virtual void _Render(const float pDelta) override;
	void _RenderImGUI(const float pDelta) override;
	virtual void _OnEvent(Event &pEvent) override;

public:
	Raymarcher();
	virtual ~Raymarcher();

	inline virtual const char *GetName() const override
	{
		return "RayMarcher";
	}

	virtual RaymarcherType GetType() const = 0;
};

#define RAYMARCHER(Type)\
	inline RaymarcherType GetType() const override { return RaymarcherType::Type; }\
	inline const char *GetName() const override { return #Type; }

