export module version;

import std;

export namespace version {
    class Version final {
    public:
        constexpr Version(int major) : m_major{major} {}
        constexpr Version(int major, int minor) : m_major{major}, m_minor{minor} {}
        constexpr Version(int major, int minor, int patch)
            : m_major{major}, m_minor{minor}, m_patch{patch} {}

        constexpr int major() const {
            return m_major;
        }

        constexpr std::optional<int> minor() const {
            return m_minor;
        }

        constexpr std::optional<int> patch() const {
            return m_patch;
        }

    private:
        int m_major = 0;
        std::optional<int> m_minor = {};
        std::optional<int> m_patch = {};
    };
} // namespace version

template<>
struct std::formatter<version::Version> {
    constexpr auto parse(auto& context) {
        auto itr = std::begin(context);
        const auto endItr = std::cend(context);
        for (; itr != endItr && *itr != '}'; ++itr) {
            switch (const auto specifier = *itr; specifier) {
            case 'M':
                m_mode = Mode::Major;
                break;
            case 'm':
                m_mode = Mode::MajorMinor;
                break;
            case '#':
                m_with_prefix = true;
                break;
            default:
                throw std::format_error{std::format("Unexpected format specifier '{}'", specifier)};
            }
        }

        return itr;
    }

    constexpr auto format(const version::Version& version, auto& context) const {
        auto out = context.out();

        if (m_with_prefix) {
            out = std::format_to(out, "{}", 'v');
        }

        switch (m_mode) {
        case Mode::Major:
            return format_to(out, "{}", version.major());
        case Mode::MajorMinor:
            return format_to(out, "{}.{}", version.major(), *version.minor());
        case Mode::Full:
            return format_to(out, "{}.{}.{}", version.major(), *version.minor(), *version.patch());
        }

        std::unreachable();
    }

private:
    enum class Mode : std::uint8_t {
        Major,
        MajorMinor,
        Full,
    };

    Mode m_mode = Mode::Full;
    bool m_with_prefix = false;
};
