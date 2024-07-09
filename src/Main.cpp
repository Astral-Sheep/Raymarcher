#include "Manager.hpp"
#include "Engine/Application.hpp"

using namespace Engine;

int main()
{
	std::unique_ptr<Application> app(new Application({ "Ray Marcher" }));
	std::shared_ptr<Manager> lManager(new Manager());
	app->GetRoot().AddObject(*lManager);
	app->Run();
	return 0;
}

