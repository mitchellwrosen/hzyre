#include "interface.h"

#include <arpa/inet.h>
#include <assert.h>
#include <ifaddrs.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

int get_interfaces(interface_t* interfaces, int max_interfaces) {
    struct ifaddrs* ifaddrs;

    int rc = getifaddrs(&ifaddrs);
    assert(rc == 0);

    int n = 0;
    struct ifaddrs* ifaddr = ifaddrs;
    while (ifaddr && n < max_interfaces) {
        if (ifaddr->ifa_addr == NULL) {
            continue;
        }

        switch (ifaddr->ifa_addr->sa_family) {
            case AF_INET: {
                int name_len = strlen(ifaddr->ifa_name);
                interfaces[n].name = (char*) malloc(name_len + 1);
                strcpy(interfaces[n].name, ifaddr->ifa_name);

                interfaces[n].addr = (char*) malloc(INET_ADDRSTRLEN);
                inet_ntop(AF_INET,
                          &((struct sockaddr_in*) ifaddr->ifa_addr)->sin_addr,
                          interfaces[n].addr,
                          INET_ADDRSTRLEN);

                if (ifaddr->ifa_netmask) {
                    interfaces[n].netmask = (char*) malloc(INET_ADDRSTRLEN);
                    inet_ntop(AF_INET,
                              &((struct sockaddr_in*) ifaddr->ifa_netmask)->sin_addr,
                              interfaces[n].netmask,
                              INET_ADDRSTRLEN);
                } else {
                    interfaces[n].netmask = NULL;
                }

                if (ifaddr->ifa_broadaddr) {
                    interfaces[n].broadcast = (char*) malloc(INET_ADDRSTRLEN);
                    inet_ntop(AF_INET,
                              &((struct sockaddr_in*) ifaddr->ifa_broadaddr)->sin_addr,
                              interfaces[n].broadcast,
                              INET_ADDRSTRLEN);
                } else {
                    interfaces[n].broadcast = NULL;
                }

                n++;
            }
        }

        ifaddr = ifaddr->ifa_next;
    }

    freeifaddrs(ifaddrs);
    return n;
}
