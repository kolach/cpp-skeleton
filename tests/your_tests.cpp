#include <gtest/gtest.h>
#include <your_library.hpp>

TEST(YourTest, SimpleTest) {
    EXPECT_EQ (6, your_function(1, 2, 3) );
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
