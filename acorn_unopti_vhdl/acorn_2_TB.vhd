-- ACORN v2 test bench for unoptimized version
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all; --- Safe to use? http://electronics.stackexchange.com/questions/4482/vhdl-converting-from-an-integer-type-to-a-std-logic-vector
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;

library STD;
use STD.textio.all;

ENTITY acorn_v2_TB IS
END acorn_v2_TB;

ARCHITECTURE behavior OF acorn_v2_TB IS 
  
  
COMPONENT acornv2_core
	PORT (	
		Reset	: IN 	STD_LOGIC;
		key : IN STD_LOGIC;
		iv : IN STD_LOGIC;
		ad : IN STD_LOGIC;
		pt : IN STD_LOGIC;
		Clock : IN 	STD_LOGIC;
		z_out	: OUT STD_LOGIC;
		valid : OUT STD_LOGIC);

end COMPONENT;  
	
	constant Clock_period : time := 2 ns;
	signal key : std_logic := '0';
	signal iv : std_logic := '0';
	signal ad : std_logic := '0';
	signal pt : std_logic := '0';
	
	signal key_128 : std_logic_vector (127 downto 0) := 	
	('0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '0', '1', '1', '1', '0', '0', '0', '0', '0', '1', '1', '0', '1', '0', '0', '0', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0', '1', '1', '0', '0', '0', '1', '1', '0', '1', '0', '0', '0', '0', '0', '1', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '1', '0', '1', '1', '1', '0', '0', '0', '0', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0', '1', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '1', '0', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0', '1', '1', '0', '1', '0', '0', '0', '1', '0', '0', '0', '0', '0', '1', '1', '1');
	--(others => '0');
	
	signal iv_128 : std_logic_vector (127 downto 0) := 	
	('0', '0', '1', '0', '1', '1', '0', '1', '0', '0', '1', '0', '1', '0', '1', '0', '0', '0', '1', '0', '0', '1', '1', '1', '0', '0', '1', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '0', '1', '1', '0', '1', '1', '0', '0', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0', '0', '1', '1', '0', '0', '0', '1', '0', '0', '1', '0', '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0', '0', '1', '0', '0', '0', '0', '0', '1', '1', '0', '1', '1', '1', '1', '0', '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1');
	--(others => '0');
	
	signal ad_128 : std_logic_vector (127 downto 0) := 	
	('0', '0', '0', '0', '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '1', '0', '1', '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '0', '1', '0');
	--(others => '0');
	
	signal pt_128 : std_logic_vector (127 downto 0) := 	
	('0', '0', '0', '0', '0', '0', '0', '1', '1', '1', '1', '0', '0', '1', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '1', '1', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '1', '1', '1', '1', '0', '0', '0', '1', '1', '1', '0', '0', '0', '0', '0', '1');
	--(others => '0');

	signal counter : std_logic_vector (6 downto 0) := (others => '0');
	
	signal Reset : std_logic := '0';
	signal Clock : std_logic := '0';
 
	signal z, valid : std_logic := '0';
 
 begin
 
	key <= key_128(to_integer(unsigned(counter)));
	iv <= iv_128(to_integer(unsigned(counter)));
	ad <= ad_128(to_integer(unsigned(counter)));
	pt <= pt_128(to_integer(unsigned(counter)));
	
	-- Update counter
	UPDATE_COUNTER : process(Clock, Reset)
		begin
		if (Reset = '1') then
			counter <= (others => '0');
		elsif (Clock'EVENT and Clock = '1') then
				counter <= counter + '1';
		end if;
	end process UPDATE_COUNTER;
	
   Clock_process :process
   begin
		Clock <= '0';
		wait for Clock_period/2;
		Clock <= '1';
		wait for Clock_period/2;
   end process;
 
	
	WRITE_TO_FILE: process
      file outfile     : text is out "z_values_unopti.txt";
      variable outline : line;
    begin
        if (valid = '1') then
          write(outline, z);
          writeline(outfile, outline);
        end if;
        wait for Clock_period;
    end process;


   MAIN: process
   begin		
 
		Reset <= '1';
		
      wait for 4*Clock_period;	
		Reset <= '0';
      wait for 4*Clock_period;	
		
      wait;
   end process;

	TEST : ACORNv2_CORE
		PORT MAP(	
			Reset	=> Reset,
			key => key,
			iv => iv,
			ad => ad,
			pt => pt,
			Clock => Clock,
			z_out => z,
			valid => valid
		);

END;