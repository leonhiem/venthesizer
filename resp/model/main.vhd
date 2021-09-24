
library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.ALL;

entity respif is
  port (
     Clk     : in Std_logic;
     Reset   : in Std_logic;
     DSPADDR : in Std_logic_vector(4 downto 0);
     DSPDATA : inout Std_logic_vector(15 downto 0);
     DATA_   : out std_logic_vector(15 downto 0);     
     CS      : in Std_logic;
     WR      : in Std_logic;
     RD      : in Std_logic;
     DSPWAIT : out std_logic;
     MEMADDR_ : out Std_logic_vector(4 downto 0);
     MEMRD_   : out std_logic;
     MEMWR_   : out std_logic;
     state_    : out std_logic_vector(3 downto 0);
     synthset  : out std_logic_vector(4 downto 0);
     reinit    : in Std_logic ;
     resp_phase : out Std_logic_vector(1 downto 0);
     synth01_1out   : out Std_logic;
     synth1_10out   : out Std_logic;
     synth225out    : out Std_logic;
     rco01_1        : out std_logic;
     rco1_10        : out std_logic;
     rco225         : out std_logic
);
end respif;


architecture toplev of respif is
COMPONENT sdpram_prl
  port (
        AIN    : IN std_logic_vector (4 downto 0);
        AOUT   : IN std_logic_vector (4 downto 0);
        DIN    : IN std_logic_vector (15 downto 0);
        DOUT   : OUT std_logic_vector(15 downto 0);
        OEN    : IN std_logic;
        WEN    : IN std_logic;
        CLK    : IN std_logic);
END COMPONENT;

COMPONENT wavegenerator
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
     expdown        : out Std_logic;
     adcclk         : out Std_logic;
     rco01_1        : out std_logic;
     rco1_10        : out std_logic;
     rco225         : out std_logic
);
END COMPONENT;


constant s0 : std_logic_vector(3 downto 0) := "0000";
constant s1 : std_logic_vector(3 downto 0) := "0001";
constant s2 : std_logic_vector(3 downto 0) := "0010";
constant s3 : std_logic_vector(3 downto 0) := "0011";
constant s4 : std_logic_vector(3 downto 0) := "0100";
constant s5 : std_logic_vector(3 downto 0) := "0101";
constant s6 : std_logic_vector(3 downto 0) := "0110";
constant s7 : std_logic_vector(3 downto 0) := "0111";
constant s8 : std_logic_vector(3 downto 0) := "1000";
constant s9 : std_logic_vector(3 downto 0) := "1001";
constant sa : std_logic_vector(3 downto 0) := "1010";
constant sb : std_logic_vector(3 downto 0) := "1011";
constant sc : std_logic_vector(3 downto 0) := "1100";
constant sd : std_logic_vector(3 downto 0) := "1101";
constant se : std_logic_vector(3 downto 0) := "1110";
constant sf : std_logic_vector(3 downto 0) := "1111";

signal c_state : std_logic_vector(3 downto 0);
signal n_state : std_logic_vector(3 downto 0);

signal adcclk   : Std_logic;

signal inspup    : Std_logic;
signal inspdown  : Std_logic;
signal expup     : Std_logic;
signal expdown   : Std_logic;

signal synth01_1out_ : Std_logic;
signal synth1_10out_ : Std_logic;

signal synth_set : Std_logic_vector(4 downto 0);

signal MEMRD     : std_logic;
signal MEMWR     : std_logic;
signal MEMADDR   : std_logic_vector (4 downto 0);

signal DATA : std_logic_vector(15 downto 0);

signal DATADIR : std_logic;
signal DATAOE : std_logic;

signal init_inspup   : boolean;
signal init_expup    : boolean;
signal init_expup1   : boolean;


BEGIN

