--
-- Project: freqgenerator_test
-- Author: L. Hiemstra
-- Date: Sat Jan 19 14:27:33 MET 2002
--
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
constant setOrReset: integer := 0;

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
constant setOrReset: integer := 0;


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

-- ***********************************************************************
-- *           freqgenerator                                             *
-- ***********************************************************************
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
ENTITY freqgenerator IS
	PORT (
          CLK       :  IN  std_logic;
          CLKIN     :  IN  std_logic;
          DATA      :  IN  std_logic_vector(15 downto 0);
          Q         :  OUT std_logic_vector(15 downto 0);          
          RCO       :  OUT std_logic;                    
          LOADREG   :  IN  std_logic;
          LOADCNT   :  IN  std_logic;                    
          RN        :  IN  std_logic                            
    	);
END freqgenerator;

ARCHITECTURE behaviour of freqgenerator IS
COMPONENT dffIen_prl
  port (
       DATA     : IN std_logic_vector (15 downto 0);
       RN       : IN std_logic; 
       CLK      : IN std_logic;
       ENABLE   : IN std_logic;
       Q        : OUT std_logic_vector (15 downto 0)            
  );
END COMPONENT;
COMPONENT counterDownLdEn_prl
  port (	
       RN        : IN std_logic;
       CLK       : IN std_logic;
       ENABLE    : IN std_logic;
       DATA      : IN std_logic_vector (15 downto 0);
       SLOAD     : IN std_logic;
       Q         : OUT std_logic_vector (15 downto 0);
       RCO       : OUT std_logic       
  );
END COMPONENT;

SIGNAL QDATA           : std_logic_vector (15 downto 0);
SIGNAL LOADCOUNT, RCOS : std_logic;

BEGIN

LOADCOUNT <= NOT (LOADCNT OR RCOS);
RCO <= RCOS;

-- HDLPlanner Instance counterDownLdEn_prl 
-- Do not **DELETE** previous line

u1 : counterDownLdEn_prl 
--GENERIC MAP(WIDTH => WIDTH)
PORT MAP(
            RN => RN,
            CLK => CLKIN,
            ENABLE => '1',            
            DATA => QDATA,
            SLOAD => LOADCOUNT,
            Q => Q,
            RCO => RCOS            
      	);

-- Do not **DELETE** next line
-- HDLPlanner End Instance counterDownLdEn_prl 

-- HDLPlanner Instance dffIen_prl 
-- Do not **DELETE** previous line

u2 : dffIen_prl 
--GENERIC MAP (WIDTH => WIDTH)
PORT MAP(
           DATA => DATA,
           RN => RN,
           CLK => CLK,
           ENABLE => LOADREG,
           Q => QDATA
        );
-- Do not **DELETE** next line
-- HDLPlanner End Instance dffIen_prl 

END behaviour;


