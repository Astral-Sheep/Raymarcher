#include "Engine/Application.hpp"

using namespace Engine;

int main()
{
	std::unique_ptr<Application> app(new Application("Ray Marcher"));
	app->Run();
	return 0;
}

