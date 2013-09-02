// FLOAT

#define FPBufSize 1002

double *FP;
double  FPBuf[FPBufSize];

void _0e()
{	FP--;
	FP[0] = 0.0;
}

void x1e()
{	FP--;
	FP[0] = 1.0;
}

int ZTO_FLOAT(char *szInput)
{ char * pEnd; 
	FP--;
	FP[0] = strtod (szInput,&pEnd);
//	if (pEnd == NULL)	return -1;
	while (isspace (*pEnd))	pEnd++;
	return *pEnd == '\0';
}

char buf[40];
int ii;
char * F_dot_STR()
{
   sprintf (buf,"%lf",*FP++);
   for(ii=0;buf[ii];ii++);
// write (0,buf, ii);
   return &buf;
}

void f_store( double * sp0 )
{  * sp0 = *FP++;
}
void f_plus()
{   FP[1] += FP[0];
    FP++;
}
void f_minus()
{   FP[1] -= FP[0];
    FP++;
}

void f_star()
{   FP[1] *= FP[0];
    FP++;
}

void f_slash()
{   FP[1] /= FP[0];
    FP++;
}

int f_zero_less()
{  return *FP++ < 0 ;
}
int f_zero_equal() 
{  return *FP++ < 0 ;
}
int f_less_than()
{ int sp0;
 sp0 = FP[1] < FP[0] ;
 FP += 2;
 return sp0;
}

long long f_to_d()
{  return (long long)(*FP);
}

void f_fetch( double * sp0 )
{ *--FP = *sp0;
}
void ss_to_f ( int sp1, int sp0)
{ FP--;
  FP[0] = (double)( ((long long)(sp0)>>32) + sp1 );
}

void d_to_f ( long long sp)
{ FP--;
  FP[0] = (double)sp;
}

int FCELL_()
{  return sizeof(double) ;
}

void f_init()
{ FP=&FPBuf[FPBufSize-2];

}

void f_tst()
{	_1e();
	Fdot();
}

void f_tst1()
{	f_tst();
}

void f_tst2()
{	f_tst1();
}
