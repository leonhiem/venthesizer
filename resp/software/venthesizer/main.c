#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h> /* POSIX terminal control definitions */
#include <ctype.h>

#include <alt_types.h>
#include <io.h>
#include "alt_types.h"
#include "sys/alt_irq.h"
#include "altera_nios2_qsys_irq.h"
#include "altera_avalon_uart_regs.h"
#include "altera_avalon_pio_regs.h"
#include "serial.h"
#include "system.h"


/*** Respirator related ***/
#define SLIDER_RATE_LOW       6
#define SLIDER_RATE_UP       60
#define SLIDER_RATE_SET      12

#define SLIDER_IE_LOW         0
#define SLIDER_IE_UP        100
#define SLIDER_IE_SET        30

#define SLIDER_HFRATE_LOW    60
#define SLIDER_HFRATE_UP    250
#define SLIDER_HFRATE_SET   100

#define SLIDER_INTENSITY_LOW  0
#define SLIDER_INTENSITY_UP 100
#define SLIDER_INTENSITY_SET  0

#define SLIDER_PI_LOW         0
#define SLIDER_PI_UP        125
#define SLIDER_PI_SET         0

#define SLIDER_PE_LOW         0
#define SLIDER_PE_UP         75
#define SLIDER_PE_SET         0

#define ADDR_synth01_1_freq        0
#define ADDR_synth01_1_dc          1
#define ADDR_synth1_10_freq_insp   2
#define ADDR_synth1_10_dc_insp     3
#define ADDR_synth1_10_freq_exp    4
#define ADDR_synth1_10_dc_exp      5
#define ADDR_synth225_freq         6
#define ADDR_synth225_dc_inspup    7
#define ADDR_synth225_dc_inspdown  8
#define ADDR_synth225_dc_expup     9
#define ADDR_synth225_dc_expdown  10


char *banner = "\r\nVentesizer LH20200419 (use '?' for help)\r\n";

unsigned short set_addr_to_baseaddr(int addr)
{
    unsigned short baseaddr;
    switch(addr) {
        case ADDR_synth01_1_freq:       printf("[synth01_1 freq]       "); baseaddr=SET_0_BASE; break;
        case ADDR_synth01_1_dc:         printf("[synth01_1 dc]         "); baseaddr=SET_1_BASE; break;
        case ADDR_synth1_10_freq_insp:  printf("[synth1_10 freq insp]  "); baseaddr=SET_2_BASE; break;
        case ADDR_synth1_10_dc_insp:    printf("[synth1_10 dc insp]    "); baseaddr=SET_3_BASE; break;
        case ADDR_synth1_10_freq_exp:   printf("[synth1_10 freq exp]   "); baseaddr=SET_4_BASE; break;
        case ADDR_synth1_10_dc_exp:     printf("[synth1_10 dc exp]     "); baseaddr=SET_5_BASE; break;
        case ADDR_synth225_freq:        printf("[synth225 freq]        "); baseaddr=SET_6_BASE; break;
        case ADDR_synth225_dc_inspup:   printf("[synth225 dc inspup]   "); baseaddr=SET_7_BASE; break;
        case ADDR_synth225_dc_inspdown: printf("[synth225 dc inspdown] "); baseaddr=SET_8_BASE; break;
        case ADDR_synth225_dc_expup:    printf("[synth225 dc expup]    "); baseaddr=SET_9_BASE; break;
        case ADDR_synth225_dc_expdown:  printf("[synth225 dc expdown]  "); baseaddr=SET_10_BASE; break;
        default: printf("[?] "); baseaddr=0xffff; break;
    }
    return baseaddr;
}

int set(int addr, unsigned short val)
{
    unsigned short base_addr = set_addr_to_baseaddr(addr);
    if(base_addr == 0xffff) {
        printf("illegal set address %d\r\n",addr);
        return -1;
    }
    printf("SET%d value=%d (0x%x)\r\n",addr,val,val);
    IOWR_ALTERA_AVALON_PIO_DATA(base_addr, val&0xffff);
    return 0;
}
int get(int addr)
{
    unsigned short base_addr = set_addr_to_baseaddr(addr);
    if(base_addr == 0xffff) {
        printf("illegal set address %d\r\n",addr);
        return -1;
    }
    unsigned short val = IORD_ALTERA_AVALON_PIO_DATA(base_addr);
    printf("SET%d value=%d (0x%x)\r\n",addr,val,val);
    return 0;
}

unsigned short LF,HF,IE;
unsigned short rate_T;
unsigned short ie_DC;
unsigned short hfrate_T;
unsigned short Intensity;
unsigned short Pi;
unsigned short Pe;

