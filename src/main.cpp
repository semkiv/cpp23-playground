// FIXME: ideally I'd prefer this to come after `import`, but G++ fails to compile such setup
#include <cstdlib>

import std;

auto main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) -> int {
    const auto greeter_thread = std::jthread{[] {
        // clang-tidy does not realize that 'import std' is sufficient for 'std::println' and
        // recommends including '<print>'
        // NOLINTNEXTLINE(misc-include-cleaner)
        std::println("Hello, C++23 world!");
    }};

    return EXIT_SUCCESS;
}
