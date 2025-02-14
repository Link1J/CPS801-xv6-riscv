#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h" 
#include "user/user.h"

char* strncpy(char *directory, const char *start, int length) {
  int i = 0;

  while (i < length && start[i] != '\0') {
      directory[i] = start[i];
      i++;
  }
  return directory;
}


int mkdir_p(char *path) {
  // If the path starts with '/', start from the root
  if (path[0] == '/') {
    if (chdir("/") < 0) {
      fprintf(2, "mkdir: failed to change to root directory\n");
      return -1;
    }
  }
  const char *start = path; // Pointer to the start of the current directory name
  const char *end;          // Pointer to the end of the current directory name
  int directory_count = 0; 

  // Iterate over path string and extract directory names
  while (*start != '\0') {
    // Skip leading '/' characters
    if (*start == '/') {
      start++;
      continue;
    }
    // Find the next '/' or end of string
    end = start;
    while (*end != '/' && *end != '\0') {
      end++;
    }
    // Create a new string for the current directory
    long length = end - start;
    char *directory = (char *)malloc(length + 1);
    if (directory == 0) {
      fprintf(2, "mkdir: memory allocation failed\n");
      return -1;
    }
    strncpy(directory, start, length);
    directory[length] = '\0'; // Null-terminate the new string
    // Output the current directory
    // printf("Directory: %s\n", directory);
    // Check if the directory already exists
    if (open(directory, O_RDONLY) < 0) {  // doesn't exist
      // printf("Directory: %s does not exist\n", directory);
      if (mkdir(directory) < 0) {    // Try creating the directory
        fprintf(2, "mkdir: failed to create directory %s\n", directory);
        return -1;
      }
    }
    // move into directory
    if (chdir(directory) < 0) {
      fprintf(2, "mkdir: failed to change into %s directory\n", directory);
      return -1;
    }
    directory_count += 1;
    // Free the allocated memory for the directory name string
    free(directory);
    // Move to the next directory in path
    start = end;
  }
  for(int i = 0; i < directory_count; i++){
    if (chdir("..") < 0) {
      fprintf(2, "mkdir: failed to go back to original directory");
      return -1;
    }
  }
  return 0;
}

int main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    fprintf(2, "Usage: mkdir [-p] directories...\n");
    exit(1);
  }

  if (strcmp(argv[1], "-p") == 0) {
    if (argc < 3) {
      fprintf(2, "mkdir: missing argument for -p\n");
      exit(1);
    }
    for(i = 2; i < argc; i++){
      // printf("Arg : %s\n", argv[i]);
      if(mkdir_p(argv[i]) < 0){
        fprintf(2, "mkdir: %s failed to create\n", argv[i]);
        break;
      }
    }
    
  } else {
    for(i = 1; i < argc; i++){
      if(mkdir(argv[i]) < 0){
        fprintf(2, "mkdir: %s failed to create\n", argv[i]);
        break;
      }
    }
  }

  exit(0);
}
