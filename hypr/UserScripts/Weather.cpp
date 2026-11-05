// Weather.cpp
// C++ replacement for Weather.py — fetches from Open-Meteo APIs
// Outputs Waybar-compatible JSON
//
// Build: see Makefile  (g++ -std=c++17 -O2 -o Weather Weather.cpp -lcurl)
// Dependencies: libcurl4-openssl-dev, nlohmann-json3-dev
//   sudo apt install libcurl4-openssl-dev nlohmann-json3-dev

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <optional>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>

// POSIX network (for offline check)
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <unistd.h>

#include <curl/curl.h>
#include <nlohmann/json.hpp>

namespace fs = std::filesystem;
using json   = nlohmann::json;

// ============================================================
//  Configuration
// ============================================================

struct Config {
    std::string units        = "imperial";   // "metric" | "imperial"
    int         cache_ttl    = 300;          // seconds
    std::string manual_place = "";           // set city here, e.g. "Concord, NH, US"
    std::string env_lat, env_lon, env_place;
    std::string loc_icon     = "\xF0\x9F\x93\x8D"; // 📍 (UTF-8)
    std::string lang         = "en";
    bool        tooltip_markup = false;
    bool        debug          = false;
    std::string ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                     "(KHTML, like Gecko) Chrome/128.0 Safari/537.36";
    int timeout = 8;

    fs::path cache_dir, api_cache_path, simple_cache_path;
};

static std::string getenv_str(const char* name, const char* def = "") {
    const char* v = std::getenv(name);
    return v ? std::string(v) : std::string(def);
}

static bool getenv_bool(const char* name, bool def = false) {
    std::string v = getenv_str(name);
    if (v.empty()) return def;
    std::transform(v.begin(), v.end(), v.begin(), ::tolower);
    return v == "1" || v == "true" || v == "yes";
}

Config load_config() {
    Config c;

    c.units = getenv_str("WEATHER_UNITS", "imperial");
    std::transform(c.units.begin(), c.units.end(), c.units.begin(), ::tolower);

    try { c.cache_ttl = std::stoi(getenv_str("WEATHER_CACHE_TTL", "300")); }
    catch (...) { c.cache_ttl = 300; }

    c.env_lat   = getenv_str("WEATHER_LAT");
    c.env_lon   = getenv_str("WEATHER_LON");
    c.env_place = getenv_str("WEATHER_PLACE");
    c.lang      = getenv_str("WEATHER_LANG", "en");

    std::string icon = getenv_str("WEATHER_LOC_ICON");
    if (!icon.empty()) c.loc_icon = icon;

    c.tooltip_markup = getenv_bool("WEATHER_TOOLTIP_MARKUP", false);
    c.debug          = getenv_bool("WEATHER_DEBUG", false);

    std::string home = getenv_str("HOME", "/tmp");
    c.cache_dir         = fs::path(home) / ".cache";
    c.api_cache_path    = c.cache_dir / "open_meteo_cache.json";
    c.simple_cache_path = c.cache_dir / ".weather_cache";

    return c;
}

// ============================================================
//  Logging
// ============================================================

static bool g_debug = false;

static void log_debug(const std::string& msg) {
    if (g_debug) std::cerr << "[debug] " << msg << "\n";
}

// ============================================================
//  Weather icons & WMO tables
// ============================================================

// Nerd Font / Unicode icon strings (UTF-8 encoded)
static const std::map<std::string, std::string> ICONS = {
    {"sunnyDay",         "\xF3\xB0\x96\x99"}, // U+F0599 (nf-weather-day_sunny)
    {"clearNight",       "\xF3\xB0\x96\x94"}, // U+F0594 (nf-weather-night_clear)
    {"cloudyFoggyDay",   "\xEE\x8C\x83"},     // U+E303  (nf-weather-cloudy)
    {"cloudyFoggyNight", "\xEE\x8D\x86"},     // U+E346  (nf-weather-night_cloudy)
    {"rainyDay",         "\xEE\x8C\x86"},     // U+E306  (nf-weather-rain)
    {"rainyNight",       "\xEE\x8C\xB1"},     // U+E331  (nf-weather-night_rain)
    {"snowyIcyDay",      "\xEE\x8C\x8A"},     // U+E30A  (nf-weather-snow)
    {"snowyIcyNight",    "\xEE\x8C\xA7"},     // U+E327  (nf-weather-night_snow)
    {"severe",           "\xEE\x8D\xAE"},     // U+E36E  (nf-weather-storm_showers)
    {"default",          "\xEE\x8C\x82"},     // U+E302  (nf-weather-cloudy_gusts)
};

