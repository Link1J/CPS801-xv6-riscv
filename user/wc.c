#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"

#define NUMBER_OF_BYTES 0b0001
#define NUMBER_OF_WORDS 0b0010
#define NUMBER_OF_CHARS 0b0100
#define NUMBER_OF_LINES 0b1000
#define DEFAULT_OUTPUTS NUMBER_OF_BYTES | NUMBER_OF_WORDS | NUMBER_OF_LINES

char buf[512];

void write_output(char *name, int format, int l, int w, int c, int m)
{
    if ((format & NUMBER_OF_LINES) != 0)
        printf("%d ", l);
    if ((format & NUMBER_OF_WORDS) != 0)
        printf("%d ", w);
    if ((format & NUMBER_OF_CHARS) != 0)
        printf("%d ", c - m);
    if ((format & NUMBER_OF_BYTES) != 0)
        printf("%d ", c);
    printf("%s\n", name);
}

void wc(int fd, char *name, int format, int *total_l, int *total_w, int *total_c, int *total_m)
{
    int n;
    int l, w, c, m, inword;
    char cur, *i;

    l = w = c = m = 0;
    inword = 0;
    while ((n = read(fd, buf, sizeof(buf))) > 0)
    {
        c = c + n;
        for (i = buf; i < (buf + sizeof(buf)); i++)
        {
            cur = *i;
            // Assuming UTF-8 for input. Which is normal for Unix and Linux.
            // This checks for a UTF-8 continuing byte, and ignores them.
            // All UTF-8 continuing bytes are in the format 0b10xxxxxx.
            if ((cur & 0b11000000) == 0b10000000)
            {
                m++;
                // No inword assignement here. We have to be in a word to get here.
                // Otherwise we are dealing with invalid UTF-8.
            }
            else if ((cur >= '\t' && cur <= '\r') || cur == ' ')
            {
                inword = 0;
                if (cur == '\n')
                    l++;
            }
            else if (!inword)
            {
                w++;
                inword = 1;
            }
        }
    }
    if (n < 0)
    {
        printf("wc: read error\n");
        return;
    }
    write_output(name, format, l, w, c, m);
    *total_l += l;
    *total_w += w;
    *total_c += c;
    *total_m += m;
}

char **parse_args(int argc, char **argv, char **items, int *output)
{
    int i, n;
    uint l;
    char **items_end = items;

    for (i = 1; i < argc; i++)
    {
        if (argv[i][0] == '-')
        {
            if (argv[i][1] == '-')
            {
                printf("wc: unrecognized option '%s'\n", argv[i]);
                exit(1);
            }

            l = strlen(argv[i]);
            for (n = 1; n < l; n++)
            {
                switch (argv[i][n])
                {
                case 'c':
                    *output |= NUMBER_OF_BYTES;
                    break;
                case 'w':
                    *output |= NUMBER_OF_WORDS;
                    break;
                case 'l':
                    *output |= NUMBER_OF_LINES;
                    break;
                case 'm':
                    *output |= NUMBER_OF_CHARS;
                    break;
                default:
                    printf("wc: invalid option -- '%c'\n", argv[i][n]);
                    exit(1);
                }
            }
            if (l > 1)
                continue;
        }
        *items_end = argv[i];
        items_end++;
    }

    return items_end;
}

int main(int argc, char *argv[])
{
    int total_l, total_w, total_c, total_m, output, fd, item_count;
    char **items, **items_end;

    total_l = total_w = total_c = total_m = output = 0;
    items = malloc(sizeof(char *) * argc);
    items_end = parse_args(argc, argv, items, &output);

    if (output == 0)
        output = DEFAULT_OUTPUTS;

    if (items == items_end)
    {
        *items_end = "";
        items_end++;
    }

    item_count = items_end - items;

    for (; items != items_end; items++)
    {
        if (((*items)[0] == '-' && (*items)[1] == '\0') || (*items)[0] == '\0')
        {
            fd = 0;
        }
        else if ((fd = open(*items, O_RDONLY)) < 0)
        {
            printf("wc: cannot open %s\n", *items);
        }
        if (fd >= 0)
        {
            wc(fd, *items, output, &total_l, &total_w, &total_c, &total_m);
            if (fd > 2)
                close(fd);
        }
    }
    if (item_count > 1)
    {
        write_output("total", output, total_l, total_w, total_c, total_m);
    }
    exit(0);
}
