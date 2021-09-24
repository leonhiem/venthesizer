library ieee ;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY respif_tb is
    generic (
        Blah : boolean := true) ;
    -- no need for any ports or generics
End respif_tb ;

ARCHITECTURE arch of respif_tb is

component respif is
  port (
     Clk     : in Std_logic;
     Reset   : in Std_logic;
     DSPADDR    : in Std_logic_vector(4 downto 0);
     DSPDATA    : inout Std_logic_vector(15 downto 0); 
     DATA_   : out std_logic_vector(15 downto 0);    
     CS      : in Std_logic;
     WR      : in Std_logic;
     RD      : in Std_logic;
     DSPWAIT : out std_logic;
     MEMADDR_ : out Std_logic_vector(4 downto 0);
     MEMRD_   : out std_logic;
     MEMWR_   : out std_logic;
     state_ : out std_logic_vector(3 downto 0);
     synthset : out std_logic_vector(4 downto 0);
     reinit         : in Std_logic ;
     resp_phase     : out std_logic_vector(1 downto 0);
     synth01_1out   : out Std_logic;
     synth1_10out   : out Std_logic;
     synth225out    : out Std_logic;
     rco01_1        : out std_logic;
     rco1_10        : out std_logic;
     rco225         : out std_logic
);
end component;

CONSTANT period     : time := 1 ns ;
CONSTANT period24   : time := 3 ns; --42 ns ; -- 24   MHz

signal simClk  :  Std_logic := '0'; -- Initial state is zero
signal Clk     :  Std_logic := '0'; -- Initial state is zero
signal Reset   :  Std_logic := '0';
signal DSPADDR    :  Std_logic_vector(4 downto 0) := "00000";
signal DSPDATA    :  Std_logic_vector(15 downto 0) := (others => 'Z');     
signal DATA_   :  std_logic_vector(15 downto 0);
signal CS      :  Std_logic := '1';
signal WR      :  Std_logic := '1';
signal RD      :  Std_logic := '1';
signal DSPWAIT :  std_logic;
signal MEMADDR_     : Std_logic_vector(4 downto 0);
signal MEMRD_       : std_logic;
signal MEMWR_       : std_logic;
signal state_       : std_logic_vector(3 downto 0);
signal synthset       : std_logic_vector(4 downto 0);

signal reinit       : std_logic := '0';

signal resp_phase     : std_logic_vector(1 downto 0);

signal synth01_1out : Std_logic;
signal synth1_10out : Std_logic;
signal synth225out  : Std_logic;

signal rco01_1        : std_logic;
signal rco1_10        : std_logic;
signal rco225         : std_logic;


SIGNAL done         : BOOLEAN := FALSE ;



