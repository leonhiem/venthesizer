--
-- Project: synthesizer_test
-- Author: L. Hiemstra
-- Date: Sat Jan 19 19:22:48 MET 2002
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

-- ***********************************************************************
-- *           Synthesizer                                               *
-- ***********************************************************************
LIBRARY ieee ;
USE ieee.std_logic_1164.all;
ENTITY synthesizer IS
	PORT (
          CLOCK     :  IN  std_logic;
          CLKIN     :  IN  std_logic;
          RESET     :  IN  std_logic;                            
          DATA      :  IN  std_logic_vector(15 downto 0);          
          ADDR      :  IN  std_logic_vector(1 downto 0);                    
          WR        :  IN  std_logic;
          SYNTH_OUT :  OUT std_logic;
          QAchk      :  OUT  std_logic_vector(15 downto 0);          
          QBchk      :  OUT  std_logic_vector(15 downto 0)          
    	);
END synthesizer;

ARCHITECTURE behaviour of synthesizer IS
COMPONENT dffIen_prl
  port (
       DATA     : IN std_logic_vector (15 downto 0);
       RN       : IN std_logic; 
       CLK      : IN std_logic;
       ENABLE   : IN std_logic;
       Q        : OUT std_logic_vector (15 downto 0)            
  );
END COMPONENT;
COMPONENT compL
  port (
       DATAA,DATAB  : IN std_logic_vector(15 downto 0);
       ALB          : OUT std_logic
  );
END COMPONENT;
COMPONENT freqgenerator
  port (
       CLK       :  IN  std_logic;
       CLKIN     :  IN  std_logic;
       DATA      :  IN  std_logic_vector(15 downto 0);
       Q         :  OUT std_logic_vector(15 downto 0);       
       RCO       :  OUT std_logic;
       LOADREG   :  IN  std_logic;
       LOADCNT   :  IN  std_logic;                    
       RN        :  IN  std_logic       
  );
END COMPONENT;

SIGNAL QB : std_logic_vector (15 downto 0);
SIGNAL QBprep : std_logic_vector (15 downto 0);
SIGNAL QA : std_logic_vector (15 downto 0);
SIGNAL RCOS : std_logic;
SIGNAL LOADprep : std_logic;
SIGNAL LOAD : std_logic_vector(3 downto 0);

BEGIN

LOAD(0) <= '1' when (ADDR(0) = '0' AND ADDR(1) = '0' AND WR = '1') else '0';
LOAD(1) <= '1' when (ADDR(0) = '1' AND ADDR(1) = '0' AND WR = '1') else '0';
LOAD(2) <= '1' when (ADDR(0) = '0' AND ADDR(1) = '1' AND WR = '1') else '0';
LOAD(3) <= '1' when (ADDR(0) = '1' AND ADDR(1) = '1' AND WR = '1') else '0';

LOADprep <= (RCOS OR LOAD(3));

QAchk <= QA;
QBchk <= QB;

u1 : freqgenerator 
PORT MAP(
          LOADREG => LOAD(0),
          LOADCNT => LOAD(1),                    
          DATA => DATA,
          RN => RESET,
          CLK => CLOCK,
          CLKIN => CLKIN,          
          Q => QA,
          RCO => RCOS          
      	);

-- HDLPlanner Instance compL 
-- Do not **DELETE** previous line

u2 : compL 
--GENERIC MAP (WIDTH => WIDTH)
PORT MAP (
			DATAA	=>	QA,
			DATAB 	=>	QB,
			ALB 	=>	SYNTH_OUT );

-- Do not **DELETE** next line
-- HDLPlanner End Instance compL 

-- HDLPlanner Instance dffIen_prl 
-- Do not **DELETE** previous line

u3 : dffIen_prl 
--GENERIC MAP (WIDTH => WIDTH)
PORT MAP(
           DATA => QBprep,
           RN => RESET,
           CLK => CLOCK,
           ENABLE => LOADprep,
           Q => QB
        );
-- Do not **DELETE** next line
-- HDLPlanner End Instance dffIen_prl 


-- HDLPlanner Instance dffIen_prl 
-- Do not **DELETE** previous line

prep : dffIen_prl 
--GENERIC MAP (WIDTH => WIDTH)
PORT MAP(
           DATA => DATA,
           RN => RESET,
           CLK => CLOCK,
           ENABLE => LOAD(2),
           Q => QBprep
        );
-- Do not **DELETE** next line
-- HDLPlanner End Instance dffIen_prl 

END behaviour;


