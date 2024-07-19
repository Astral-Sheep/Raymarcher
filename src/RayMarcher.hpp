#pragma once

#include "Engine/Object.hpp"
#include "Engine/events/Event.hpp"
#include "Engine/utils/Memory.hpp"
#include "GLCore/core/buffers/VertexArray.hpp"
#include "GLCore/core/buffers/IndexBuffer.hpp"
#include "GLCore/core/Shader.hpp"

using namespace Engine;

enum class RaymarcherType
{
	Shapes2D,
	Blend2D,
	Repetition2D,
	Fractals2D,
	Shapes3D,
	Blend3D,
	Repetition3D,
	Fractals3D,
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

	// -- Framerate --
	float mDelta;
	float mFramerate;
	float mFramerateUpdateDelay;

	bool mShowImGui;

protected:
	Memory::UniquePtr<GL::Shader> mShader;

protected:
	void InitShader();
	virtual void RenderImGuiParameters();
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

