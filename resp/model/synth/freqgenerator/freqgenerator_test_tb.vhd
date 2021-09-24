library ieee ;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY freqgenerator_test_tb is
    generic (
        Blah : boolean := true) ;
    -- no need for any ports or generics
End freqgenerator_test_tb ;

ARCHITECTURE arch of freqgenerator_test_tb is

component freqgenerator is
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
end component;

CONSTANT period24   : time := 42 ns ; -- 24   MHz
CONSTANT period12   : time := 78 ns ; -- 12.9 MHz 

signal Clk24   :  Std_logic := '0'; -- Initial state is zero
signal Clk12   :  Std_logic := '0'; -- Initial state is zero
signal Reset   :  Std_logic := '0';
signal LOADREG :  Std_logic := '0';
signal LOADCNT :  Std_logic := '0';
signal DATA    :  Std_logic_vector(15 downto 0) := (others => 'Z');     

signal Q       :  Std_logic_vector(15 downto 0);  
signal freq_out_rco : Std_logic;

SIGNAL done         : BOOLEAN := FALSE ;


-- The following
    SHARED VARIABLE Cycle : NATURAL := 0 ;

    PROCEDURE PrintStatus IS
        VARIABLE lout : line ;
    BEGIN
        WRITE(lout, now, right, 10, ns) ;
        WRITE(lout, string'(" Cycle = ")) ;
        WRITE(lout, Cycle, right, 3) ;
        WRITE(lout, string'(" LOADREG = ")) ;
        WRITE(lout, LOADREG) ;
        WRITE(lout, string'(" LOADCNT = ")) ;
        WRITE(lout, LOADCNT) ;
        WRITE(lout, string'(" Q = ")) ;
        WRITE(lout, Q) ;
        WRITE(lout, string'(" freq_out_rco = ")) ;
        WRITE(lout, freq_out_rco) ;
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
    U1: freqgenerator
        PORT MAP(
          CLK    => Clk12,
          CLKIN  => Clk24,
          DATA   => DATA,
          Q      => Q,
          RCO     => freq_out_rco,
          LOADREG => LOADREG,
          LOADCNT => LOADCNT,
          RN      => Reset
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

        -- Load both registers
        DATA <= "0000000000001000";
        LOADREG <= '1';
        wait for period12 * 1 ;
        LOADREG <= '0';
        LOADCNT <= '1';
        wait for period12 * 1 ;
        LOADCNT <= '0';
        DATA <= (others => 'Z');

        wait for period12 * 14 ;
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






