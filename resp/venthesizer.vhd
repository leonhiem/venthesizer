library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


--*****************************************************************************
--*  DEFINE: Entity                                                           *
--*****************************************************************************

 
entity venthesizer is
  port ( 
         --
         -- Input clock 
         --
         clk_50      : in  std_logic;
        
         --
         -- SDRAM interface,
         -- here a IS42S16160B (143MHz@CL-3) is used.
         -- Reference is made to ISSI datasheet:
         -- IS42S16160B, 12/14/05 
         --        
         SDRAM_CLK     : out   std_logic;                       -- Master Clock
         SDRAM_CKE     : out   std_logic;                       -- Clock Enable    
         SDRAM_CS_N    : out   std_logic;                       -- Chip Select
         SDRAM_RAS_N   : out   std_logic;                       -- Row Address Strobe
         SDRAM_CAS_N   : out   std_logic;                       -- Column Address Strobe
         SDRAM_WE_N    : out   std_logic;                       -- Write Enable
         SDRAM_DQ      : inout std_logic_vector(15 downto 0);   -- Data I/O (16 bits)
         SDRAM_DQML    : out   std_logic;                       -- Output Disable / Write Mask (low)
         SDRAM_DQMU    : out   std_logic;                       -- Output Disable / Write Mask (high)
         SDRAM_ADDR    : out   std_logic_vector(12 downto 0);   -- Address Input (13 bits)
         SDRAM_BA_0    : out   std_logic;                       -- Bank Address 0
         SDRAM_BA_1    : out   std_logic;                       -- Bank Address 1
			
			--
         -- UART_0
         --
         UART0_TXD      : out   std_logic;
         UART0_RXD      : in    std_logic;

			
         -- EPCS
         --
         EPCS_DCLK     : out   std_logic;
         EPCS_SCE     : out   std_logic;
         EPCS_SDO     : out   std_logic;
         EPCS_DATA0    : in    std_logic;
       
        --
         -- Swithes and keys
         --
         KEY           : in    std_logic_vector(1 downto 0);
         SW            : in    std_logic_vector(3 downto 0);
        		 
         --
         -- LEDs, green and heartbeat
         --
         pio_led     : out   std_logic_vector(7 downto 0);
			gpio0       : out   std_logic_vector(7 downto 0);
			
			valve_out   : out   std_logic;
			valve_out_n : out   std_logic
       );
end entity venthesizer;

architecture syn of venthesizer is

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


 component system is
        port (
            clk_clk         : in    std_logic                     := 'X';             -- clk
            pio_led_export  : out   std_logic_vector(7 downto 0);                     -- export
            epcs_dclk       : out   std_logic;                                        -- dclk
            epcs_sce        : out   std_logic;                                        -- sce
            epcs_sdo        : out   std_logic;                                        -- sdo
            epcs_data0      : in    std_logic                     := 'X';             -- data0
            sdram_addr      : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_ba        : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n     : out   std_logic;                                        -- cas_n
            sdram_cke       : out   std_logic;                                        -- cke
            sdram_cs_n      : out   std_logic;                                        -- cs_n
            sdram_dq        : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_dqm       : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_ras_n     : out   std_logic;                                        -- ras_n
            sdram_we_n      : out   std_logic;                                        -- we_n
            uart_0_rxd      : in    std_logic                     := 'X';             -- rxd
            uart_0_txd      : out   std_logic;                                        -- txd
            reset_reset_n   : in    std_logic                     := 'X';             -- reset_n            
            pio_0_export    : out   std_logic_vector(7 downto 0);                     -- export            
            pio_key_export  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
            pio_sw_export   : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export            
				
				set_0_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_0_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_1_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_1_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_2_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_2_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_3_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_3_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_4_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_4_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_5_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_5_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_6_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_6_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_7_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_7_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_8_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_8_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_9_in_port   : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_9_out_port  : out   std_logic_vector(15 downto 0);                    -- out_port
            set_10_in_port  : in    std_logic_vector(15 downto 0) := (others => 'X'); -- in_port
            set_10_out_port : out   std_logic_vector(15 downto 0)                     -- out_port
        );
    end component system;
    
     component pll_sys
     port ( 
            inclk0   : in  std_logic  := '0';
            c0       : out std_logic ;
            c1       : out std_logic ;
            c2       : out std_logic ;
				c3       : out std_logic ;
            locked   : out std_logic 
          );
   end component pll_sys;

   
