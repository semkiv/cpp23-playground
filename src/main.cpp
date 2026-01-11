// FIXME: ideally I'd prefer this to come after `import`, but G++ fails to compile such setup
#include <cstdlib>

import std;

auto main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) -> int {
    auto jt = std::jthread{[] { std::println("Hello, C++23 world!"); }};

    return EXIT_SUCCESS;
}
