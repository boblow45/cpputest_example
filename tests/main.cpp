#include "CppUTest/CommandLineTestRunner.h"

int main(int ac, char **av)
{
    CommandLineTestRunner::RunAllTests(ac, av);
    return 0;
}

// #include <iostream>
// #include "defines.hpp"
// using namespace std;

// int main()
// {
//     cout << "Hello World!\n";
//     return 0;
// }