static const std::string& icon(const std::string& key) {
    auto it = ICONS.find(key);
    return it != ICONS.end() ? it->second : ICONS.at("default");
}

static std::string wmo_to_icon(int code, bool is_day) {
    if (code == 0)
        return is_day ? icon("sunnyDay") : icon("clearNight");
    if (code == 1 || code == 2 || code == 3 || code == 45 || code == 48)
        return is_day ? icon("cloudyFoggyDay") : icon("cloudyFoggyNight");
    if (code == 51 || code == 53 || code == 55 ||
        code == 61 || code == 63 || code == 65 ||
        code == 80 || code == 81 || code == 82)
        return is_day ? icon("rainyDay") : icon("rainyNight");
    if (code == 56 || code == 57 || code == 66 || code == 67 ||
        code == 71 || code == 73 || code == 75 || code == 77 ||
        code == 85 || code == 86)
        return is_day ? icon("snowyIcyDay") : icon("snowyIcyNight");
    if (code == 95 || code == 96 || code == 99)
        return icon("severe");
    return icon("default");
}

static std::string wmo_to_status(int code) {
    static const std::map<int, std::string> WMO = {
        {0,"Clear sky"},{1,"Mainly clear"},{2,"Partly cloudy"},{3,"Overcast"},
        {45,"Fog"},{48,"Depositing rime fog"},
        {51,"Light drizzle"},{53,"Moderate drizzle"},{55,"Dense drizzle"},
        {56,"Freezing drizzle"},{57,"Freezing drizzle"},
        {61,"Light rain"},{63,"Moderate rain"},{65,"Heavy rain"},
        {66,"Freezing rain"},{67,"Freezing rain"},
        {71,"Slight snow"},{73,"Moderate snow"},{75,"Heavy snow"},{77,"Snow grains"},
        {80,"Rain showers"},{81,"Rain showers"},{82,"Violent rain showers"},
        {85,"Snow showers"},{86,"Heavy snow showers"},
        {95,"Thunderstorm"},{96,"Thunderstorm w/ hail"},{99,"Thunderstorm w/ hail"},
    };
    auto it = WMO.find(code);
    return it != WMO.end() ? it->second : "Unknown";
}

// ============================================================
//  Network connectivity check (raw TCP, no subprocess)
// ============================================================

static bool tcp_connect(const char* ip, int port, int timeout_ms) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return false;

    // Set non-blocking
    int flags = fcntl(fd, F_GETFL, 0);
    fcntl(fd, F_SETFL, flags | O_NONBLOCK);

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(static_cast<uint16_t>(port));
    inet_pton(AF_INET, ip, &addr.sin_addr);

    connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr));

    fd_set wfds;
    FD_ZERO(&wfds);
    FD_SET(fd, &wfds);
    timeval tv{timeout_ms / 1000, (timeout_ms % 1000) * 1000};
    int rc = select(fd + 1, nullptr, &wfds, nullptr, &tv);

    close(fd);
    return rc > 0;
}

static bool check_network() {
    return tcp_connect("8.8.8.8",  80, 2000) ||
           tcp_connect("1.1.1.1",  80, 2000) ||
           tcp_connect("9.9.9.9",  80, 2000);
}

// ============================================================
//  HTTP via libcurl
// ============================================================

static size_t curl_write_cb(char* ptr, size_t size, size_t nmemb, std::string* s) {
    s->append(ptr, size * nmemb);
    return size * nmemb;
}

static std::optional<std::string> http_get(const std::string& url, const Config& cfg,
                                            const std::string& extra_ua = "") {
    CURL* curl = curl_easy_init();
    if (!curl) return std::nullopt;

    std::string body;
    std::string agent = extra_ua.empty() ? cfg.ua : extra_ua;

    curl_easy_setopt(curl, CURLOPT_URL,            url.c_str());
    curl_easy_setopt(curl, CURLOPT_USERAGENT,       agent.c_str());
    curl_easy_setopt(curl, CURLOPT_TIMEOUT,         static_cast<long>(cfg.timeout));
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION,  1L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION,   curl_write_cb);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA,       &body);

    CURLcode res = curl_easy_perform(curl);
    long     http_code = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK || http_code < 200 || http_code >= 300) {
        log_debug("HTTP GET failed: " + url + " code=" + std::to_string(http_code));
        return std::nullopt;
    }
    return body;
}