-- HDLPlanner Instance sdpram_prl 
Ins : sdpram_prl 
--GENERIC MAP (	ADDR_WIDTH => 5,
--		WIDTH => 16)
PORT MAP (
	AIN  => MEMADDR,
	AOUT => MEMADDR,
	DIN  => DATA,
	DOUT => DATA,
	OEN  => MEMRD,
	WEN  => MEMWR,
	CLK  => Clk
  );
-- HDLPlanner End Instance sdpram_prl 

wavegen : wavegenerator 
port map (
     Clk            => Clk,
     Reset          => Reset,
     DATA           => DATA,
     synth_addr     => synth_set(1 downto 0),
     synth01_1wr    => synth_set(2),
     synth1_10wr    => synth_set(3),
     synth225wr     => synth_set(4),
     synth01_1out   => synth01_1out_,
     synth1_10out   => synth1_10out_,
     synth225out    => synth225out,
     inspup         => inspup,
     inspdown       => inspdown,
     expup          => expup,
     expdown        => expdown,
     adcclk         => adcclk,
     rco01_1        => rco01_1,
     rco1_10        => rco1_10,
     rco225         => rco225
);

synth1_10out <= synth1_10out_;
synth01_1out <= synth01_1out_;

resp_phase(0) <= not synth1_10out_;
resp_phase(1) <= not synth01_1out_;  

synthset <= synth_set;


  MEMRD_ <= MEMRD;
  MEMWR_ <= MEMWR;

  MEMADDR_ <= MEMADDR;
  state_ <= c_state;

  DATA_ <= DATA;

