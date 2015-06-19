#ifndef INTERFACE_H_
#define INTERFACE_H_

typedef struct {
    char* name;
    char* addr;
    char* netmask;
    char* broadcast;
} interface_t;

// Fill the pre-calloc'd array of interfaces (up to max_interfaces elements),
// and return the number of elements actually filled.
int get_interfaces(interface_t* interfaces, int max_interfaces);

#endif // INTERFACE_H_