static std::optional<json> http_get_json(const std::string& url, const Config& cfg,
                                          const std::string& extra_ua = "") {
    auto body = http_get(url, cfg, extra_ua);
    if (!body) return std::nullopt;
    try {
        return json::parse(*body);
    } catch (...) {
        log_debug("JSON parse error for: " + url);
        return std::nullopt;
    }
}

// Simple URL param builder (encodes spaces as %20, basic chars)
static std::string url_encode(const std::string& s) {
    CURL* curl = curl_easy_init();
    if (!curl) return s;
    char* enc = curl_easy_escape(curl, s.c_str(), static_cast<int>(s.size()));
    std::string result = enc ? std::string(enc) : s;
    if (enc) curl_free(enc);
    curl_easy_cleanup(curl);
    return result;
}

// Build query string from key/value pairs
static std::string build_url(const std::string& base,
                              const std::vector<std::pair<std::string,std::string>>& params) {
    std::string url = base + "?";
    for (size_t i = 0; i < params.size(); ++i) {
        if (i) url += "&";
        url += params[i].first + "=" + url_encode(params[i].second);
    }
    return url;
}

// ============================================================
//  Cache
// ============================================================

static void ensure_cache_dir(const Config& cfg) {
    try { fs::create_directories(cfg.cache_dir); }
    catch (const std::exception& e) {
        std::cerr << "Error creating cache dir: " << e.what() << "\n";
    }
}

static std::optional<json> read_cache(const Config& cfg) {
    if (!fs::exists(cfg.api_cache_path)) return std::nullopt;
    try {
        std::ifstream f(cfg.api_cache_path);
        json data = json::parse(f);

        if (data.value("units", "") != cfg.units) {
            log_debug("Cache units mismatch, ignoring.");
            return std::nullopt;
        }
        double ts = data.value("timestamp", 0.0);
        double now = std::chrono::duration<double>(
            std::chrono::system_clock::now().time_since_epoch()).count();
        if ((now - ts) <= cfg.cache_ttl) return data;
    } catch (const std::exception& e) {
        std::cerr << "Error reading cache: " << e.what() << "\n";
    }
    return std::nullopt;
}

static void write_cache(const json& forecast, const std::optional<json>& aqi,
                        const std::string& place, const Config& cfg) {
    try {
        ensure_cache_dir(cfg);
        json data;
        data["forecast"]  = forecast;
        data["aqi"]       = aqi.value_or(nullptr);
        data["place"]     = place;
        data["units"]     = cfg.units;
        data["timestamp"] = std::chrono::duration<double>(
            std::chrono::system_clock::now().time_since_epoch()).count();
        std::ofstream f(cfg.api_cache_path);
        f << data.dump();
    } catch (const std::exception& e) {
        std::cerr << "Error writing cache: " << e.what() << "\n";
    }
}

static void write_simple_cache(const std::string& text, const Config& cfg) {
    try {
        ensure_cache_dir(cfg);
        std::ofstream f(cfg.simple_cache_path);
        f << text;
    } catch (const std::exception& e) {
        std::cerr << "Error writing simple cache: " << e.what() << "\n";
    }
}

// ============================================================
//  Coordinate resolution
// ============================================================

static std::optional<std::pair<double,double>> geocode_place(const std::string& name,
                                                              const Config& cfg) {
    auto url = build_url("https://geocoding-api.open-meteo.com/v1/search", {
        {"name", name}, {"count", "1"}, {"language", cfg.lang}, {"format", "json"}
    });
    auto data = http_get_json(url, cfg);
    if (!data) return std::nullopt;
    try {
        auto& results = (*data)["results"];
        if (results.is_array() && !results.empty()) {
            double lat = results[0].at("latitude").get<double>();
            double lon = results[0].at("longitude").get<double>();
            return std::make_pair(lat, lon);
        }
    } catch (...) {}
    return std::nullopt;
}

// Try to extract lat/lon from ipwho.is response
static std::optional<std::pair<double,double>> coords_from_ipwho(const Config& cfg) {
    auto data = http_get_json("https://ipwho.is/", cfg);
    if (!data) return std::nullopt;
    try {
        if ((*data).value("success", false)) {
            double lat = (*data).at("latitude").get<double>();
            double lon = (*data).at("longitude").get<double>();
            return std::make_pair(lat, lon);
        }
    } catch (...) {}
    return std::nullopt;
}

