#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>

#define MAX_PATH 128

const char* ICONS[][5] = {
    {"󰁻", "󰁽", "󰁿", "󰂀", "󱟢"},
    {"󰁻", "󰁽", "󰁿", "󰂀", "󰁹"}
};

#define NORMAL_COLOR "%{F#FFFCF0}"
#define LOW_COLOR    "%{F#AF3029}"
#define RESET_COLOR  "%{F-}"

static inline int get_battery_name(char* battery_name, size_t size) {
    DIR* dir = opendir("/sys/class/power_supply");
    if (!dir) return -1;

    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {
        if (strncmp(entry->d_name, "BAT", 3) == 0) {
            strncpy(battery_name, entry->d_name, size - 1);
            battery_name[size - 1] = '\0';
            closedir(dir);
            return 0;
        }
    }
    closedir(dir);
    return -1;
}

static inline int read_file(const char* path, char* buffer, size_t size) {
    FILE* file = fopen(path, "r");
    if (!file) return -1;

    if (!fgets(buffer, size, file)) {
        fclose(file);
        return -1;
    }
    fclose(file);
    buffer[strcspn(buffer, "\n")] = '\0';
    return 0;
}

static inline int get_battery_capacity(const char* battery_name) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "/sys/class/power_supply/%s/capacity", battery_name);

    char buffer[16];
    if (read_file(path, buffer, sizeof(buffer)) != 0) return -1;
    return atoi(buffer);
}

static inline int get_battery_status(const char* battery_name, char* status, size_t size) {
    char path[MAX_PATH];
    snprintf(path, sizeof(path), "/sys/class/power_supply/%s/status", battery_name);
    return read_file(path, status, size);
}

static inline int get_icon_index(int capacity) {
    return (capacity >= 100) ? 4 : (capacity / 20);
}

static inline void display_battery_status(const char* color, const char* icon) {
    printf("%s%s%s\n", color, icon, RESET_COLOR);
    fflush(stdout);
}

int main() {
    char battery_name[16];
    if (get_battery_name(battery_name, sizeof(battery_name)) == -1) return EXIT_FAILURE;

    while (1) {
        int capacity = get_battery_capacity(battery_name);
        if (capacity == -1) return EXIT_FAILURE;

        char status[16];
        if (get_battery_status(battery_name, status, sizeof(status)) == -1) return EXIT_FAILURE;

        const char* color = (capacity <= 20) ? LOW_COLOR : NORMAL_COLOR;
        int icon_index = get_icon_index(capacity);
        int is_charging = strcmp(status, "Charging") == 0;

        if (capacity == 100 && !is_charging) {
            display_battery_status(color, ICONS[0][4]);
        } else if (is_charging) {
            for (int i = icon_index; i < 5; i++) {
                display_battery_status(color, ICONS[1][i]);
                usleep(200000);
            }
        } else {
            display_battery_status(color, ICONS[0][icon_index]);
        }

        sleep(1);
    }

    return EXIT_SUCCESS;
}