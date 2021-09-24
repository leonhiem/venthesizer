-- HDLPlanner Start sdpram_prl 
-- Do not **Delete** previous line

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY sdpram_prl IS
-- synopsys template
        GENERIC ( ADDR_WIDTH : INTEGER :=  5; 
                  WIDTH      : INTEGER :=  16);
        PORT (
              AIN           : IN std_logic_vector (ADDR_WIDTH-1 downto 0);
              AOUT   : IN std_logic_vector (ADDR_WIDTH-1 downto 0);
              DIN    : IN std_logic_vector (WIDTH-1 downto 0);
              DOUT   : OUT std_logic_vector(WIDTH-1 downto 0);
              OEN           : IN std_logic;
              WEN           : IN std_logic;
              CLK           : IN std_logic);
END sdpram_prl ;
 
ARCHITECTURE behv OF sdpram_prl IS
 
constant clockEdge : std_logic := '1';
constant setOrResetLevel : std_logic := '0';
constant setOrReset: integer := 0;

 
TYPE twoDarray IS
        ARRAY(0 to 2**ADDR_WIDTH - 1) of std_logic_vector (WIDTH-1 downto 0);
SIGNAL mem : twoDarray ;
begin
 
dwrite: process (CLK,WEN,AIN)
VARIABLE write_address : INTEGER;
begin
       if (CLK = clockEdge and CLK'event) then 
          write_address :=  CONV_INTEGER(AIN);
          if(WEN = '0') then
                mem(write_address) <= DIN;
          end if;
       end if;
                
end process dwrite;
 
 
dread: process (OEN,AOUT,mem)
VARIABLE read_address : INTEGER;
begin
                 read_address :=  CONV_INTEGER(AOUT); 
                 if(OEN = '0') then
                                 DOUT <= mem(read_address) ;
                 else
                                 FOR i IN 0 TO (WIDTH - 1) LOOP
                                          DOUT(i) <= 'Z';
                                 END LOOP;      
                 end if;
end process dread;
 
 
end behv;
 
-- Do not **Delete** next line
-- HDLPlanner End sdpram_prl 

