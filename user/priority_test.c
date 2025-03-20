#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NUM_LOOPS 5

void run_child(int priority, const char *name, int loops) {
  set_priority(priority);
  for (int i = 0; i < loops; i++) {
      fprintf(2, "%s (PID: %d) running...\n", name, getpid());
      for (volatile int j = 0; j < 100000000; j++);  // Simulated CPU work
  }
  fprintf(2, "%s (PID: %d) exiting, switch count: %d \n", name, getpid(), get_ctx_swtch_count());
  exit(0);
}

void run_default_child(const char *name, int loops){
  for (int i = 0; i < loops; i++) {
    fprintf(2, "%s (PID: %d) running...\n", name, getpid());
    for (volatile int j = 0; j < 100000000; j++);  // Simulated CPU work
  }
  fprintf(2, "%s (PID: %d) exiting, switch count: %d\n", name, getpid(), get_ctx_swtch_count());
  exit(0);

}

void run_dynamic_child(int start_priority, int end_priority, const char *name, int loops){
  set_priority(start_priority);  // Start with lowest priority

  for (int i = 0; i < NUM_LOOPS / 2; i++) {
      fprintf(2, "Child (PID: %d, Priority: %d) running...\n", getpid(), start_priority);
      for (volatile int j = 0; j < 100000000; j++);  // Simulated CPU work
  }

  fprintf(2, "Child (PID: %d): Changing priority to %d\n", getpid(), end_priority);
  set_priority(end_priority);  // Dynamically change priority to highest

  for (int i = NUM_LOOPS / 2; i < NUM_LOOPS; i++) {
      fprintf(2, "Child (PID: %d, Priority: %d) running...\n", getpid(), end_priority);
      for (volatile int j = 0; j < 100000000; j++);  // Continue work with higher priority
  }

  fprintf(2, "Child (PID: %d, Priority: %d) exiting | Execution Time: %d ticks\n", getpid(), end_priority,get_ctx_swtch_count());
  
  exit(0);
}


// **Test 1: Basic Execution**
void test_basic_execution() {
  fprintf(2, "\n--- Running Test 1: Basic Execution ---\n");
  if (fork() == 0) run_default_child("Process 1 (Priority=DEFAULT)", NUM_LOOPS);
  while (wait(0) > 0);
}

// **Test 2: Priority Scheduling**
void test_priority_scheduling() {
  fprintf(2, "\n--- Running Test 2: Priority-Based Scheduling ---\n");
  if (fork() == 0) run_child(4, "Low-Priority Process", NUM_LOOPS);
  if (fork() == 0) run_child(0, "High-Priority Process", NUM_LOOPS);
  while (wait(0) > 0);
}

// **Test 3: Low Priority Starvation**
void test_starvation() {
  fprintf(2, "\n--- Running Test 3: Low Priority Starvation ---\n");
  if (fork() == 0) run_child(0, "High-Priority Task 1", NUM_LOOPS);
  if (fork() == 0) run_child(0, "High-Priority Task 2", NUM_LOOPS);
  if (fork() == 0) run_child(4, "Low-Priority Task", NUM_LOOPS * 2);  // Should be delayed
  while (wait(0) > 0);
}

// **Test 4: Dynamic Priority Change**
void test_dynamic_priority() {
  fprintf(2, "\n--- Running Test 4: Dynamic Priority Change ---\n");

  if (fork() == 0) run_dynamic_child(0, 4, "Child 1 (Dynamic)", NUM_LOOPS*2);
  if (fork() == 0) run_child(1, "Child 2 (Priority=1)", NUM_LOOPS);
  while (wait(0) > 0);
}
// **Test 5: Invalid Priority Handling**
void test_invalid_priority() {
  fprintf(2, "\n--- Running Test 5: Invalid Priority Handling ---\n");
  if (fork() == 0) run_dynamic_child(1, 5, "Child 1 (Dynamic)", NUM_LOOPS*2);
  if (fork() == 0) run_child(2, "Child 2 (Priority=2)", NUM_LOOPS);
  while (wait(0) > 0);
}


void test_multiple_process_priorities(){
  fprintf(2, "\n--- Running Test 6: Test the handling of multiple processes with different priorities ---\n");
  if (fork() == 0) run_child(4, "Child 0 (Priority=4)", 5);
    if (fork() == 0) run_child(0, "Child 1 (Priority=0)", 5);  // Highest priority
    if (fork() == 0) run_child(1, "Child 2 (Priority=1)", 5);
    if (fork() == 0) run_child(2, "Child 3 (Priority=2)", 5);
    if (fork() == 0) run_child(2, "Child 4 (Priority=2)", 5);
    if (fork() == 0) run_child(0, "Child 5 (Priority=0)", 5);
    if (fork() == 0) run_child(3, "Child 6 (Priority=3)", 5);
    if (fork() == 0) run_child(4, "Child 7 (Priority=4)", 5);

    while (wait(0) > 0);

}


int main() {
  test_basic_execution();
  test_priority_scheduling();
  test_starvation();
  test_dynamic_priority();
  test_invalid_priority();
  test_multiple_process_priorities();
    
  exit(0);
}