char * reinit(void)
{
    int err=0;
    unsigned short dce,dci,pim,pem;
    float intensity = (float)Intensity / 100.;

    float Pim = (float)Pi * (1.0 + intensity);
    float Pem = (Pe + intensity * ((float)Pi - (float)Pe)) * (1.0 + intensity);
    float DCI = 1.0 / (1.0 + intensity);
    float DCE;

    printf("---- reinit start ----\r\n");
    printf("lf=%d BPM\r\n",LF);
    printf("hf=%d BPM\r\n",HF);
    printf("ie=%d %%\r\n",IE);

    printf("Intensity=%d %%\r\n",Intensity);
    printf("Pi=%d mBar Pe=%d mBar \r\n",Pi,Pe);

    if(Pem < 0.01) {
      DCE = 0.0;
    } else {
      DCE = ((float)Pe / ((float)Pe + intensity * ((float)Pi - (float)Pe))) / (1.0 + intensity);
    }

    dci = (unsigned short)((float)hfrate_T * DCI);
    dce = (unsigned short)((float)hfrate_T * DCE);
    pim = (unsigned short)(Pim * 1066.0/(SLIDER_PI_UP * 2.0));
    pem = (unsigned short)(Pem * 1066.0/(SLIDER_PI_UP * 2.0));
    if(pim == 0) pim=1;
    if(pem == 0) pem=1;

    printf("dci=%d dce=%d\r\n",dci,dce);
    printf("pim=%d pem=%d\r\n",pim,pem);

    if(ie_DC==0) ie_DC=1;
    if(ie_DC==rate_T) ie_DC=rate_T-1;

    if(ie_DC > rate_T) {
        err++;
        printf("ERROR: ie_DC > rate_T\r\n");
    }

    if(dci==0) dci=1;
    if(dci==hfrate_T) dci=hfrate_T-1;
    if(dci > hfrate_T) {
        err++;
        printf("ERROR: dci > hfrate_T\r\n");
    }
    if(dce==0) dce=1;
    if(dce==hfrate_T) dce=hfrate_T-1;
    if(dce > hfrate_T) {
        err++;
        printf("ERROR: dce > hfrate_T\r\n");
    }
    if(err !=0) {
        printf("Not updating!\r\n");
    } else {
        set(ADDR_synth01_1_freq,      rate_T);
        set(ADDR_synth01_1_dc,        ie_DC);
        set(ADDR_synth1_10_freq_insp, hfrate_T);
        set(ADDR_synth1_10_dc_insp,   dci);
        set(ADDR_synth1_10_freq_exp,  hfrate_T);
        set(ADDR_synth1_10_dc_exp,    dce);
        set(ADDR_synth225_freq,       0x42a);
        set(ADDR_synth225_dc_inspup,  pim);
        set(ADDR_synth225_dc_inspdown,1);
        set(ADDR_synth225_dc_expup,   pem);
        set(ADDR_synth225_dc_expdown, 1);
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 1);
        usleep(100000);
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0);
    }
    printf("---- reinit end ----\r\n");
    if(err == 0) return "OK"; else return "FAIL";
}

unsigned short convert_rate(unsigned short val)
{
    unsigned short r;
    LF=val;
    float lf = (float)val / 60.0; // to BPM to Hz
    r = (unsigned short)((1.0 / lf) * 6300.0);
    printf("%d BPM, rate_T = %u\r\n",val,r);
    return r;
}
unsigned short convert_hfrate(unsigned short val)
{
    unsigned short r;
    HF=val;
    float hf = (float)val / 60.0; // to BPM to Hz
    r = (unsigned short)((1.0 / hf) * 50400.0);
    printf("%d BPM, hfrate_T = %u\r\n",val,r);
    return r;
}
unsigned short convert_ie(unsigned short val)
{
    unsigned short r;
    IE=val;
    r = (unsigned short)((float)rate_T * ((float)val / 100.0));
    printf("%d %% to ie_DC = %u\r\n",val, r);
    return r;
}

void init(void)
{
    rate_T    = convert_rate(SLIDER_RATE_SET);
    ie_DC     = convert_ie(SLIDER_IE_SET);
    hfrate_T  = convert_hfrate(SLIDER_HFRATE_SET);
    Intensity = SLIDER_INTENSITY_SET;
    Pi        = SLIDER_PI_SET;
    Pe        = SLIDER_PE_SET;
    printf("init %s\r\n",reinit());
}
void demo(void)
{
    rate_T    = convert_rate(12);
    ie_DC     = convert_ie(30);
    hfrate_T  = convert_hfrate(250);
    Intensity = 50;
    Pi        = 25;
    Pe        = 5;
    printf("demo %s\r\n",reinit());
}

