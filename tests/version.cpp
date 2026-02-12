import compat;
import version;

import std;

// GTest does not get along with 'import std', so canot use that
int main() {
    {
        auto ver = version::Version{0, 1, 2};

        if (ver.major() != 0) {
            return compat::exit_failure;
        }

        if (const auto minor = ver.minor(); !minor || *minor != 1) {
            return compat::exit_failure;
        }

        if (const auto patch = ver.patch(); !patch || *patch != 2) {
            return compat::exit_failure;
        }
    }

    {
        auto ver = version::Version{0, 1};

        if (ver.major() != 0) {
            return compat::exit_failure;
        }

        if (const auto minor = ver.minor(); !minor.has_value() || *minor != 1) {
            return compat::exit_failure;
        }

        if (ver.patch().has_value()) {
            return compat::exit_failure;
        }
    }

    {
        auto ver = version::Version{2};

        if (ver.major() != 2) {
            return compat::exit_failure;
        }

        if (ver.minor().has_value()) {
            return compat::exit_failure;
        }

        if (ver.patch().has_value()) {
            return compat::exit_failure;
        }
    }

    {
        const auto ver = version::Version{0, 1, 2};

        if (std::format("{}", ver) != "0.1.2") {
            return compat::exit_failure;
        }

        if (std::format("{:#}", ver) != "v0.1.2") {
            return compat::exit_failure;
        }

        if (std::format("{:M}", ver) != "0") {
            return compat::exit_failure;
        }

        if (std::format("{:#M}", ver) != "v0") {
            return compat::exit_failure;
        }

        if (std::format("{:m}", ver) != "0.1") {
            return compat::exit_failure;
        }

        if (std::format("{:#m}", ver) != "v0.1") {
            return compat::exit_failure;
        }
    }
}
