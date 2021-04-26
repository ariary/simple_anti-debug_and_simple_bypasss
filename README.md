
# simple_anti-debug_and_simple_bypasss
Nothing new on 🌍. Just a repository containing an Anti-debugging trick and its bypass

## The trick
`GDB`, `strace`, etc uses `PTRACE` syscall in order to debug. The trick consists of performing a `PTRACE` call on the program itself. If this action failed means that another process has already done it so we can exit the program.

Another tricks added is that we perform this call in a constructor function, which is called before the `main` function with ELF executable. (***TIP:*** it is also a great place to hide a packer if you want to write a virus)

### Code
```
#include  <stdio.h>
#include  <sys/ptrace.h>

void  ptrace_trap(void) __attribute__ ((constructor));

void  ptrace_trap(void) {
	if (ptrace(PTRACE_TRACEME, 0, 0, 0) < 0) {
		printf("Don't ptrace me!\n");
		exit(0);
	}
}

int  main(int  argc, char **argv) {
	printf("Hello debuggingless World!\n");
	return  1;
}
```


## Bypass 1 - ```rax = 0```

## Bypass 2 - ```LD_PRELOAD``` trick
## s/o
 - https://www.exploit-db.com/papers/13234 great paper! (anti-debugging trick, glibc initialization)
 - https://gist.github.com/poxyran/71a993d292eee10e95b4ff87066ea8f2: bypass 
 - https://seblau.github.io/posts/linux-anti-debugging bypass 2


