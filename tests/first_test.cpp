#include "CppUTest/TestHarness.h"

using namespace std;

TEST_GROUP(FirstTestGroup){};

TEST(FirstTestGroup, FirstTest)
{
    FAIL("Fail me!");
}

TEST(FirstTestGroup, SecondTest)
{
    STRCMP_EQUAL("world", "world");
}