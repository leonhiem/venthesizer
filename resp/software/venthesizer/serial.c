/*
 * File:        serial.c
 * Author:      Leon Hiemstra
 * Date:
 * Description: Serial interface fucntions
 *
 */

#include <stdio.h> /* Standard input/output definitions */
#include <stdlib.h>
#include <stdarg.h>
#include <string.h> /* String function definitions */
#include <unistd.h> /* UNIX standard function definitions */
#include <fcntl.h> /* File control definitions */
#include <errno.h> /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/time.h>
#include "serial.h"
#include "system.h"

int is_initialized(void) { return fd_initialized; }


int construct_serial(int nr, Serial_cfg *c)
{
    int status = 0;
    int openflags;
    char dev_name[32];

    DTRstatus=0;

    devnr=nr;
    cfg=*c;
    sprintf(dev_name,UART_0_NAME);
    //sprintf(dev_name,"/dev/USBserial");
    //sprintf(dev_name,"/dev/ttyUSB%d",devnr);
    //sprintf(dev_name,"/dev/USBsolar");
    //printf("constructor Serial\n");


    fd_initialized = 0;

    /* Connect to serial device driver: */

    // O_NOCTTY flag: not "controlling terminal" mode
    // O_NDELAY flag: don't care about the state of the DCD signal line
    openflags = O_RDWR;// | O_NOCTTY;
    if(!cfg.block) openflags |= O_NONBLOCK;

    if((fd = open(dev_name, openflags)) < 0) {
        fprintf(stderr,"Error opening %s reason: %s\n",dev_name,strerror(errno));
        status = -1;
    } else {
        unsigned int baudrate;

        struct termios options;

        if(cfg.block == 1) {
            fcntl(fd, F_SETFL, 0); // blocking IO
        } else {                                 // nonblocking
            //fcntl(fd[devnr], F_SETFL, FASYNC); 
            fcntl(fd, F_SETFL, FNDELAY); 
                                                 /* We don't use NDELAY option
                                                    but we use c_cc[VMIN] and
                                                    c_cc[VTIME] */
        }


        fd_initialized = 1;
    }
    return fd_initialized;
}

void destruct_serial()
{
    //printf("destructor Serial\n");
    if(fd_initialized) {
        close(fd);
    }
}

int Write(const char *buf, int len)
{
    int n=0;

//#define SERIAL_FRAGMENTED 1
//#define SERIAL_FRAGMENTED_WITHDELAY 100000

#ifdef SERIAL_FRAGMENTED
    {
        int i;
        for(i=0;i<len;i++) {
            if((n = write(fd, &buf[i], 1)) < 0) {
                print_err(ID,"Write error: %s\n",strerror(errno));
                return -1;
            }
#ifdef SERIAL_FRAGMENTED_WITHDELAY
            usleep(SERIAL_FRAGMENTED_WITHDELAY);
#endif
        }
    }
#else
    if((n = write(fd, buf, len)) < 0) {
        printf("Write error: %s\n",strerror(errno));
        return -1;
    }
#endif

    return n;
}

int writef(const char *str, ...)
{
    int status=0;
    va_list ap;
    char *cmd = (char *)malloc((strlen(str)+1));

    if(cmd == NULL) 
    { 
        status = -MA_ERR; 
        printf("Malloc error\n");
    }
    else
    {
        va_start(ap, str);
        vsprintf(cmd,str,ap);
        va_end(ap);
        if(Write((const char *)cmd,strlen(cmd)) < 0) status=-WR_ERR;
        free(cmd);
    }
    return status;
}

int Read(char *buf, int len)
{
    int n;

    if((n = read(fd, (void *)buf, len)) < 0) {
        printf("Read error: %s\n",strerror(errno));
        return -1;
    }
    return n;
}

int read_response(char *buf, int len, int to)
{
    int status = 0;
    int read_bytes;

    struct timeval tv;
    unsigned long timeout,newtime;
    gettimeofday(&tv,NULL);
    timeout = tv.tv_sec + to;
    newtime = tv.tv_sec;

    read_bytes=0;
    while((newtime < timeout) && (read_bytes < len))
    {
        int ret;
        gettimeofday(&tv,NULL);
        newtime = tv.tv_sec;

        ret=Read(&buf[read_bytes],(len-read_bytes));
        if(ret < 0) status = -RD_ERR;
        else read_bytes += ret;

        usleep(10);
    }
    if(newtime >= timeout) 
    {
        printf("Timeout error\n");
        status = -TO_ERR;
    }
    else
        status = read_bytes;

    return status;
}

int read_response_to_eos(char *buf, int maxlen, const char eos, const char eos2)
{
    int status = 0;
    int read_bytes;
    char endc = 0;


    read_bytes=0;
    while((read_bytes < maxlen) && 
          (endc != eos) && (endc != eos2) && (status != -RD_ERR))
    {
        int ret;
        int i;
  
        ret=Read(&buf[read_bytes],(maxlen-read_bytes));
  
        if(ret < 0) 
            status = -RD_ERR;
        else {
            for(i=0;(i<ret) && (endc!=eos) && (endc!=eos2);i++) {
                printf("%c",buf[i+read_bytes]);
                if(buf[i+read_bytes] == eos) {
                    endc = eos;
                    read_bytes += i+1;
                } else if(buf[i+read_bytes] == eos2) {
                    endc = eos2;
                    read_bytes += i+1;
                }
            }
            if(endc != eos && endc != eos2) read_bytes += ret;
        }
        //usleep(10);
    }
    status = read_bytes;

    return status;
}

int read_n(char *buf, int len)
{
    int read_bytes;

    read_bytes=0;
    while(read_bytes < len) {
        int ret;

        ret=Read(&buf[read_bytes],(len-read_bytes));
        if(ret < 0) return -RD_ERR;
        else read_bytes += ret;
    }
    return read_bytes;
}

int read_n_synced(char *buf, int len, unsigned char sync)
{
    int read_bytes;
    char firstb=0;


    while(firstb != sync) {
        int ret;

        ret=Read(&firstb,1);
        if(ret < 0) return -RD_ERR;
    }
    buf[0] = firstb;

    read_bytes=1;
    while(read_bytes < len) {
        int ret;

        ret=Read(&buf[read_bytes],(len-read_bytes));
        if(ret < 0) return -RD_ERR;
        else read_bytes += ret;
    }
    return read_bytes;
}

