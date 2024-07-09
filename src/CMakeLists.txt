target_sources(${PROJECT_NAME} PRIVATE
	Main.cpp
	Manager.cpp
	RayMarcher.cpp
	# DefaultRaymarcher.cpp
	ShapesRaymarcher.cpp
	BlendRaymarcher.cpp
	Repetition.cpp
	# MengerSponge.cpp
	# FailedMengerSponge.cpp
	# SierpinskiTetrahedron.cpp
	# JerusalemCube.cpp
	FractalRaymarcher.cpp
)

target_include_directories(${PROJECT_NAME} PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}
)

