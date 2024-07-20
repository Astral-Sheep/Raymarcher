#include "Manager.hpp"
#include "Engine/Application.hpp"
#include "Engine/utils/Memory.hpp"

using namespace Engine;

int main()
{
	std::unique_ptr<Application> app(new Application({ "Ray Marcher" }));
	Memory::SharedPtr<Manager> lManager(new Manager());
	app->GetRoot().AddObject(*lManager);
	app->Run();
	return 0;
}

