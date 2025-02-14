#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char* fmtname(char *path) {
	static char buf[DIRSIZ + 1];
	char *p;

	// Find first character after last slash.
	for (p = path + strlen(path); p >= path && *p != '/'; p--);
	p++;

	// Return blank-padded name.
	if (strlen(p) >= DIRSIZ) { return p; }

	memmove(buf, p, strlen(p));
	memset(buf + strlen(p), ' ', DIRSIZ - strlen(p));
	
	return buf;
}

// Removing the ' ' created by fmtname for the -m flag.
char* clean_fmtname(char *name) {
	int end = 0;
	char *modified_name = name;

	while (name[end] != ' ') { end++; }

	modified_name[end] = '\0';
	return modified_name;
}

void ls(char *path, int l_flag, int p_flag, int m_flag) {
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;
	int total_entries = 0, curr_entries = 0;

	if ((fd = open(path, O_RDONLY)) < 0) {
		fprintf(2, "ls: cannot open %s\n", path);
		return;
	}

	if (fstat(fd, &st) < 0) {
		fprintf(2, "ls: cannot stat %s\n", path);
		close(fd);
		return;
	}

	switch (st.type) {
		case T_DEVICE:
			if ((l_flag == 1 && m_flag == 1) || (l_flag == 0 && m_flag == 1)) {
				printf("%s", clean_fmtname(fmtname(path)));
			} else if (l_flag == 1 && m_flag == 0) {
				printf("%s %d %s %d\n", "-", st.nlink, fmtname(path), (int) st.size);
			} else {
				printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
			}
			break;
		case T_FILE:
			if ((l_flag == 1 && m_flag == 1) || (l_flag == 0 && m_flag == 1)) {
				printf("%s", clean_fmtname(fmtname(path)));
			} else if (l_flag == 1 && m_flag == 0) {
				printf("%s %d %s %d\n", "f", st.nlink, fmtname(path), (int) st.size);
			} else {
				printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
			}
			break;
		case T_DIR:
			if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
				printf("ls: path too long\n");
				break;
			}

			strcpy(buf, path);
			p = buf + strlen(buf);
			*p++ = '/';

			// Count the total number of entries when "." is selected.
			// Used for -m to know when to place ", " at the end of each iteration.
			while (read(fd, &de, sizeof(de)) == sizeof(de)) {
				if (de.inum != 0) { total_entries++; }
			}

			// Close and reopen to reset the file descriptor.
			close(fd);
			fd = open(path, O_RDONLY);

			while (read(fd, &de, sizeof(de)) == sizeof(de)) {
				if (de.inum == 0) {
					continue;
				} else {
					memmove(p, de.name, DIRSIZ);
					p[DIRSIZ] = 0;

					if (stat(buf, &st) < 0) {
						printf("ls: cannot stat %s\n", buf);
						continue;
					}

					switch (st.type) {
						case T_DEVICE:
							if ((l_flag == 1 && m_flag == 1) || (l_flag == 0 && m_flag == 1)) {
								printf("%s", clean_fmtname(fmtname(buf)));
							} else if (l_flag == 1 && m_flag == 0) {
								printf("%s %d %s %d\n", "-", st.nlink, fmtname(buf), (int) st.size);
							} else {
								printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
							}
							break;
						case T_FILE:
							if ((l_flag == 1 && m_flag == 1) || (l_flag == 0 && m_flag == 1)) {
								printf("%s", clean_fmtname(fmtname(buf)));
							} else if (l_flag == 1 && m_flag == 0) {
								printf("%s %d %s %d\n", "f", st.nlink, fmtname(buf), (int) st.size);
							} else {
								printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
							}
							break;
						case T_DIR:
							char *modified_name = fmtname(buf);

							if (l_flag == 1) {
								if (m_flag == 1 && p_flag == 1) {
									modified_name = clean_fmtname(modified_name);
									printf("%s/", modified_name);
								} else if (m_flag == 1 && p_flag == 0) {
									modified_name = clean_fmtname(modified_name);
									printf("%s", modified_name);
								} else if (m_flag == 0 && p_flag == 1) {
									modified_name[strlen(modified_name) - 1] = '/';
									printf("%s %d %s %d\n", "d", st.nlink, modified_name, (int) st.size);	
								} else {
									printf("%s %d %s %d\n", "d", st.nlink, fmtname(buf), (int) st.size);
								}
							} else {
								if (m_flag == 1 && p_flag == 1) {
									modified_name = clean_fmtname(modified_name);
									printf("%s/", modified_name);
								} else if (m_flag == 1 && p_flag == 0) {
									modified_name = clean_fmtname(modified_name);
									printf("%s", modified_name);
								} else if (m_flag == 0 && p_flag == 1) {
									modified_name[strlen(modified_name) - 1] = '/';
									printf("%s %d %d %d\n", modified_name, st.type, st.ino, (int) st.size);
								} else {
									printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
								}
							}
							break;
					}
				}
				curr_entries++;

				// If the -m flag is set and the curr_entries is less than the total -> print ", " at the end of each iteration.
				if ((m_flag == 1) && (total_entries > curr_entries)) { printf(", "); }
			}
			break;
	}
	close(fd);
}

int main(int argc, char *argv[]) {
	int l_flag = 0, p_flag = 0, m_flag = 0;
	int only_flags = 0;

	// Check which flags are selected.
	for (int i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-l") == 0) {
			l_flag = 1;
		} else if (strcmp(argv[i], "-p") == 0) {
			p_flag = 1;
		} else if (strcmp(argv[i], "-m") == 0) {
			m_flag = 1;
		}
	}

	// Check if there's flags + files/dir or just only flags.
	for (int i = 1; i < argc; i++) {
		if (argv[i][0] != '-') {
			only_flags = 1;
			break;
		}
	}

	if (only_flags == 0) {
		ls(".", l_flag, p_flag, m_flag);
	} else {
		for (int i = 1; i < argc; i++) {
			if (strcmp(argv[i], "-l") == 0 || strcmp(argv[i], "-p") == 0 || strcmp(argv[i], "-m") == 0) {
				continue;
			} else {
				ls(argv[i], l_flag, p_flag, m_flag);
				
				// For single/multiple entries with the -m flag -> print ", " at the end of each iteration.
				if (m_flag == 1) { if (i != argc - 1) { printf(", "); } }
			}
		}
	}

	// At the end of the loop, if -m is set -> print a new line for the terminal.
	if (m_flag == 1) { printf("\n"); }
	exit(0);
}