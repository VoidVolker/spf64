#include <stdio.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <linux/if.h>
#include <linux/sockios.h>
#include <errno.h>
// #include <linux/socket.h>
#define TCP_NODELAY	1

// 7007 create-server  -> sock
// sock (#num connects) listen
// sock accept -> client_sock
// client_sock client-buf <size> read -> a u 
// sock close

// c_sock_open (int port,char * iaddr)
// c_sock_lconnect (int port)
// c_getmyip 
// c_create_server (int port)
// c_sock_accept
// c_sock_listen

//char * inet_addr_buf="127.0.0.1";
char inet_addr_buff[256]="localhost";
char * inet_addr_buf=&inet_addr_buff;
unsigned CIPAddr;

int c_sock_open(int port,char * iaddr)
{
	struct sockaddr_in serveraddr;
	struct hostent *he;
	int sock;

  if((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
      printf("connect socket err\n");
      return -1;
    }

  if ((he = gethostbyname(iaddr)) == 0)
    {
      printf("Client-gethostbyname() error lol!\n");
      return -1;
    }

	serveraddr.sin_family = AF_INET;
	serveraddr.sin_port =  htons(port);
//  serveraddr.sin_addr.s_addr = inet_addr(inet_ntoa(*(struct in_addr *)he->h_addr_list[0]));
	serveraddr.sin_addr =  *((struct in_addr *)he->h_addr);
	memset(&(serveraddr.sin_zero), '\0', 8);

  if(connect(sock, (struct sockaddr *)&serveraddr, sizeof(struct sockaddr)) == -1)
    {
      printf("connect err");
      return -1;
    }
    else
      printf("Client-The connect() is OK...\n");
      return sock;
}

int c_sock_lconnect(int port)
{
	return c_sock_open( port, inet_addr_buf );
}

unsigned hostname2ip(char * hostname)
{
   struct hostent *he;

   if ( (he = gethostbyname( hostname ) ) == NULL) 
   {
	// get the host info
	printf("gethostbyname");
	return -1;
   }
     
   return *((unsigned *)he->h_addr);
}

/*
 * Определяем IP адрес сетевого интерфейса
 */

unsigned c_getmyip()
{
  int fd;
  struct sockaddr_in * ps;
  struct ifreq ifr;
  int ipaddr;

  memset((void *)&ifr, 0, sizeof(struct ifreq));
  if((fd = socket(AF_INET,SOCK_DGRAM,0)) < 0)	return (-1);

  sprintf(ifr.ifr_name,"%s","eth0");

  if(ioctl(fd, SIOCGIFADDR, &ifr) < 0) {
    sprintf(ifr.ifr_name,"%s","eth1");
    if(ioctl(fd, SIOCGIFADDR, &ifr) < 0)
      {
        sprintf(ifr.ifr_name,"%s","eth0.2");
        if(ioctl(fd, SIOCGIFADDR, &ifr) < 0)
        return -1;
      }
  }

  ps= (struct sockaddr_in *) &ifr.ifr_addr;
  ipaddr= ps->sin_addr.s_addr;
  close(fd);
  return ipaddr;
}

int c_create_server(int port)
{
	struct sockaddr_in server;
	int sock, flag, ret;

//    if((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)
  if((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1)
    {
      perror("server socket err\n");
      return -1;
    }

  /* Отключение алгоритма Нагля (TCP No Delay) - ускоряет сокеты */
  flag = 1;
  ret = setsockopt( sock, IPPROTO_TCP, TCP_NODELAY, (char *)&flag, sizeof(flag) );
  if (ret == -1) {
    printf("Couldn't setsockopt(TCP_NODELAY)\n");
    return -1;
  }

  server.sin_family = AF_INET;
  server.sin_port = htons(port);
  server.sin_addr.s_addr = INADDR_ANY;
  bzero(&server.sin_zero, 8);
//    printf ("Source IP:   %d.%d.%d.%d\n", NIPQUAD(server.sin_addr.s_addr));

  if((bind(sock, (struct sockaddr *)&server, sizeof(struct sockaddr_in))) == -1)
    {
      perror("bind err\n");
      return -1;
    }

  // Вот тут хрень какая-то не нужная - я ее выкинул
   // { int rr; u_char hostname[50];
	// rr=gethostname(&hostname,sizeof(hostname));
	// printf("hostname = %s %d %x\n",hostname,rr,getmyip());
     // {	unsigned ip;

	// strcpy(hostname,"ibm.com");
	// ip=hostname2ip(hostname);
	// printf("%s resolved to %x" , hostname , ip);
     // }
   // }

   // if((listen(sock, 5)) == -1)
   // {
	// perror("listen err");
	// exit(-1);
   // }


   // printf("\nThe TCPServer Waiting for client on port %d\n",ntohs(server.sin_port));
  printf("TCP Server created\n");

  return sock;
}


int c_sock_accept (int sock)
{ int new;
  struct sockaddr_in client;
  int sockaddr_len = sizeof(struct sockaddr_in);

	if((new = accept(sock, (struct sockaddr *)&client, &sockaddr_len)) == -1)
    {
      perror("accept err");
      return -1;
    }
	CIPAddr=client.sin_addr.s_addr;
//	printf("From %x %s:%d\n", CIPAddr,inet_ntoa(client.sin_addr), ntohs(client.sin_port));
	printf("From %x :%d\n", CIPAddr, ntohs(client.sin_port));

	return new;
}


int c_sock_listen(int sock)
{
	return listen(sock, 100);
}

//http://code.metager.de/source/xref/busybox/networking/interface.c#1120

