#include "RayMarcher.hpp"
#include "Engine/Application.hpp"

using namespace Engine;

int main()
{
	std::unique_ptr<Application> app(new Application("Ray Marcher"));
	std::shared_ptr<RayMarcher> rayMarcher(new RayMarcher);
	app->GetRoot().AddObject(*rayMarcher);
	app->Run();
	return 0;
}

