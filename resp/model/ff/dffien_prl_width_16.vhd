-- ********************************************************************
-- *       D flipflop register with enable, parallel load             *
-- ********************************************************************
-- HDLPlanner Start dffIen_prl 
-- Do not **Delete** previous line

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY dffIen_prl IS
-- synopsys template
       GENERIC (WIDTH      : integer := 16);
       PORT (
              DATA       : IN std_logic_vector (WIDTH-1 downto 0);
              RN         : IN std_logic; 
              CLK        : IN std_logic;
              ENABLE     : IN std_logic;
              Q          : OUT std_logic_vector (WIDTH-1 downto 0)
          );
END dffIen_prl ;

ARCHITECTURE behv OF dffIen_prl IS
 
constant clockEdge : std_logic := '1';
constant setOrResetLevel : std_logic := '0';
constant setOrReset: integer := 2000; --0;

SIGNAL Qtmp	: std_logic_vector(WIDTH-1 downto 0);

BEGIN

       PROCESS(CLK,RN)
       BEGIN
            if(RN = setOrResetLevel) then
                   Qtmp <= CONV_STD_LOGIC_VECTOR(setOrReset,WIDTH);
            elsif (CLK = clockEdge and CLK'event) then
                   if (ENABLE = '1') then
                          Qtmp <= DATA;
                   else
                          Qtmp <= Qtmp;
                   end if;
            end if;
       END PROCESS;
       Q <= Qtmp;
END behv;
              
-- Do not **Delete** next line
-- HDLPlanner End dffIen_prl 

