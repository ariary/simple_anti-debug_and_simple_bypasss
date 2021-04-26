#include <stdio.h>
#include <sys/ptrace.h>

void ptrace_trap(void) __attribute__ ((constructor));

void ptrace_trap(void) {

    if (ptrace(PTRACE_TRACEME, 0, 0, 0) < 0) { 
        printf("Don't ptrace me!\n");
        exit(0);
    }
}

int main(int argc, char **argv) {

    printf("Hello debuggingless World!\n");
    return 1;
}
