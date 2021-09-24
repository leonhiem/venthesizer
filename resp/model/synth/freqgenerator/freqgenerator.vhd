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