int main()
{
    int openflags;
    int n;
    char buf[100];

    usleep(1000000);

    openflags = O_RDWR;// | O_NOCTTY;
    if((fd = open(UART_0_NAME, openflags)) < 0) {
        printf("Error opening %s reason: %s\n\r",UART_0_NAME,strerror(errno));
    } else {
       if((n = write(fd, banner, strlen(banner))) < 0) {
          printf("Write error: %s\n\r",strerror(errno));
       }
       //printf("UART0 open OK\r\n");
       printf("\r\n");
    }

    init();

    while(1) {
        printf("CMD> ");

        int len = read_response_to_eos(buf, 98, '\n', '\r');
        if(len>=0) buf[len]=0;
        if(len>0) {
          printf("\r\n");
          if(strncasecmp(buf,"led=",4)==0) {
            char *bufptr=&buf[4];
            int i;
            for(i=4;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            int val=atoi(bufptr);
            printf("LED value=%d (0x%x)\r\n",val,val);
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, val&0xff);
          } else if(strncasecmp(buf,"setdef",6)==0) {
            set(ADDR_synth01_1_freq,      0x189c);
            set(ADDR_synth01_1_dc,        0x8b8);
            set(ADDR_synth1_10_freq_insp, 0x1870);
            set(ADDR_synth1_10_dc_insp,   0x1810);
            set(ADDR_synth1_10_freq_exp,  0x1120);
            set(ADDR_synth1_10_dc_exp,    0x520);
            set(ADDR_synth225_freq,       0x42a);
            set(ADDR_synth225_dc_inspup,  0x420);
            set(ADDR_synth225_dc_inspdown,0x2);
            set(ADDR_synth225_dc_expup,   0x100);
            set(ADDR_synth225_dc_expdown, 0x2);
            printf("latch by toggle led=1 led=0\r\n");
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 1);
            usleep(100000);
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0);
            printf("done\r\n");
          } else if(strncasecmp(buf,"?set",4)==0) {
            int i;
            for(i=0;i<11;i++) {
                get(i);
            }
          } else if(strncasecmp(buf,"init",4)==0) {
            init();
          } else if(strncasecmp(buf,"demo",4)==0) {
            demo();
          } else if(strncasecmp(buf,"set",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(buf[i]=='=') { buf[i]=0; break; }
            }
            int addr=atoi(bufptr);
            i++;
            bufptr=&buf[i];
            for(;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            set(addr,val);
            printf("latch by toggle led=1 led=0\r\n");
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 1);
            usleep(100000);
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0);
            printf("done\r\n");
          } else if(strncasecmp(buf,"lf=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if((val >= SLIDER_RATE_LOW) && (val <= SLIDER_RATE_UP)) {
              rate_T = convert_rate(val);
              printf("rate %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"ie=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if(val <= SLIDER_IE_UP) {
              ie_DC = convert_ie(val);
              printf("ie %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"hf=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if((val >= SLIDER_HFRATE_LOW) && (val <= SLIDER_HFRATE_UP)) {
              hfrate_T = convert_hfrate(val);
              printf("hfrate %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"in=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if(val <= SLIDER_INTENSITY_UP) {
              Intensity = val;
              printf("Intensity = %d\r\n",val);
              printf("Intensity %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"pi=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if(val <= SLIDER_PI_UP) {
              Pi = val;
              printf("Pi = %d\r\n",val);
              printf("pi %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"pe=",3)==0) {
            char *bufptr=&buf[3];
            int i;
            for(i=3;i<strlen(buf);i++) {
              if(!isdigit(buf[i])) { buf[i]=0; break; }
            }
            unsigned short val=atoi(bufptr);
            if(val <= SLIDER_PE_UP) {
              Pe = val;
              printf("Pe = %d\r\n",val);
              printf("pe %s\r\n",reinit());
            } else printf("range error\r\n");
          } else if(strncasecmp(buf,"?",1)==0) {
            printf("lf=N (%d to %d) init=%d\r\n",SLIDER_RATE_LOW,SLIDER_RATE_UP,SLIDER_RATE_SET);
            printf("ie=N (%d to %d) init=%d\r\n",SLIDER_IE_LOW,SLIDER_IE_UP,SLIDER_IE_SET);
            printf("hf=N (%d to %d) init=%d\r\n",SLIDER_HFRATE_LOW,SLIDER_HFRATE_UP,SLIDER_HFRATE_SET);
            printf("in=N (%d to %d) init=%d\r\n",SLIDER_INTENSITY_LOW,SLIDER_INTENSITY_UP,SLIDER_INTENSITY_SET);
            printf("pi=N (%d to %d) init=%d\r\n",SLIDER_PI_LOW,SLIDER_PI_UP,SLIDER_PI_SET);
            printf("pe=N (%d to %d) init=%d\r\n",SLIDER_PE_LOW,SLIDER_PE_UP,SLIDER_PE_SET);
            printf("\r\n");
            printf("led=N\r\n");
            printf("setdef\r\n");
            printf("?set\r\n");
            printf("init\r\n");
            printf("demo\r\n");
            printf("setN=M\r\n");
          } else {
            printf("No such command\r\n");
          }
        }
    }

  return 0;
}
