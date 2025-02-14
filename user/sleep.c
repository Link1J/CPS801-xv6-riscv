#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {

    if (argc < 2) {
        fprintf(2, "Sleep missing instruction ...\n");
        exit(1);
    } 

    //int pid = getpid();
    int time = atoi(argv[1]);

    exit(sleep(time * 10));


}