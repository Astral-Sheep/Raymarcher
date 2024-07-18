target_sources(${PROJECT_NAME} PRIVATE
	Main.cpp
	Manager.cpp
	RayMarcher.cpp
	2d/Raymarcher2D.cpp
	2d/ShapesRaymarcher.cpp
	2d/BlendRaymarcher.cpp
	2d/RepetitionRaymarcher.cpp
	2d/FractalRaymarcher.cpp
	3d/Raymarcher3D.cpp
	3d/ShapesRaymarcher.cpp
	3d/BlendRaymarcher.cpp
	3d/RepetitionRaymarcher.cpp
	3d/FractalRaymarcher.cpp
)

target_include_directories(${PROJECT_NAME} PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}
)