static std::optional<std::pair<double,double>> coords_from_ipapi(const Config& cfg) {
    auto data = http_get_json("https://ipapi.co/json", cfg);
    if (!data) return std::nullopt;
    try {
        double lat = (*data).at("latitude").get<double>();
        double lon = (*data).at("longitude").get<double>();
        return std::make_pair(lat, lon);
    } catch (...) {}
    return std::nullopt;
}

static std::optional<std::pair<double,double>> coords_from_ipinfo(const Config& cfg) {
    auto data = http_get_json("https://ipinfo.io/json", cfg);
    if (!data) return std::nullopt;
    try {
        std::string loc = (*data).at("loc").get<std::string>();
        auto comma = loc.find(',');
        if (comma == std::string::npos) return std::nullopt;
        double lat = std::stod(loc.substr(0, comma));
        double lon = std::stod(loc.substr(comma + 1));
        return std::make_pair(lat, lon);
    } catch (...) {}
    return std::nullopt;
}

static std::pair<double,double> get_coords(const Config& cfg) {
    // 1) Manual place → geocode
    if (!cfg.manual_place.empty()) {
        auto c = geocode_place(cfg.manual_place, cfg);
        if (c) return *c;
    }

    // 2) Explicit env coordinates
    if (!cfg.env_lat.empty() && !cfg.env_lon.empty()) {
        try { return {std::stod(cfg.env_lat), std::stod(cfg.env_lon)}; }
        catch (...) { std::cerr << "Invalid WEATHER_LAT/LON\n"; }
    }

    // 3) Env place → geocode
    if (!cfg.env_place.empty()) {
        auto c = geocode_place(cfg.env_place, cfg);
        if (c) return *c;
    }

    // 4) Cached coordinates
    auto cached = read_cache(cfg);
    if (cached) {
        try {
            double lat = (*cached)["forecast"].at("latitude").get<double>();
            double lon = (*cached)["forecast"].at("longitude").get<double>();
            return {lat, lon};
        } catch (...) {}
    }

    // 5) IP-based geolocation
    if (auto c = coords_from_ipwho(cfg))  return *c;
    if (auto c = coords_from_ipapi(cfg))  return *c;
    if (auto c = coords_from_ipinfo(cfg)) return *c;

    std::cerr << "All geolocation methods failed, defaulting to 0,0\n";
    return {0.0, 0.0};
}

// ============================================================
//  Reverse geocoding
// ============================================================

static std::optional<std::string> reverse_geocode(double lat, double lon, const Config& cfg) {
    // Try Nominatim first
    {
        char lat_s[32], lon_s[32];
        std::snprintf(lat_s, sizeof(lat_s), "%.6f", lat);
        std::snprintf(lon_s, sizeof(lon_s), "%.6f", lon);
        auto url = build_url("https://nominatim.openstreetmap.org/reverse", {
            {"lat", lat_s}, {"lon", lon_s},
            {"format", "jsonv2"}, {"accept-language", cfg.lang}
        });
        std::string nom_ua = cfg.ua + " Weather.cpp/1.0";
        auto data = http_get_json(url, cfg, nom_ua);
        if (data) {
            try {
                auto& addr = (*data)["address"];
                std::vector<std::string> parts;
                for (auto& key : {"city","town","village","hamlet"}) {
                    if (addr.contains(key) && !addr[key].get<std::string>().empty()) {
                        parts.push_back(addr[key].get<std::string>());
                        break;
                    }
                }
                if (addr.contains("state") && !addr["state"].get<std::string>().empty())
                    parts.push_back(addr["state"].get<std::string>());
                if (addr.contains("country") && !addr["country"].get<std::string>().empty())
                    parts.push_back(addr["country"].get<std::string>());
                if (!parts.empty()) {
                    std::string result;
                    for (size_t i = 0; i < parts.size(); ++i) {
                        if (i) result += ", ";
                        result += parts[i];
                    }
                    return result;
                }
            } catch (...) {}
        }
    }

    // Fallback: Open-Meteo reverse geocoding
    {
        char lat_s[32], lon_s[32];
        std::snprintf(lat_s, sizeof(lat_s), "%.6f", lat);
        std::snprintf(lon_s, sizeof(lon_s), "%.6f", lon);
        auto url = build_url("https://geocoding-api.open-meteo.com/v1/reverse", {
            {"latitude", lat_s}, {"longitude", lon_s},
            {"language", cfg.lang}, {"format", "json"}
        });
        auto data = http_get_json(url, cfg);
        if (data) {
            try {
                auto& results = (*data)["results"];
                if (results.is_array() && !results.empty()) {
                    auto& p = results[0];
                    std::vector<std::string> parts;
                    for (auto& key : {"name","admin1","country"}) {
                        if (p.contains(key) && p[key].is_string())
                            parts.push_back(p[key].get<std::string>());
                    }
                    if (!parts.empty()) {
                        std::string result;
                        for (size_t i = 0; i < parts.size(); ++i) {
                            if (i) result += ", ";
                            result += parts[i];
                        }
                        return result;
                    }
                }
            } catch (...) {}
        }
    }
    return std::nullopt;
}

