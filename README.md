
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
### In action
W/ `strace`:
```
$ strace ./anti 
execve("./anti", ["./anti"], 0x7ffd130fdd80 /* 44 vars */) = 0
brk(NULL)                               = 0x56328c049000
[...]
write(1, "Don't ptrace me!\n", 17Don't ptrace me!
)      = 17
exit_group(0)                           = ?
+++ exited with 0 +++
```

Or w/ `gdb`:
```
$ gdb ./anti
Reading symbols from ./anti...
(No debugging symbols found in ./anti)
gdb-peda$ run
Starting program: /home/kali/Documents/anti-debug/simple_anti-debug_and_simple_bypasss/anti 
Don't ptrace me!
[Inferior 1 (process 4938) exited normally]
```

## Bypass 1 - ```rax = 0```
### Why do we set `rax` register to 0?
`rax` is the 64-bit, "long" size register

We will catch ptrace syscall and see what we want to bypass the check:
```
$ gdb ./anti
gdb-peda$ catch syscall ptrace
Catchpoint 1 (syscall 'ptrace' [101])
gdb-peda$ run
Starting program: /home/kali/Documents/anti-debug/simple_anti-debug_and_simple_bypasss/anti 
[----------------------------------registers-----------------------------------]
RAX: 0xffffffffffffffda 
[...]
[-------------------------------------code-------------------------------------]
   0x7ffff7ee51ce <ptrace+78>:  mov    QWORD PTR [rsp+0x20],rax
   0x7ffff7ee51d3 <ptrace+83>:  mov    eax,0x65
   0x7ffff7ee51d8 <ptrace+88>:  syscall 
=> 0x7ffff7ee51da <ptrace+90>:  cmp    rax,0xfffffffffffff000
   0x7ffff7ee51e0 <ptrace+96>:  ja     0x7ffff7ee5220 <ptrace+160>
   0x7ffff7ee51e2 <ptrace+98>:  test   rax,rax
   0x7ffff7ee51e5 <ptrace+101>: js     0x7ffff7ee51ed <ptrace+109>
   0x7ffff7ee51e7 <ptrace+103>: cmp    r8d,0x2
```
In fact `rax` is the return value by `ptrace` syscall, we want it to be `0`
 
### How do wset `rax` register to 0?
W/ `gdb`, we will catch ptrace call, and set the `rax` value to 0, and run the prmg:

    $ gdb -q ./anti
    Reading symbols from ./anti...
    (No debugging symbols found in ./anti)
    gdb-peda$ catch syscall ptrace
    Catchpoint 1 (syscall 'ptrace' [101])
    gdb-peda$ commands 1
    Type commands for breakpoint(s) 1, one per line.
    End with a line saying just "end".
    >set ($rax) = 0
    >continue
    >end
    gdb-peda$ run
    Starting program: /home/kali/Documents/anti-debug/anti 
    Hello debuggingless World!
    During startup program exited with code 1.

## Bypass 2 - ```LD_PRELOAD``` trick

### Explanation
If you set `LD_PRELOAD` to the path of a shared object, that file will be loaded **before** any other library (including the C runtime, `libc.so`).
Hence if I defined a `ptrace` and load the `.so` it will be executed rather than the standard one

### In action

```
make cptrace.so
export LD_PRELOAD="./cptrace.so"
strace ./traceme1.out
Hello debuggingless World!
```
## s/o
 - https://www.exploit-db.com/papers/13234 great paper! (anti-debugging trick, glibc initialization)
 - https://gist.github.com/poxyran/71a993d292eee10e95b4ff87066ea8f2: bypass 
 - https://seblau.github.io/posts/linux-anti-debugging bypass 2


