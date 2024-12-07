#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ICON_ETH_ON ""
#define ICON_ETH_OFF "󰈀"
#define ICON_WIFI_STRONG "󰤨"
#define ICON_WIFI_MEDIUM "󰤥"
#define ICON_WIFI_GOOD "󰤢"
#define ICON_WIFI_WEAK "󰤟"
#define ICON_WIFI_NO_SIGNAL "󰤯"
#define ICON_NO_INTERNET "󰅛"
#define ICON_WIFI_NO_PING "󰤩"

#define COLOR_CONNECTED "%{F#FFFCF0}"
#define COLOR_DISCONNECTED "%{F#AF3029}"
#define COLOR_NO_INTERNET "%{F#282726}"
#define COLOR_RESET "%{F-}"

static inline int check_internet() {
    return system("ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1") == 0;
}

static inline void display_icon(const char* color, const char* icon) {
    printf("%s%s%s\n", color, icon, COLOR_RESET);
}

static inline int get_wifi_signal() {
    FILE* fp = popen("nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*:' | cut -d':' -f2", "r");
    if (!fp) return -1;

    char buffer[16];
    if (fgets(buffer, sizeof(buffer), fp) == NULL) {
        pclose(fp);
        return -1;
    }
    pclose(fp);
    return atoi(buffer);
}

static inline int ethernet_connected() {
    return system("nmcli -t -f DEVICE,TYPE,STATE dev | grep -q 'ethernet:connected'") == 0;
}

int main() {
    static int last_has_internet = 0; 
    static int last_signal_level = -1;

    int has_internet = check_internet();

    if (has_internet != last_has_internet) {
        last_has_internet = has_internet;
    }

    if (ethernet_connected()) {
        display_icon(has_internet ? COLOR_CONNECTED : COLOR_DISCONNECTED, ICON_ETH_ON);
    } else {
        int signal_level = get_wifi_signal();

        if (signal_level >= 0 && signal_level != last_signal_level) {
            last_signal_level = signal_level;
        }

        if (signal_level >= 0) {
            const char* icon = ICON_WIFI_NO_SIGNAL;
            if (signal_level >= 80) icon = ICON_WIFI_STRONG;
            else if (signal_level >= 60) icon = ICON_WIFI_MEDIUM;
            else if (signal_level >= 40) icon = ICON_WIFI_GOOD;
            else if (signal_level >= 20) icon = ICON_WIFI_WEAK;

            display_icon(has_internet ? COLOR_CONNECTED : COLOR_NO_INTERNET, has_internet ? icon : ICON_WIFI_NO_PING);
        } else {
            display_icon(COLOR_NO_INTERNET, ICON_NO_INTERNET);
        }
    }

    return 0;
}