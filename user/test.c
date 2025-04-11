#include "kernel/types.h"
#include "user.h"

int main(int argc, char *argv[]) {

    // Call the system call to create the swapfile
    int res = runtestcases();
    if (res < 0) {
        printf("Failed to run tests\n");
    } else {
        printf("Tests ran successfully\n");
    }

    exit(0);
}