// ============================================================
//  Weather API fetching
// ============================================================

static std::string units_query(const std::string& units) {
    // Returns query fragment for units params
    if (units == "imperial")
        return "&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch";
    return "&temperature_unit=celsius&wind_speed_unit=kmh&precipitation_unit=mm";
}

static std::optional<json> fetch_forecast(double lat, double lon, const Config& cfg) {
    char buf[512];
    std::snprintf(buf, sizeof(buf),
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=%.6f&longitude=%.6f"
        "&current=temperature_2m,apparent_temperature,relative_humidity_2m,"
        "wind_speed_10m,wind_direction_10m,weather_code,visibility,precipitation,"
        "pressure_msl,is_day"
        "&hourly=precipitation_probability"
        "&daily=temperature_2m_max,temperature_2m_min"
        "&timezone=auto%s",
        lat, lon, units_query(cfg.units).c_str());
    return http_get_json(std::string(buf), cfg);
}

static std::optional<json> fetch_aqi(double lat, double lon, const Config& cfg) {
    char buf[256];
    std::snprintf(buf, sizeof(buf),
        "https://air-quality-api.open-meteo.com/v1/air-quality"
        "?latitude=%.6f&longitude=%.6f&current=european_aqi&timezone=auto",
        lat, lon);
    return http_get_json(std::string(buf), cfg);
}

// ============================================================
//  Output building
// ============================================================

static std::string html_escape(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) {
        if      (c == '&')  out += "&amp;";
        else if (c == '<')  out += "&lt;";
        else if (c == '>')  out += "&gt;";
        else                out += c;
    }
    return out;
}

static std::string format_visibility(double meters, const std::string& units) {
    char buf[32];
    if (units == "imperial") {
        std::snprintf(buf, sizeof(buf), "%.1f mi", meters / 1609.344);
    } else {
        std::snprintf(buf, sizeof(buf), "%.1f km", meters / 1000.0);
    }
    return buf;
}

static std::string build_hourly_precip(const json& forecast) {
    try {
        auto& times_arr = forecast["hourly"]["time"];
        auto& probs_arr = forecast["hourly"]["precipitation_probability"];
        std::string cur_time = forecast["current"].value("time", "");

        // Find index of current time
        size_t idx = 0;
        for (size_t i = 0; i < times_arr.size(); ++i) {
            if (times_arr[i].get<std::string>() == cur_time) { idx = i; break; }
        }

        std::string result = " (next 6h)";
        size_t end = std::min(idx + 6, probs_arr.size());
        for (size_t i = idx; i < end; ++i) {
            if (probs_arr[i].is_null())
                result += " -";
            else
                result += " " + std::to_string(probs_arr[i].get<int>()) + "%";
        }
        return result;
    } catch (...) {
        return "";
    }
}

struct OutputPair {
    json        waybar;
    std::string simple;
};

