import compat;
import version;

import std;

auto main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[]) -> int {
    std::println("{:=^40}", "Hello, C++23 world!");
    std::println("This is C++23 Playground {:M}", version::Version{0, 1, 0});
    return compat::exit_success;
}
