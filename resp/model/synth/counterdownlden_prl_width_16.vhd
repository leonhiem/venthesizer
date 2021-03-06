-- *********************************************************************
-- *    Counter down parallel load with enable, 16 bit width           *
-- *********************************************************************

-- HDLPlanner Start counterDownLdEn_prl 
-- Do not **Delete** previous line

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY counterDownLdEn_prl IS
-- synopsys template
        generic (WIDTH   : integer := 16);
        port(	
              RN        : IN std_logic;
              CLK       : IN std_logic;
              ENABLE    : IN std_logic;
              DATA      : IN std_logic_vector (WIDTH-1 downto 0);
              SLOAD     : IN std_logic;
              Q         : OUT std_logic_vector (WIDTH-1 downto 0);
              RCO       : OUT std_logic
          );
END counterDownLdEn_prl ;

ARCHITECTURE behv OF counterDownLdEn_prl IS
 
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
                if (ENABLE = '1') then
                        if (SLOAD = '0') then
                                Qtmp <= DATA;
                        else
                                Qtmp <= Qtmp - '1';
                        end if;
                end if;
         end if;
        
         if (Qtmp = CONV_STD_LOGIC_VECTOR(0,WIDTH)) then
                RCO <= '1';
         else
               RCO <= '0';
         end if;
 
   end process;
        
         Q <= Qtmp;

end behv;

-- Do not **Delete** next line
-- HDLPlanner End counterDownLdEn_prl 