static OutputPair build_output(double lat, double lon, const std::string& place,
                                const json& forecast, const std::optional<json>& aqi,
                                const Config& cfg) {
    auto& cur        = forecast["current"];
    auto& cur_units  = forecast["current_units"];
    auto& daily      = forecast["daily"];
    auto& daily_units = forecast["daily_units"];

    // Temperature
    double temp_val  = cur.value("temperature_2m", std::numeric_limits<double>::quiet_NaN());
    std::string temp_unit = cur_units.value("temperature_2m", "");
    std::string temp_str  = std::isnan(temp_val) ? "N/A"
        : std::to_string(static_cast<int>(std::round(temp_val))) + temp_unit;

    // Feels like
    double feels_val = cur.value("apparent_temperature", std::numeric_limits<double>::quiet_NaN());
    std::string feels_unit = cur_units.value("apparent_temperature", "");
    std::string feels_str  = std::isnan(feels_val) ? ""
        : "Feels like " + std::to_string(static_cast<int>(std::round(feels_val))) + feels_unit;

    // Day/night & weather code
    int is_day = cur.value("is_day", 1);
    int code   = cur.value("weather_code", -1);
    std::string weather_icon = wmo_to_icon(code, is_day == 1);
    std::string status       = wmo_to_status(code);

    // Daily min/max
    std::string dtemp_unit = daily_units.value("temperature_2m_min", temp_unit);
    std::string min_max;
    try {
        double tmin = daily["temperature_2m_min"][0].get<double>();
        double tmax = daily["temperature_2m_max"][0].get<double>();
        min_max = "  " + std::to_string(static_cast<int>(std::round(tmin))) + dtemp_unit
                + "\t\t  " + std::to_string(static_cast<int>(std::round(tmax))) + dtemp_unit;
    } catch (...) {}

    // Wind
    std::string wind_text;
    if (!cur["wind_speed_10m"].is_null()) {
        double wind = cur["wind_speed_10m"].get<double>();
        std::string wu = cur_units.value("wind_speed_10m", "");
        wind_text = "  " + std::to_string(static_cast<int>(std::round(wind))) + wu;
    }

    // Humidity
    std::string humidity_text;
    if (!cur["relative_humidity_2m"].is_null()) {
        int hum = cur["relative_humidity_2m"].get<int>();
        humidity_text = "  " + std::to_string(hum) + "%";
    }

    // Visibility
    std::string visibility_text;
    if (cur.contains("visibility") && !cur["visibility"].is_null()) {
        double vis = cur["visibility"].get<double>();
        visibility_text = "  " + format_visibility(vis, cfg.units);
    }

    // AQI
    std::string aqi_text = "AQI N/A";
    if (aqi) {
        try {
            int aqi_val = (*aqi)["current"]["european_aqi"].get<int>();
            aqi_text = "AQI " + std::to_string(aqi_val);
        } catch (...) {}
    }

    // Hourly precipitation
    std::string hourly_precip = build_hourly_precip(forecast);

    // Location string
    std::string effective_place = !cfg.manual_place.empty() ? cfg.manual_place
                                : !cfg.env_place.empty()    ? cfg.env_place
                                : place;
    std::string place_str = effective_place.empty()
        ? [&]{ char b[32]; std::snprintf(b,sizeof(b),"%.3f, %.3f",lat,lon); return std::string(b); }()
        : effective_place;
    std::string location_text = cfg.loc_icon + "  " + place_str;

    // Build tooltip
    std::string tooltip;
    if (cfg.tooltip_markup) {
        tooltip = "\t\t<span size=\"xx-large\">" + html_escape(temp_str) + "</span>\t\t\n"
                + "<big> " + weather_icon + "</big>\n"
                + "<b>" + html_escape(status) + "</b>\n"
                + html_escape(location_text) + "\n"
                + (feels_str.empty() ? "" : "<small>" + html_escape(feels_str) + "</small>\n")
                + "\n"
                + (min_max.empty() ? "" : "<b>" + html_escape(min_max) + "</b>\n")
                + html_escape(wind_text) + "\t" + html_escape(humidity_text) + "\n"
                + html_escape(visibility_text) + "\t" + html_escape(aqi_text)
                + (hourly_precip.empty() ? "" : "\n<i> " + html_escape(hourly_precip) + "</i>");
    } else {
        std::vector<std::string> lines = {
            weather_icon + "  " + temp_str,
            status,
            location_text,
        };
        if (!feels_str.empty())    lines.push_back(feels_str);
        if (!min_max.empty())      lines.push_back(min_max);
        std::string wind_hum = wind_text;
        if (!humidity_text.empty()) wind_hum += " " + humidity_text;
        if (!wind_hum.empty())     lines.push_back(wind_hum);
        std::string vis_aqi = visibility_text;
        if (!aqi_text.empty())     vis_aqi += " " + aqi_text;
        if (!vis_aqi.empty())      lines.push_back(vis_aqi);
        if (!hourly_precip.empty()) lines.push_back(hourly_precip);
        for (size_t i = 0; i < lines.size(); ++i) {
            if (i) tooltip += "\n";
            tooltip += lines[i];
        }
    }

    // Waybar JSON
    json waybar;
    waybar["text"]    = weather_icon + "  " + temp_str;
    waybar["alt"]     = status;
    waybar["tooltip"] = tooltip;
    waybar["class"]   = "wmo-" + std::to_string(code) + " " + (is_day ? "day" : "night");

    // Simple text cache
    std::string simple = place_str + "\n"
        + weather_icon + "  " + status + "\n"
        + "  " + temp_str + " (" + feels_str + ")\n"
        + (wind_text.empty()       ? "" : " " + wind_text + " \n")
        + (humidity_text.empty()   ? "" : " " + humidity_text + " \n")
        + " " + visibility_text + " " + aqi_text + "\n";

    return {waybar, simple};
}

