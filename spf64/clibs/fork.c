#include <linux/unistd.h>
#include <linux/sched.h>
#include <sys/types.h>
// #include <unistd.h>
#include <sys/signal.h>

// Получение task id
// pid_t pid, ppid;
// pid = getpid ();
// ppid = getppid ();

int c_getpid() {
  // pid_t getpid(void);
  return getpid();
}

int c_getppid() { 
  // pid_t getppid(void);
  return getppid();
}

// int my_thread(void * a)
// { 
   // {
       // struct sched_param sp;
       // sp.sched_priority = 1;
       // if ( sched_setscheduler(0, SCHED_RR, &sp) == -1 )
           // return 55;
   // }
   // .....
// }

int c_clone(int xt) {
  // int clone(int (*fn)(void *), void *child_stack,
          // int flags, void *arg, ...
          // /* pid_t *ptid, struct user_desc *tls, pid_t *ctid */ );
  void **child_stack;
  child_stack = (void **) malloc(8192);
  return clone(xt, child_stack, SIGCHLD|CLONE_VM, NULL);
}

// --- Тестовый код
int c_exit() { 
  // pid_t getppid(void);
  // exit(-1);
  // getpid()
  // int sig;
  // sig = SIGCHLD;
  kill(getpid(), SIGTERM);
}

// int c_fork (void) {
    // pid_t pid = fork();
    // if (pid == 0) {
        // printf ("child (pid=%d)\n", getpid());
    // } else {
        // printf ("parent (pid=%d, child's pid=%d)\n", getpid(), pid);
    // }
    // return pid;
// }
// ---

// int c_execve(char * iaddr) {
    // execve(iaddr, NULL, NULL);
    // return 0;
// }

// extern char ** environ;

// int main (void)
// {
        // char * echo_args[] = { "echo", "child", NULL };

        // if (!fork ()) {
                // execve ("/bin/echo", echo_args, environ);
                // fprintf (stderr, "an error occured\n");
                // return 1;
        // }

        // printf ("parent");
        // return 0;
// }