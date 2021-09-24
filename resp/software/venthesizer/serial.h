#ifndef SERIAL_H
#define SERIAL_H

#define SERIAL_MAX_PORTS 4

#define ID "serial"

/* 
 * Error conditions 
 */
#define RD_ERR  1
#define WR_ERR  2
#define TO_ERR  3
#define MA_ERR  4


typedef struct {
  unsigned int baudrate;   /* Set baudrate */
  int icrnl;               /* Enable translation character CR to NL */
  int crtscts;             /* Set hardware handshake on/off */
  int xonxoff;             /* Set software handshake on/off */
  int block;               /* Enable blocking mode */
  int sendbreak;           /* Send break at init time */
} Serial_cfg;

  int devnr;
  int fd;
  int fd_initialized;
  Serial_cfg cfg;
  int DTRstatus;

int is_initialized(void);
int Write(const char *buf, int len);
int writef(const char *str, ...);
int Read(char *buf, int len);
int read_response(char *buf, int len, int timeout);
int read_response_to_eos(char *buf, int maxlen, char eos, char eos2);
int read_n(char *buf, int len);
int read_n_synced(char *buf, int len, unsigned char sync);

#endif // SERIAL_H

