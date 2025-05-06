#include "devicefetcher.h"

devicefetcher::devicefetcher() {}


#ifndef DEVICE_FETCHER_H
#define DEVICE_FETCHER_H

#include <string>
#include <vector>
#include <curl/curl.h>

struct Device {
    std::string id;
    std::string name;
    std::string type;
    std::string status;
    std::string last_active;
};

class DeviceFetcher {
public:
    DeviceFetcher();
    ~DeviceFetcher();

    // Fetches device data from web API
    bool fetchData(const std::string& url);

    // Saves fetched data to CSV file
    bool saveToCSV(const std::string& filename);

private:
    CURL* curl;
    std::string response_data;
    std::vector<Device> devices;

    // libcurl write callback
    static size_t writeCallback(void* contents, size_t size, size_t nmemb, void* userp);

    // Parse JSON response
    void parseJsonResponse();
};

#endif // DEVICE_FETCHER_H
