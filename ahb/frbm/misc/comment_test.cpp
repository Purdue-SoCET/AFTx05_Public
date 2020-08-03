/*
 * File: comment_test.c
 * Desc: Test program to verify the behaviour of fgets.
 */

#include <stdio.h>

typedef struct _cmd {
    char  code;
    char* name;
} cmdinfo_t;

cmdinfo_t g_cmds[] = {
    { 'A', "Address"            },
    { 'W', "Write"              },
    { 'E', "Expect"             },
    { 'M', "Mask"               },
    { 'C', "Control"            },
    { 'I', "Idle"               },
    { 'P', "Protection flags"   },
    { 'B', "Burst flags"        },
    { 'L', "Lock bit"           },
    { 'X', "Exit"               },
    { '#', "Comment"            },
    {  0 , ""                   }
};


int char_in_string (char ch, char* chars)
{
    for (char* psz = chars; *psz != 0; psz++) {
        if (*psz == ch) {
            return 1;
        }
    }
    return 0;
}

int main (int argc, char** argv)
{
    FILE* fdTIC;
    char* szFileName;
    char  chCmd;
    int   nArg;
    char  szComment[512];
    
    // Check for required number of arguments.
    if (argc != 2) {
        puts ("Incorrect number of arguments.");
        return 1;
    }
    
    // Attempt to open the file.
    szFileName = argv[1];
    fdTIC      = fopen (szFileName, "r");
    
    // Process the file.
    while (!feof (fdTIC)) {
        // Read the command.
        fscanf (fdTIC, "%c ", &chCmd);
        
        // Print the command name.
        for (int i = 0; g_cmds[i].code; i++) {
            if (g_cmds[i].code == chCmd) {
                printf ("%s", g_cmds[i].name);
                break;
            }
        }
        
        // Also read an argument, maybe.
        if (char_in_string (chCmd, "ACMWEBPL")) {
            fscanf (fdTIC, "%x ", &nArg);
            printf (": 0x%08X", nArg);
        }
        
        // Process comments.
        if (chCmd == '#') {
            fgets (szComment, 512, fdTIC);
            printf (": %s", szComment);
        }
        
        printf ("\n");
    }
    
    // Close the file.
    fclose (fdTIC);
    return 0;
}