component wavegenerator 
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
end component wavegenerator;


  signal clk_sys    : std_logic;
  signal clk_24     : std_logic;
  signal clk_12     : std_logic;
  signal pll_locked : std_logic;
  SIGNAL system_reset_shift  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');                      

  signal reset      : std_logic;
  signal reset_n      : std_logic;
   signal sdram_ba   : std_logic_vector(1 downto 0);
   signal sdram_dqm  : std_logic_vector(1 downto 0);
   signal led_register   : std_logic_vector(7 downto 0);
   signal pulse    : std_logic;

  signal synth01_1out : std_logic;
  signal synth1_10out : std_logic;
  signal synth225out  : std_logic;
    
  signal reinit         : std_logic;
  
  signal wave_data : std_logic_vector(15 downto 0);
  signal synth_set : std_logic_vector(4 downto 0);
  signal inspup    : std_logic;
  signal inspdown  : std_logic;
  signal expup     : std_logic;
  signal expdown   : std_logic;

  signal synth01_1_freq       : std_logic_vector (15 downto 0);     
  signal synth01_1_dc         : std_logic_vector (15 downto 0);   
  signal synth1_10_insp_freq  : std_logic_vector (15 downto 0);  
  signal synth1_10_insp_dc    : std_logic_vector (15 downto 0);   
  signal synth1_10_exp_freq   : std_logic_vector (15 downto 0);  
  signal synth1_10_exp_dc     : std_logic_vector (15 downto 0);   
  signal synth225_freq        : std_logic_vector (15 downto 0);   
  signal synth_inspup_dc      : std_logic_vector (15 downto 0);   
  signal synth_inspdown_dc    : std_logic_vector (15 downto 0);   
  signal synth_expup_dc       : std_logic_vector (15 downto 0);   
  signal synth_expdown_dc     : std_logic_vector (15 downto 0);   
				

  TYPE t_reg IS RECORD
    state : std_logic_vector(3 downto 0);
    wave_data   : std_logic_vector(15 downto 0);
    synth_set   : std_logic_vector(4 downto 0);

    init_inspup   : boolean;
    init_expup    : boolean;
    init_expup1   : boolean;

    stage  : integer range 0 to 7;
  END RECORD;

  signal r, nxt_r : t_reg;


begin
   		
  reinit <= led_register(0);
  
  u_wavegen : wavegenerator 
  port map (
     Clk            => clk_24,
     Reset          => reset_n,
     DATA           => wave_data,
     synth_addr     => synth_set(1 downto 0),
     synth01_1wr    => synth_set(2),
     synth1_10wr    => synth_set(3),
     synth225wr     => synth_set(4),
     synth01_1out   => synth01_1out,
     synth1_10out   => synth1_10out,
     synth225out    => synth225out,
     inspup         => inspup,
     inspdown       => inspdown,
     expup          => expup,
     expdown        => expdown     
);



main : process(reset_n, r, reinit,
  synth01_1_freq, 
  synth01_1_dc, 
  synth1_10_insp_freq,
  synth1_10_insp_dc, 
  synth1_10_exp_freq,
  synth1_10_exp_dc,
  synth225_freq,
  synth_inspup_dc,
  synth_inspdown_dc,
  synth_expup_dc,
  synth_expdown_dc,
  inspup,
  inspdown,
  expup,
  expdown
) 

  variable v: t_reg;