-- The following
    SHARED VARIABLE Cycle : NATURAL := 0 ;

    PROCEDURE PrintStatus IS
        VARIABLE lout : line ;
    BEGIN
        WRITE(lout, now, right, 10, ns) ;
        WRITE(lout, string'(" Cycle = ")) ;
        WRITE(lout, Cycle, right, 3) ;
        WRITE(lout, string'(" CS = ")) ;
        WRITE(lout, CS) ;
        WRITE(lout, string'(" WR = ")) ;
        WRITE(lout, WR) ;
        WRITE(lout, string'(" RD = ")) ;
        WRITE(lout, RD) ;
        WRITELINE(OUTPUT, lout) ;
    END PrintStatus ;


    PROCEDURE CheckStatus(
        CONSTANT NSoal, ewval : std_logic_vector ;
        SIGNAL done : OUT BOOLEAN) IS
    BEGIN
     --   IF ((RD /= NSoal) OR (WR /= ewval)) THEN
            PrintStatus ;       -- Print the curent status
     --       ASSERT(FALSE) REPORT "Test Failed" SEVERITY FAILURE ;
     --       done <= TRUE ;
     --       WAIT ;
     --   END IF ;
    END CheckStatus ;


begin

-- This is the unit under test
    U1: respif
        PORT MAP(
     Clk     => Clk,
     Reset   => Reset,
     DSPADDR    => DSPADDR,
     DSPDATA    => DSPDATA,
     DATA_   => DATA_,
     CS      => CS,
     WR      => WR,
     RD      => RD,
     DSPWAIT => DSPWAIT,
     MEMADDR_ => MEMADDR_,
     MEMRD_   => MEMRD_,
     MEMWR_   => MEMWR_,
     state_ => state_,
     synthset => synthset,
     reinit    => reinit,
     resp_phase   => resp_phase,
     synth01_1out => synth01_1out,
     synth1_10out => synth1_10out,
     synth225out  => synth225out,
     rco01_1        => rco01_1,
     rco1_10        => rco1_10,
     rco225         => rco225 
) ;


-- The following is a process which generates a clock
-- while the unit is still under test
    ClkProcess: PROCESS(done, simclk)
    BEGIN
        IF (NOT done) THEN
            IF (simclk = '1') THEN
                Cycle := Cycle + 1 ;
            END IF ;
            simclk <= NOT simclk after period / 2 ;
        END IF ;
    END PROCESS ;

-- The following is a process which generates a clock
-- while the unit is still under test
    ClkProcess3: PROCESS(done, Clk)
    BEGIN
        IF (NOT done) THEN
          Clk <= NOT Clk after period24 / 2 ;
        END IF ;
    END PROCESS ;


    TestBench: PROCESS
    BEGIN
        wait until (simclk = '1') ;
        -- make sure that the controller initialized properly
        CheckStatus("00", "00", done) ;

        wait for period * 1 ;
        Reset <= '1';
        
        -- write to address 
        DSPADDR <= "00000"; -- 01_1 freq
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000011";        
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00001"; -- 01_1 dc
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000010";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00010"; -- 1_10 freq (insp, exp) 
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000100";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00100"; -- 1_10 dc (insp)
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000011";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00101"; -- 1_10 dc (exp)
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000010";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00110"; -- 225 freq 
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000001001000";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "00111"; -- 225 dc (inspup) 
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000001000100";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "01000"; -- 225 dc (inspdown)
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000001100";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "01001"; -- 225 dc (expup)
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000111100";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        -- Write to address 
        DSPADDR <= "01010"; -- 225 dc (expdown)
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000010";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';


        DSPDATA <= (others => 'Z');
        -- Finished writing to memory
       
        reinit <= '1';

        wait for period * 8 ;

        reinit <= '0';

        wait for period * 256 ;

        -- Write to address 
        DSPADDR <= "00010"; 
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000101";
        wait for period * 6 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';

        DSPDATA <= (others => 'Z');
        
        wait for period * 1024 ;

        -- Read from address 
        DSPADDR <= "00110"; 
        CS <= '0';
        wait for period * 1 ;
        RD <= '0';        
        wait for period * 12 ;
        RD <= '1';
        wait for period * 1 ;
        CS <= '1';
        
        wait for period * 1024 ;

        -- Read from address 
        DSPADDR <= "01000"; 
        CS <= '0';
        wait for period * 1 ;
        RD <= '0';        
        wait for period * 12 ;
        RD <= '1';
        wait for period * 1 ;
        CS <= '1';
        
        wait for period * 102 ;


        -- Read from address 
        DSPADDR <= "01001"; 
        CS <= '0';
        wait for period * 1 ;
        RD <= '0';        
        wait for period * 12 ;
        RD <= '1';
        wait for period * 1 ;
        CS <= '1';
        
        wait for period * 979 ;

                
        -- Write to address 
        DSPADDR <= "00010"; 
        CS <= '0';
        wait for period * 1 ;
        WR <= '0';
        wait for period * 1 ;
        DSPDATA <= "0000000000000100";
        wait for period * 11 ;
        WR <= '1';
        wait for period * 1 ;
        CS <= '1';
        DSPDATA <= (others => 'Z');

        wait for period * 52 ;

        -- Read from address 
        DSPADDR <= "00010"; 
        CS <= '0';
        wait for period * 1 ;
        RD <= '0';        
        wait for period * 11 ;
        RD <= '1';
        wait for period * 1 ;
        CS <= '1';
        
        wait for period * 4096 ;


        CheckStatus("00", "00", done) ;

        -- We are done testing. The following
        -- two statements will end the simulation
        done <= TRUE ;          -- Force the clock process to shutdown
        WAIT ;                  -- This waits forever
    END PROCESS ;


-- The following process monitors the outputs and prints them
-- to standard output (screen)
    Monitor: PROCESS
    BEGIN
        WAIT until (simclk = '0') ;   -- We sample outputs on the falling edge
        PrintStatus ;
    END PROCESS ;


end arch; 













