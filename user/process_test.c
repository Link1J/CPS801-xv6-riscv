#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void run_child(const char *name, int loops) {
    int start_time = uptime(); // Record start time.

    for (int i = 0; i < loops; i++) {
        fprintf(2, "%s (PID: %d) running...\n", name, getpid());
        for (volatile int j = 0; j < 100000000; j++);
    }

    int end_time = uptime(); // Record end time.
    int completion_time = end_time - start_time; // Calculate process duration.

    fprintf(2, "%s (PID: %d) exiting | Completion Time: %d ticks | Context Switch Count: %d\n", name, getpid(), completion_time, get_ctx_swtch_count());
    exit(0);
}

int main() {
    if (fork() == 0) run_child("Child 0", 5);
    if (fork() == 0) run_child("Child 1", 5);
    if (fork() == 0) run_child("Child 2", 5);
    if (fork() == 0) run_child("Child 3", 5);
    if (fork() == 0) run_child("Child 4", 5);
    if (fork() == 0) run_child("Child 5", 5);
    if (fork() == 0) run_child("Child 6", 5);
    if (fork() == 0) run_child("Child 7", 5);

    while (wait(0) > 0);

    fprintf(2, "--- Round-Robin Test Completed ---\n");
    exit(0);
}