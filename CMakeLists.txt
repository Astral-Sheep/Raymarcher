cmake_minimum_required(VERSION 3.15)
project(Raymarcher VERSION 1.0)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${PROJECT_NAME} src/Main.cpp)
add_subdirectory(src)

target_include_directories(${PROJECT_NAME} PRIVATE
	${CMAKE_SOURCE_DIR}/dependencies/Engine/include
	${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/MathLib/include
	${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/include
	${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLEW/include
	${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLFW/include
)

list(APPEND DEFINITIONS
	GLEW_STATIC
	USE_IMGUI
)

list(APPEND LIBRARIES
	opengl32.lib
	User32.lib
	Gdi32.lib
	Shell32.lib
)

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(ARCH64 ON)

	list(APPEND LIBRARIES
		${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLFW/lib-vc2019/x64/glfw3.lib
		${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLEW/lib/Release/x64/glew32s.lib
	)
else()
	set(ARCH64 OFF)

	list(APPEND LIBRARIES
		${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLFW/lib-vc2019/Win32/glfw3.lib
		${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/dependencies/GLEW/lib/Release/Win32/glew32s.lib
	)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Release")
	list(APPEND DEFINITIONS RELEASE)

	if (ARCH64)
		list(APPEND LIBRARIES
			${CMAKE_SOURCE_DIR}/dependencies/Engine/lib/x64/Release/ImGui/Engines.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/MathLib/lib/x64/Release/MathLibs.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/lib/x64/Release/GLCores.lib
		)
	else()
		list(APPEND LIBRARIES
			${CMAKE_SOURCE_DIR}/dependencies/Engine/lib/Win32/Release/ImGui/Engines.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/MathLib/lib/Win32/Release/MathLibs.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/lib/Win32/Release/GLCores.lib
		)
	endif()
else()
	list(APPEND DEFINITIONS
		DEBUG
		ENGINE_DEBUG
		GLCORE_DEBUG
		MATH_DEBUG
	)

	if (ARCH64)
		list(APPEND LIBRARIES
			${CMAKE_SOURCE_DIR}/dependencies/Engine/lib/x64/Debug/ImGui/Engines.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/MathLib/lib/x64/Debug/MathLibs.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/lib/x64/Debug/GLCores.lib
		)
	else()
		list(APPEND LIBRARIES
			${CMAKE_SOURCE_DIR}/dependencies/Engine/lib/Win32/Debug/ImGui/Engines.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/MathLib/lib/Win32/Debug/MathLibs.lib
			${CMAKE_SOURCE_DIR}/dependencies/Engine/dependencies/GLCore/lib/Win32/Debug/GLCores.lib
		)
	endif()
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE ${DEFINITIONS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRARIES})

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /ignore:4099")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /ignore:4099")
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /ignore:4099")

