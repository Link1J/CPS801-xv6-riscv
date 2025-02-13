#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void write_with_escape_sequences(char *str) {
  while (*str) {
    if (*str == '\\') { // Check for backslash
      str++;
      switch (*str) {
        case 'b': // Backspace
          write(1, "\b", 1);
          break;
        case 'n': // Newline
          write(1, "\n", 1);
          break;
        case 't': // Tab
          write(1, "\t", 1);
          break;
        case 'r': // Carriage return
          write(1, "\r", 1);
          break;
        case 'v': // Vertical tab
          write(1, "\v", 1);
          break;
        case '\\': // Backslash
          write(1, "\\", 1);
          break;
        default: // If no valid escape sequence, write the characters as is
          write(1, "\\", 1);
          if (*str) {
              write(1, str, 1);
          }
          break;
      }
    } else {
      write(1, str, 1); // Write normal character
    }
    str++;
  }
}

int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++){
    write_with_escape_sequences(argv[i]);
    if(i + 1 < argc){
      write(1, " ", 1);
    } else {
      write(1, "\n", 1);
    }
  }
  exit(0);
}
