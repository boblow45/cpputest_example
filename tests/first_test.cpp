#include <cstdint>

#include "CppUTest/TestHarness.h"
#include "math.hpp"

using namespace std;

TEST_GROUP(FirstTestGroup){};

TEST(FirstTestGroup, TestAdd)
{
    uint32_t x;
    x = add(1, 2);
    CHECK_EQUAL(3, x);
    x = add(1, 0);
    CHECK_EQUAL(1, x);
    x = add(0, 1);
    CHECK_EQUAL(1, x);
}