dspif : process ( Clk )
begin
  if (Clk = '0' and Clk'event) then
    if (DATADIR = '0' AND DATAOE = '1') then
      DSPDATA <= DATA;
    elsif (DATADIR = '1' AND DATAOE = '1') then
      DATA <= DSPDATA;
    elsif (RD = '0') then
      DSPDATA <= DSPDATA;
    else
      DATA <= (others => 'Z');
      DSPDATA <= (others => 'Z');
    end if;
  end if;
end process dspif;


main : process( c_state )
  variable stage  : integer range 0 to 7;
  variable n_stage  : integer range 0 to 7;
begin
  n_state <= c_state;
  case c_state is
    when s0 =>
       synth_set <= (others => '0');
       MEMWR <= '1';
       MEMRD <= '1';
       DATADIR <= '0';
       DATAOE <= '0';
       DSPWAIT <= '0';
       init_inspup <= false;
       init_expup <= false;
       init_expup1 <= false;
       n_state <= s1;
    when s1 =>
       if (reinit = '1') then
         n_state <= s4;
       else

       --
       -- Check DSP Interface:
       --
       if (WR = '0' AND CS = '0') then
         MEMADDR <= DSPADDR; MEMWR <= '0';
         DATADIR <= '1'; DATAOE <= '1';

       elsif (RD = '0' AND CS = '0') then
         MEMADDR <= DSPADDR; MEMRD <= '0';
         DATADIR <= '0'; DATAOE <= '1';


       --
       -- Check Inspiration-Up Phase:
       --
       elsif (inspup = '1' and not init_inspup) then
         MEMADDR <= "00000"; MEMRD <= '0';
         synth_set <= "00100"; -- synth01_1
         init_inspup <= true;
         stage := 5;

       --
       -- Check Inspiration-Down Phase:
       --
       elsif (inspdown = '1') then
         MEMADDR <= "01000"; MEMRD <= '0';
         synth_set <= "10010"; -- synth225

       --
       -- Check Expiration-Up Phase:
       --
       elsif (expup = '1' and not init_expup) then
         MEMADDR <= "00101"; MEMRD <= '0';
         synth_set <= "01010"; -- synth1_10
         init_expup <= true;

       --
       -- Check Expiration-Down Phase:
       --
       elsif (expdown = '1') then
         MEMADDR <= "01010"; MEMRD <= '0';
         synth_set <= "10010"; -- synth225

       --
       -- Process Initialisation Stages for Inspiration-Up:
       --
       elsif (init_inspup) then
         case stage is
           when 4 =>
             MEMADDR <= "00001"; MEMRD <= '0';
             synth_set <= "00110"; -- synth01_1
           when 3 =>
             MEMADDR <= "00010"; MEMRD <= '0';
             synth_set <= "01000"; -- synth1_10
           when 2 =>
             MEMADDR <= "00100"; MEMRD <= '0';
             synth_set <= "01010"; -- synth1_10
           when 1 =>
             MEMADDR <= "00110"; MEMRD <= '0';
             synth_set <= "10000"; -- synth225
           --when 0 =>
           --  MEMADDR <= "00111"; MEMRD <= '0';
           --  synth_set <= "10010"; -- synth225
           when others =>
             MEMADDR <= "00111"; MEMRD <= '0';
             synth_set <= "10010"; -- synth225
         end case;

       --
       -- Process Initialisation Stages for Expiration-Up:
       --
       elsif (init_expup) then
         if (init_expup1) then
             MEMADDR <= "01001"; MEMRD <= '0';
             synth_set <= "10010"; -- synth225
         end if;

       end if;
       n_state <= s2;
       end if;

    when s2 =>
       n_state <= s3;

    when s3 =>
       MEMWR <= '1';
       MEMRD <= '1';
       synth_set <= (others => '0');
       DATADIR <= '0'; DATAOE <= '0';

       --
       -- Finish Initialisation Stages for Inspiration-Up:
       --
       if (init_inspup) then

         case stage is
           when 5|4|3|2|1 =>
             n_stage := stage - 1;
           --when 0 =>
           when others =>
             init_inspup <= false;
         end case;
         stage := n_stage;

       --
       -- Finish Initialisation Stages for Expiration-Up:
       --
       elsif (init_expup) then
         if (init_expup1) then
           init_expup <= false;
           init_expup1 <= false;
         else
           init_expup1 <= true;
         end if;

       end if;
       n_state <= s1;


    -- Re init synthesizer 01_1:
    when s4 =>
       DSPWAIT <= '1';
       MEMADDR <= "00000"; MEMRD <= '0';
       synth_set <= "00100"; -- synth01_1
       n_state <= s5;
    when s5 =>
       synth_set <= "00101"; -- synth01_1
       n_state <= s6;
    when s6 =>
       MEMADDR <= "00001"; 
       synth_set <= "00110"; -- synth01_1
       n_state <= s7;
    when s7 =>
       synth_set <= "00111"; -- synth01_1
       n_state <= s8;

    -- Re init synthesizer 1_10:
    when s8 =>
       MEMADDR <= "00010"; 
       synth_set <= "01000"; -- synth1_10
       n_state <= s9;
    when s9 =>
       synth_set <= "01001"; -- synth1_10
       n_state <= sa;
    when sa =>
       MEMADDR <= "00100"; 
       synth_set <= "01010"; -- synth1_10
       n_state <= sb;
    when sb =>
       synth_set <= "01011"; -- synth1_10
       n_state <= sc;

    -- Re init synthesizer 225:
    when sc =>
       MEMADDR <= "00110"; 
       synth_set <= "10000"; -- synth225
       n_state <= sd;
    when sd =>
       synth_set <= "10001"; -- synth225
       n_state <= se;
    when se =>
       MEMADDR <= "00111"; 
       synth_set <= "10010"; -- synth225
       n_state <= sf;
    when sf =>
       synth_set <= "10011"; -- synth225
       DSPWAIT <= '0';
       n_state <= s1;
    when others =>
       n_state <= s0;

  end case;
end process main;

PROCESS ( Clk, Reset )
  BEGIN
    if Reset = '0' then c_state <= s0;
    elsif Clk = '1' and Clk'event then c_state <= n_state;
  end if;
END PROCESS;


end toplev; 


