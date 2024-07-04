#pragma once

#include "Engine/Object.hpp"
#include "Engine/events/Event.hpp"
#include "math/Vector2.hpp"
#include "math/Vector3.hpp"
#include "GLCore/core/buffers/VertexArray.hpp"
#include "GLCore/core/buffers/IndexBuffer.hpp"
#include "GLCore/core/Shader.hpp"

using namespace Engine;

class RayMarcher : public Object
{
private:
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
	std::unique_ptr<GL::Shader> mShader;

	Math::Vector3 mCameraPos;
	Math::Vector2 mCameraRot;
	float mCameraSpeed;

public:
	RayMarcher();
	~RayMarcher();

	void _Process(const float pDelta) override;
	void _Render(const float pDelta) override;

	inline const char *GetName() const override
	{
		return "RayMarcher";
	}
};

