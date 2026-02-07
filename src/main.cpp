// FIXME: ideally I'd prefer this to come after `import`, but g++ fails to compile such setup
#include <cstdlib>

import std;

auto main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) -> int {
    std::println("{:=^40}", "Hello, C++23 world!");

    return EXIT_SUCCESS;
}
