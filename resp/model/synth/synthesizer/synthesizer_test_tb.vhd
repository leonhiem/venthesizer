library ieee ;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY synthesizer_test_tb is
    generic (
        Blah : boolean := true) ;
    -- no need for any ports or generics
End synthesizer_test_tb ;

ARCHITECTURE arch of synthesizer_test_tb is

component synthesizer is
  port (
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
end component;

CONSTANT period24   : time := 42 ns ; -- 24   MHz
CONSTANT period12   : time := 78 ns ; -- 12.9 MHz 

signal Clk24   :  Std_logic := '0'; -- Initial state is zero
signal Clk12   :  Std_logic := '0'; -- Initial state is zero
signal Reset   :  Std_logic := '0';

signal ADDR    :  Std_logic_vector(1 downto 0) := (others => '0');     
signal DATA    :  Std_logic_vector(15 downto 0) := (others => 'Z');     
signal WR      :  Std_logic := '0';

signal QAchk   :  Std_logic_vector(15 downto 0);
signal QBchk   :  Std_logic_vector(15 downto 0);
signal SYNTH_OUT : Std_logic;

SIGNAL done         : BOOLEAN := FALSE ;


-- The following
    SHARED VARIABLE Cycle : NATURAL := 0 ;

    PROCEDURE PrintStatus IS
        VARIABLE lout : line ;
    BEGIN
        WRITE(lout, now, right, 10, ns) ;
        WRITE(lout, string'(" Cycle = ")) ;
        WRITE(lout, Cycle, right, 3) ;
        WRITE(lout, string'(" ADDR = ")) ;
        WRITE(lout, ADDR) ;
        WRITE(lout, string'(" WR = ")) ;
        WRITE(lout, WR) ;
        WRITE(lout, string'(" DATA = ")) ;
        WRITE(lout, DATA) ;
        WRITE(lout, string'(" SYNTH_OUT = ")) ;
        WRITE(lout, SYNTH_OUT) ;
        WRITELINE(OUTPUT, lout) ;
    END PrintStatus ;


    PROCEDURE CheckStatus(
        CONSTANT NSoal, ewval : std_logic_vector ;
        SIGNAL done : OUT BOOLEAN) IS
    BEGIN
            PrintStatus ;       -- Print the curent status
    END CheckStatus ;


begin

-- This is the unit under test
    U1: synthesizer
        PORT MAP(
          CLOCK  => Clk12,
          CLKIN  => Clk24,
          RESET  => Reset,
          DATA   => DATA,
          ADDR   => ADDR,
          WR     => WR,
          SYNTH_OUT => SYNTH_OUT,
          QAchk  => QAchk,
          QBchk  => QBchk
) ;


-- The following is a process which generates a clock
-- while the unit is still under test
    ClkProcess: PROCESS(done, Clk12)
    BEGIN
        IF (NOT done) THEN
            IF (Clk12 = '1') THEN
                Cycle := Cycle + 1 ;
            END IF ;
            Clk12 <= NOT Clk12 after period12 / 2 ;
        END IF ;
    END PROCESS ;

-- The following is a process which generates a clock
-- while the unit is still under test
    ClkProcess2: PROCESS(done, Clk24)
    BEGIN
        IF (NOT done) THEN
          Clk24 <= NOT Clk24 after period24 / 2 ;
        END IF ;
    END PROCESS ;


    TestBench: PROCESS
    BEGIN
        wait until (Clk12 = '1') ;
        -- make sure that the controller initialized properly
        CheckStatus("00", "00", done) ;

        wait for period12 * 1 ;
        Reset <= '1';

        -- Load both freq registers
        ADDR <= "00";
        DATA <= "0000000000001000";
        WR   <= '1';
        wait for period12 * 2 ;
        WR   <= '0';

        wait for period12 * 1 ;

        ADDR <= "01";
        DATA <= "0000000000001000";
        WR   <= '1';
        wait for period12 * 2 ;
        WR   <= '0';

        wait for period12 * 1 ;

        -- Load dc registers
        ADDR <= "10";
        DATA <= "0000000000000011";
        WR   <= '1';
        wait for period12 * 2 ;
        WR   <= '0';

        wait for period12 * 1 ;

        -- Load dc registers
        ADDR <= "11";
        DATA <= "0000000000000011";
        WR   <= '1';
        wait for period12 * 2 ;
        WR   <= '0';

        DATA <= (others => 'Z');

        wait for period12 * 20 ;
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
        WAIT until (Clk12 = '0') ;   -- We sample outputs on the falling edge
        PrintStatus ;
    END PROCESS ;


end arch; 