begin
  v := r; -- defaults

  case r.state is
    when s0 =>
       v.synth_set   := (others => '0');       
       v.init_inspup := false;
       v.init_expup  := false;
       v.init_expup1 := false;
       v.wave_data   := (others=>'Z');
       v.state       := s1;
    when s1 =>
       --if (KEY(0) = '0') then
       if (reinit = '1') then
         v.state := s4;
       else


       --
       -- Check Inspiration-Up Phase:
       --
       if (inspup = '1' and not r.init_inspup) then
         v.wave_data := synth01_1_freq;
         v.synth_set := "00100"; -- synth01_1
         v.init_inspup := true;
         v.stage := 5;

       --
       -- Check Inspiration-Down Phase:
       --
       elsif (inspdown = '1') then
         v.wave_data := synth_inspdown_dc;
         v.synth_set := "10010"; -- synth225

       --
       -- Check Expiration-Up Phase:
       --
       elsif (expup = '1' and not r.init_expup) then
         v.wave_data := synth1_10_exp_dc;
         v.synth_set := "01010"; -- synth1_10
         v.init_expup := true;

       --
       -- Check Expiration-Down Phase:
       --
       elsif (expdown = '1') then
         v.wave_data := synth_expdown_dc;
         v.synth_set := "10010"; -- synth225

       --
       -- Process Initialisation Stages for Inspiration-Up:
       --
       elsif (r.init_inspup) then
         case r.stage is
           when 4 =>
             v.wave_data := synth01_1_dc;
             v.synth_set := "00110"; -- synth01_1
           when 3 =>
             v.wave_data := synth1_10_insp_freq;
             v.synth_set := "01000"; -- synth1_10
           when 2 =>
             v.wave_data := synth1_10_insp_dc;
             v.synth_set := "01010"; -- synth1_10
           when 1 =>
             v.wave_data := synth225_freq;
             v.synth_set := "10000"; -- synth225
           when others =>
             v.wave_data := synth_inspup_dc;
             v.synth_set := "10010"; -- synth225
         end case;

       --
       -- Process Initialisation Stages for Expiration-Up:
       --
       elsif (r.init_expup) then
         if (r.init_expup1) then
             v.wave_data := synth_expup_dc;
             v.synth_set := "10010"; -- synth225
         end if;

       end if;
       v.state := s2;
       end if;

    when s2 =>
       v.state := s3;

    when s3 =>       
       v.synth_set := (others => '0');
       
       --
       -- Finish Initialisation Stages for Inspiration-Up:
       --
       if (r.init_inspup) then

         case r.stage is
           when 5|4|3|2|1 =>
             v.stage := r.stage - 1;
           --when 0 =>
           when others =>
             v.init_inspup := false;
         end case;

       --
       -- Finish Initialisation Stages for Expiration-Up:
       --
       elsif (r.init_expup) then
         if (r.init_expup1) then
           v.init_expup := false;
           v.init_expup1 := false;
         else
           v.init_expup1 := true;
         end if;
       end if;
       v.state := s1;


    -- Re init synthesizer 01_1:
    when s4 =>
       v.wave_data := synth01_1_freq;
       v.synth_set := "00100"; -- synth01_1
       v.state := s5;
    when s5 =>
       v.synth_set := "00101"; -- synth01_1
       v.state := s6;
    when s6 =>
       v.wave_data := synth01_1_dc; 
       v.synth_set := "00110"; -- synth01_1
       v.state := s7;
    when s7 =>
       v.synth_set := "00111"; -- synth01_1
       v.state := s8;

    -- Re init synthesizer 1_10:
    when s8 =>
       v.wave_data := synth1_10_insp_freq;  
       v.synth_set := "01000"; -- synth1_10
       v.state := s9;
    when s9 =>
       v.synth_set := "01001"; -- synth1_10
       v.state := sa;
    when sa =>
       v.wave_data := synth1_10_exp_freq; 
       v.synth_set := "01010"; -- synth1_10
       v.state := sb;
    when sb =>
       v.synth_set := "01011"; -- synth1_10
       v.state := sc;

    -- Re init synthesizer 225:
    when sc =>
       v.wave_data := synth225_freq; 
       v.synth_set := "10000"; -- synth225
       v.state := sd;
    when sd =>
       v.synth_set := "10001"; -- synth225
       v.state := se;
    when se =>
       v.wave_data := synth_inspup_dc; 
       v.synth_set := "10010"; -- synth225
       v.state := sf;
    when sf =>
       v.synth_set := "10011"; -- synth225       
       v.state := s1;
    when others =>
       v.state := s0;

  end case;

  if reset_n = '0' then
    v.state := s0;
  end if;

  nxt_r <= v; -- updating registers

