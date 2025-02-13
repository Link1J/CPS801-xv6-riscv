#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int isValidFlag(char*);
int isValidPidList(char*);
void printErr(const char*);

int 
main(int argc, char *argv[])
{
  for (int i = 1; i < argc; i++){
    if (!isValidFlag(argv[i])){
      printErr("unsupported SysV option");
      exit(1);
    } else {
      if (strcmp(argv[i],"-p") == 0 && !isValidPidList(argv[i+1])){
        printErr("process ID list syntax error");
        exit(1);
      } else {
        i++;
      }
    }
  }

  ps(argc, argv);
  exit(0);
}

int isValidFlag(char *arg){
  if (strcmp("r", arg) == 0) {
    return 1;
  } else if (strcmp("-l", arg) == 0) {
    return 1;
  } else if (strcmp("-p", arg) == 0) {
    return 1;
  } else {
    return 0;
  }
}

int isValidPidList(char *arg)
{
  for (int i = 0; i < strlen(arg); i++){
    if (!((arg[i] >= '0' && arg[i] <= '9') || arg[i] == ',')) {
      return 0;
    }
  }

  return 1;
}

void printErr(const char *msg)
{
  printf("error: %s\n", msg);
  printf("Usage:\n");
  printf(" ps [options]\n");
}
