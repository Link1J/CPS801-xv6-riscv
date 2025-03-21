#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void run_child(int priority, const char *name, int loops) {
    int start_time = uptime(); // Record start time.
    set_priority(priority);

    for (int i = 0; i < loops; i++) {
        fprintf(2, "%s (PID: %d) running...\n", name, getpid());
        for (volatile int j = 0; j < 100000000; j++);
    }

    int end_time = uptime(); // Record end time.
    int completion_time = end_time - start_time; // Calculate process duration.

    fprintf(2, "%s (PID: %d) exiting | Completion Time: %d ticks\n", name, getpid(), completion_time);
    exit(0);
}

int main() {
    if (fork() == 0) run_child(4, "Child 0 (Priority=4)", 5);
    if (fork() == 0) run_child(0, "Child 1 (Priority=0)", 5);
    if (fork() == 0) run_child(1, "Child 2 (Priority=1)", 5);
    if (fork() == 0) run_child(2, "Child 3 (Priority=2)", 5);
    if (fork() == 0) run_child(2, "Child 4 (Priority=2)", 5);
    if (fork() == 0) run_child(0, "Child 5 (Priority=0)", 5);
    if (fork() == 0) run_child(3, "Child 6 (Priority=3)", 5);
    if (fork() == 0) run_child(4, "Child 7 (Priority=4)", 5);

    while (wait(0) > 0);

    fprintf(2, "--- Priority Order Test Completed ---\n");
    exit(0);
}