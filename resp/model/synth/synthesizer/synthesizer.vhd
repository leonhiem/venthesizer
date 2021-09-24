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
          SYNTH_OUT :  OUT std_logic          
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