// ============================================================
//  Main
// ============================================================

int main() {
    curl_global_init(CURL_GLOBAL_DEFAULT);

    Config cfg = load_config();
    g_debug = cfg.debug;

    // Offline check
    if (!check_network()) {
        json out;
        out["text"]    = "\xef\x81\xaa"; // nf-weather-na (󰖪)
        out["alt"]     = "Offline";
        out["tooltip"] = "No network connection";
        std::cout << out.dump() << "\n";
        curl_global_cleanup();
        return 0;
    }

    auto [lat, lon] = get_coords(cfg);

    // ---- Try valid cache ----
    auto cached = read_cache(cfg);
    if (cached) {
        try {
            double c_lat = (*cached)["forecast"].value("latitude", 0.0);
            double c_lon = (*cached)["forecast"].value("longitude", 0.0);
            if (std::abs(c_lat - lat) <= 0.1 && std::abs(c_lon - lon) <= 0.1) {
                std::string cached_place = (*cached).value("place", "");
                auto aqi_j = (*cached)["aqi"].is_null()
                    ? std::optional<json>(std::nullopt)
                    : std::optional<json>((*cached)["aqi"]);
                auto [waybar, simple] = build_output(lat, lon, cached_place,
                                                     (*cached)["forecast"], aqi_j, cfg);
                std::cout << waybar.dump() << "\n";
                write_simple_cache(simple, cfg);
                curl_global_cleanup();
                return 0;
            }
        } catch (const std::exception& e) {
            std::cerr << "Cached data error, refetching: " << e.what() << "\n";
        }
    }

    // ---- Fetch fresh data ----
    auto forecast = fetch_forecast(lat, lon, cfg);
    if (forecast) {
        auto aqi   = fetch_aqi(lat, lon, cfg);
        std::string place = cfg.manual_place.empty()
            ? reverse_geocode(lat, lon, cfg).value_or("")
            : cfg.manual_place;
        write_cache(*forecast, aqi, place, cfg);
        auto [waybar, simple] = build_output(lat, lon, place, *forecast, aqi, cfg);
        std::cout << waybar.dump() << "\n";
        write_simple_cache(simple, cfg);
        curl_global_cleanup();
        return 0;
    }

    // ---- Last resort: stale cache ----
    if (fs::exists(cfg.api_cache_path)) {
        try {
            std::ifstream f(cfg.api_cache_path);
            json stale = json::parse(f);
            std::string stale_place = stale.value("place", "");
            auto aqi_j = stale["aqi"].is_null()
                ? std::optional<json>(std::nullopt)
                : std::optional<json>(stale["aqi"]);
            auto [waybar, simple] = build_output(lat, lon, stale_place,
                                                 stale["forecast"], aqi_j, cfg);
            std::cout << waybar.dump() << "\n";
            write_simple_cache(simple, cfg);
            curl_global_cleanup();
            return 0;
        } catch (const std::exception& e) {
            std::cerr << "Stale cache failed: " << e.what() << "\n";
        }
    }

    // ---- Fallback minimal output ----
    json fallback;
    fallback["text"]    = icon("default") + "  N/A";
    fallback["alt"]     = "Unavailable";
    fallback["tooltip"] = "Weather unavailable";
    fallback["class"]   = "unavailable";
    std::cout << fallback.dump() << "\n";

    curl_global_cleanup();
    return 1;
}
