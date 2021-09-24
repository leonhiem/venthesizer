  -------------------------------------------------------------------
  -- Wave generator
  -------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wavegenerator is
  port (
     Clk            : in Std_logic;
     Reset          : in Std_logic;
     DATA           : in Std_logic_vector(15 downto 0);
     synth_addr     : in Std_logic_vector(1 downto 0);
     synth01_1wr    : in Std_logic;
     synth1_10wr    : in Std_logic;
     synth225wr     : in Std_logic;
     synth01_1out   : out Std_logic;
     synth1_10out   : out Std_logic;
     synth225out    : out Std_logic;
     inspup         : out Std_logic;
     inspdown       : out Std_logic;
     expup          : out Std_logic;
     expdown        : out Std_logic
);
end wavegenerator;

architecture behv of wavegenerator is
  component counterUp_prl is
  port (
         RN      : IN std_logic;
         CLK     : IN std_logic;
         Q       : OUT std_logic_vector (11 downto 0));
  end component;
  component synthesizer IS
  PORT (
          CLOCK     :  IN  std_logic;
          CLKIN     :  IN  std_logic;
          RESET     :  IN  std_logic;
          DATA      :  IN  std_logic_vector(15 downto 0);          
          ADDR      :  IN  std_logic_vector(1 downto 0);          
          WR        :  IN  std_logic;
          SYNTH_OUT :  OUT std_logic);          
  end component;

  signal clksignal : std_logic_vector(11 downto 0);
  signal synth01_1out_i : std_logic;
  signal synth1_10out_i : std_logic;

begin
  ---------------------------------------------------------------------
  -- Instantiation of components
  ---------------------------------------------------------------------
  synth01_1 : synthesizer port map (Clk,clksignal(10),Reset,DATA,
                                    synth_addr,synth01_1wr,synth01_1out_i);
  synth1_10 : synthesizer port map (Clk,clksignal(7),Reset,DATA,
                                    synth_addr,synth1_10wr,synth1_10out_i);
  synth225  : synthesizer port map (Clk,Clk,Reset,DATA,
                                    synth_addr,synth225wr,synth225out);

synth01_1out <= synth01_1out_i;
synth1_10out <= synth1_10out_i;

-- HDLPlanner Instance counterUp_prl
-- Do not **DELETE** previous line

freqdiv : counterUp_prl
--GENERIC MAP(WIDTH => WIDTH)
PORT MAP(
            RN  => Reset,
            CLK => Clk,
            Q   => clksignal
        );

-- Do not **DELETE** next line
-- HDLPlanner End Instance counterUp_prl 

  inspup   <= '1' when (synth01_1out_i = '1' AND synth1_10out_i = '1') else '0';
  inspdown <= '1' when (synth01_1out_i = '1' AND synth1_10out_i = '0') else '0';
  expup    <= '1' when (synth01_1out_i = '0' AND synth1_10out_i = '1') else '0';
  expdown  <= '1' when (synth01_1out_i = '0' AND synth1_10out_i = '0') else '0';
  
end behv; 

