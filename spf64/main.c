#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include "spf/float.cc"

// extern void mains();

#ifndef O_BINARY
#define O_BINARY 0
#endif


#ifndef S_IREAD 
#define S_IREAD O_RDONLY
#endif
#ifndef  S_IWRITE
#define S_IWRITE O_WRONLY
#endif


char * ARGV1;
//int AAAA=444;

int RWGet()
{  return O_RDWR|O_BINARY ;
}
int ROGet()
{  return O_RDONLY|O_BINARY ;
 }
int WOGet()
{  return O_WRONLY|O_BINARY ;
}

int SEEK_SETGet() { return SEEK_SET ; }
int O_CREATGet() {
 return O_CREAT ;
 }

//extern int add(int aa,int bb);
extern void amain(); 
extern void TST(); 
/*
int add(int aa,int bb)
{ return aa+bb;
} */

void HPOINT(int x)
{   printf("%x ",x);
}

int	mtell(int _fd)
{ return lseek(_fd, (off_t) 0, SEEK_CUR); }

int	rmlseek(int _fd, int off1)
{ return lseek(_fd, (off_t) off1, SEEK_SET); }

int	mlseek(int _fd, int off1, int mode)
{ return lseek(_fd, (off_t) off1, mode); }

int LOPEN(const char *pathname, int flags)
{ return open(pathname, flags|O_BINARY,S_IREAD | S_IWRITE);
}

int LACCEPT(char *p,int n)
{ register char *q;
  q = fgets (p, n, stdin);
  q = strrchr (p, '\n');
  if (q) *q = '\0';
  return strlen (p);
}

char* LARGV1() {return ARGV1;}

void LZTYPE(char *p)
{ printf("%s\n",p);
}

void LBYE()
{  exit(0); }


/*----------------------------------------------------------*/
// from kforth-1.2.10 

struct termios tios0;
char key_query_char = 0;

void save_term ()
{
    tcgetattr(0, &tios0);
}

void restore_term ()
{
    tcsetattr(0, TCSANOW, &tios0);
}

void echo_off ()
{
  struct termios t;
  tcgetattr(0, &t);
  t.c_lflag &= ~ECHO;
  tcsetattr(0, TCSANOW, &t);
}

void echo_on ()
{
  struct termios t;
  tcgetattr(0, &t);
  t.c_lflag |= ECHO;
  tcsetattr(0, TCSANOW, &t);
}
/*----------------------------------------------------------*/




int C_KEY ()
{
  /* stack: ( -- n | wait for keypress and return key code ) */

  char ch;
  int n;
  struct termios t1, t2;

  if (key_query_char)
    {
      ch = key_query_char;
      key_query_char = 0;
    }
  else
    {
      tcgetattr(0, &t1);
      t2 = t1;
      t2.c_lflag &= ~ICANON;
      t2.c_lflag &= ~ECHO;
//      t2.c_lflag &= ~ISIG;
      t2.c_lflag |= ISIG;
      t2.c_cc[VMIN] = 1;
      t2.c_cc[VTIME] = 0;
      tcsetattr(0, TCSANOW, &t2);

//      do {
	n = read(0, &ch, 1);
//      } while (n != 1);

      tcsetattr(0, TCSANOW, &t1);
    }
 
  return ch;
}
/*----------------------------------------------------------*/

int C_KEYQUERY ()
{
  /* stack: ( a -- b | return true if a key is available ) */

  char ch = 0;
  int chq;
  struct termios t1, t2;

  if (key_query_char)  return -1;

      tcgetattr(0, &t1);
      t2 = t1;
      t2.c_lflag &= ~ICANON;
      t2.c_lflag &= ~ECHO;
      t2.c_cc[VMIN] = 0;
      t2.c_cc[VTIME] = 0;
      tcsetattr(0, TCSANOW, &t2);

      chq = read(0, &ch, 1) ? -1 : 0;
      if (ch) key_query_char = ch;  
      tcsetattr(0, TCSANOW, &t1);

  return chq;
}      
/*----------------------------------------------------------*/

int C_ACCEPT (char *cp, int n1 )
{
  /* stack: ( a n1 -- n2 | wait for n characters to be received ) */

  char ch,  *cpstart, *bksp = "\010 \010";
  int n2, nr;
  struct termios t1, t2;

  cpstart = cp;

  tcgetattr(0, &t1);
  t2 = t1;
  t2.c_lflag &= ~ICANON;
  t2.c_lflag &= ~ECHO;
  t2.c_lflag &= PENDIN;

  t2.c_cc[VMIN] = 1;
  t2.c_cc[VTIME] = 0;
  tcsetattr(0, TCSANOW, &t2);


  n2 = 0;
  while (n2 < n1)
    {
      nr = read (0, cp, 1);
      if (nr == 1) 
	{
	  if (*cp == 10) 
	    break;
	  else if (*cp == 127)
	  {
	    write (0, bksp, 3);
	    --cp; --n2;
	    if (cp < cpstart) cp = cpstart;
	    if (n2 < 0) n2 = 0;
	  }
	  else
	  {
	    write (0, cp, 1);
	    ++n2; ++cp;
	  }
	}
    }

  tcsetattr(0, TCSANOW, &t1);
  return n2;
}

int L_ACCEPT (char *cp, int n1 )
{  struct termios t1, t2;
  int n2;
  tcgetattr(0, &t1);
  t2 = t1;
  t2.c_lflag |= ICANON;
  t2.c_lflag |= ECHO;
  t2.c_lflag |= PENDIN;

  t2.c_cc[VMIN] = 1;
  t2.c_cc[VTIME] = 0;
  tcsetattr(0, TCSANOW, &t2);
   n2 = read (0, cp, n1);
  tcsetattr(0, TCSANOW, &t1);
  return n2;
}


static int ASCREEN;
static struct {char lines, cols, x, y;} scrn;

int wherexy(void) {								/* 19 */
    lseek(ASCREEN, 0, SEEK_SET); read(ASCREEN, &scrn, 4);
    return ((scrn.x << 16) | (scrn.y & 0xFFFF)); }

long long zzzz()
{ return 0x5555777733331111l;
}
main(int argc,char **argv)
{  char kk;
   ARGV1=argv[1];
   FP=&FPBuf[FPBufSize-2];
  amain();
  
  return 0;
}
