library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

 
entity regleds is
  port ( 
         clk     : in  std_logic;
         reset   : in  std_logic;
         reg_in  : in  std_logic_vector(7 downto 0);
         output  : out std_logic			     
       );
end entity regleds;

architecture behav of regleds is

   signal pulse   : std_logic := '0';
   signal counter : std_logic_vector(23 downto 0) := (others => '0');
	  
begin
   process(clk)
   begin
    if (Clk = '1' and Clk'event) then
      if reset = '1' then
          counter(23 downto 16) <= reg_in;
          counter(15 downto 0)  <= (others => '0');
          pulse <= '0';			 
      --if to_integer(unsigned(counter)) = 49999999 then
      elsif counter = x"FFFFFF" then
          counter(23 downto 16) <= reg_in;
          counter(15 downto 0)  <= (others => '0');
          pulse <= '1';			 
      else
          counter <= std_logic_vector(unsigned(counter) + 1);
      end if;
   end if;
   end process;

   output <= pulse;

end architecture behav;


