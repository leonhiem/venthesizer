-- *************************************************************************
-- *            Comperator A < B (unsigned)                                *
-- *************************************************************************
-- HDLPlanner Start compL 
-- Do not **Delete** previous line

library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY compL IS
-- synopsys template
        generic (WIDTH      : integer := 16);
        port(
		DATAA,DATAB  : IN std_logic_vector(WIDTH-1 downto 0);
		ALB          : OUT std_logic
        );
END compL ;

ARCHITECTURE behv OF compL IS
 begin
        process(DATAA,DATAB)    
        begin 
                if (DATAA < DATAB) then
                        ALB <= '1';
                else
                        ALB <= '0';
                end if;
        end process; 

end behv;
-- Do not **Delete** next line
-- HDLPlanner End compL 