end process main;

PROCESS ( clk_24 )
  BEGIN
    if rising_edge(clk_24) then 
      r <= nxt_r;
    end if;
END PROCESS;


  -- connect to outside world
  wave_data <= r.wave_data;
  synth_set <= r.synth_set;


	valve_out <=  synth225out;
	valve_out_n <= NOT synth225out;
	
   pio_led(2) <= synth01_1out;
	pio_led(1) <= synth1_10out;
	pio_led(0) <= synth225out;
	
	pio_led(7) <= inspup;
	pio_led(6) <= inspdown;
	pio_led(5) <= expup;
	pio_led(4) <= expdown;

   inst_pll_sys : pll_sys
      port map ( 
                 inclk0 => clk_50,
                 c0     => clk_sys,
                 c1     => SDRAM_CLK,
                 c2     => clk_24,
					  c3     => clk_12,
                 locked => pll_locked
               );

   system_pll_reset: PROCESS(clk_sys)
   BEGIN
      IF RISING_EDGE(clk_sys) THEN
         system_reset_shift <= system_reset_shift(6 DOWNTO 0) & NOT(pll_locked);
      END IF;
   END PROCESS;

   reset <= system_reset_shift(7);
   reset_n <= NOT reset;



    u0 : system
        port map (
            clk_clk        => clk_sys,
            reset_reset_n  => reset_n,

            pio_led_export => led_register,
				pio_0_export   => gpio0,
				
				pio_key_export => KEY,
            pio_sw_export  => SW,
					  
									  
            epcs_dclk      => EPCS_DCLK,
            epcs_sce       => EPCS_SCE,
            epcs_sdo       => EPCS_SDO,
            epcs_data0     => EPCS_DATA0,

            sdram_addr     => SDRAM_ADDR,
            sdram_ba       => sdram_ba,
            sdram_cas_n    => sdram_cas_n, 
            sdram_cke      => sdram_cke,
            sdram_cs_n     => sdram_cs_n,
            sdram_dq       => sdram_dq, 
            sdram_dqm      => sdram_dqm, 
            sdram_ras_n    => sdram_ras_n,
            sdram_we_n     => sdram_we_n,

            uart_0_rxd     => uart0_rxd,
            uart_0_txd     => uart0_txd,
				
            
            set_0_in_port   => synth01_1_freq,  
            set_0_out_port  => synth01_1_freq, 
            set_1_in_port   => synth01_1_dc,  
            set_1_out_port  => synth01_1_dc,  
            set_2_in_port   => synth1_10_insp_freq, 
            set_2_out_port  => synth1_10_insp_freq, 
            set_3_in_port   => synth1_10_insp_dc, 
            set_3_out_port  => synth1_10_insp_dc,  
            set_4_in_port   => synth1_10_exp_freq, 
            set_4_out_port  => synth1_10_exp_freq, 
            set_5_in_port   => synth1_10_exp_dc,  
            set_5_out_port  => synth1_10_exp_dc, 
            set_6_in_port   => synth225_freq,  
            set_6_out_port  => synth225_freq,  
            set_7_in_port   => synth_inspup_dc, 
            set_7_out_port  => synth_inspup_dc, 
            set_8_in_port   => synth_inspdown_dc,  
            set_8_out_port  => synth_inspdown_dc,  
            set_9_in_port   => synth_expup_dc, 
            set_9_out_port  => synth_expup_dc, 
            set_10_in_port  => synth_expdown_dc, 
            set_10_out_port => synth_expdown_dc  

        );
   SDRAM_BA_1 <= sdram_ba(1);
   SDRAM_BA_0 <= sdram_ba(0);
   
   SDRAM_DQMU <= sdram_dqm(1);
   SDRAM_DQML <= sdram_dqm(0);
end architecture syn;


