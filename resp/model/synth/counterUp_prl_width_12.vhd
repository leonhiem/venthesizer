-- **************************************************************************
-- *             Frequency divider, width 12                                *
-- **************************************************************************
-- HDLPlanner Start counterUp_prl 
-- Do not **Delete** previous line

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY counterUp_prl IS
-- synopsys template
        generic (WIDTH   : integer := 12);
        port(	
              RN       : IN std_logic;
              CLK      : IN std_logic;
              Q        : OUT std_logic_vector (WIDTH-1 downto 0)              
          );
END counterUp_prl ;

ARCHITECTURE behv OF counterUp_prl IS
 
constant clockEdge : std_logic := '1';
constant setOrResetLevel : std_logic := '0';
constant setOrReset: integer := 1000; --0;


SIGNAL Qtmp	: std_logic_vector(WIDTH-1 downto 0);

begin
    process(CLK,RN)
    begin 
         if(RN = setOrResetLevel) then
                Qtmp <= CONV_STD_LOGIC_VECTOR(setOrReset,WIDTH);
         elsif (CLK = clockEdge and CLK'event) then
                Qtmp <= Qtmp + '1';
         end if;

     end process;

         Q <= Qtmp;

end behv;
-- Do not **Delete** next line
-- HDLPlanner End counterUp_prl 

