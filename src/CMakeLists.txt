target_sources(${PROJECT_NAME} PRIVATE
	Main.cpp
	Manager.cpp
	RayMarcher.cpp
	DefaultRaymarcher.cpp
	MengerSponge.cpp
	FailedMengerSponge.cpp
)

target_include_directories(${PROJECT_NAME} PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}
)

