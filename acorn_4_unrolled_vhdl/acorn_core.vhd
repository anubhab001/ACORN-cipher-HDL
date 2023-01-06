
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all; --- Safe to use? http://electronics.stackexchange.com/questions/4482/vhdl-converting-from-an-integer-type-to-a-std-logic-vector
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library STD;
use STD.textio.all;

entity acornv2_core is
	PORT (	
		Reset	: IN 	STD_LOGIC;
		key : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		iv : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		ad : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		pt : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Clock : IN 	STD_LOGIC;
		z_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- Key-stream/Tag
		valid : OUT STD_LOGIC);

end acornv2_core;

architecture Behavioral of acornv2_core is

	COMPONENT lfsr
	GENERIC ( LEN : INTEGER;
				 TAP : INTEGER) ;
	PORT (	
		Reset	: IN 	STD_LOGIC ;
		Zin 	: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0) ;
		Clock : IN 	STD_LOGIC ;
		Z		: OUT STD_LOGIC_VECTOR (LEN-1 DOWNTO 0)) ;
	END COMPONENT;
    

   -- Signals
   signal ks, m: std_logic_vector (3 downto 0) := (others => '0');
	
	----------------------------
	-- MAKE THESE OF 1 BIT, AND CONCATENATE?
	----------------------------
   signal ca, cb: std_logic_vector (3 downto 0) := (others => '0');
	
	signal Astate : std_logic_vector (60 downto 0) := (others => '0');  
	signal Bstate : std_logic_vector (45 downto 0) := (others => '0');  
	signal Cstate : std_logic_vector (46 downto 0) := (others => '0');  
	signal Dstate : std_logic_vector (38 downto 0) := (others => '0');  
	signal Estate : std_logic_vector (36 downto 0) := (others => '0');  
	signal Fstate : std_logic_vector (58 downto 0) := (others => '0');  
	signal Gstate : std_logic_vector ( 3 downto 0) := (others => '0');  
	signal round_counter : std_logic_vector (11 downto 0) := (others => '0');
	signal stored_key : std_logic_vector (127 downto 0) := (others => '0');
	
	
BEGIN
 
   A: lfsr
	GENERIC MAP (LEN => 61,
					TAP => 23)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Bstate(3 downto 0),
          Clock => Clock,
			 Z => Astate
   );

	B: lfsr
	GENERIC MAP (LEN => 46,
					TAP => 5)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Cstate(3 downto 0),
          Clock => Clock,
			 Z => Bstate
   );
	
	C: lfsr
	GENERIC MAP (LEN => 47,
					TAP => 4)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Dstate(3 downto 0),
          Clock => Clock,
			 Z => Cstate
   );	
	
	D: lfsr
	GENERIC MAP (LEN => 39,
					TAP => 6)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Estate(3 downto 0),
          Clock => Clock,
			 Z => Dstate
   );	
	
	E: lfsr
	GENERIC MAP (LEN => 37,
					TAP => 3)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Fstate(3 downto 0),
          Clock => Clock,
			 Z => Estate
   );	

	F: lfsr
	GENERIC MAP (LEN => 59,
					TAP => 5)
	PORT MAP (
          Reset => Reset,
          Zin(3 downto 0) => Gstate(3 downto 0),
          Clock => Clock,
			 Z => Fstate);	
	
----	G: nfsr
----	GENERIC MAP (LEN => 4)
----	PORT MAP (
----			a0(3 downto 0) => Astate(3 downto 0), c0(3 downto 0) => Cstate(3 downto 0), b0(3 downto 0) => Bstate(3 downto 0),
----			f14(3 downto 0) => Fstate(17 downto 14), a23(3 downto 0) => Astate(26 downto 23), d6(3 downto 0) => Dstate(9 downto 6),
----			f0(3 downto 0) => Fstate(3 downto 0), c4(3 downto 0) => Cstate(7 downto 4), e3(3 downto 0) => Estate(6 downto 3),
----			e0(3 downto 0) => Estate(3 downto 0), b5(3 downto 0) => Bstate(8 downto 5), 
----			ca(3 downto 0) => ca, cb(3 downto 0) => cb, ks(3 downto 0) => ks,
----         Reset => Reset,
----         m(3 downto 0) => m,
----         Clock => Clock,
----			Z => Gstate
----   );	

	ks <= Astate(15 downto 12) XOR  Dstate(3 downto 0) XOR Cstate(7 downto 4) XOR Cstate(3 downto 0) XOR 
		(Fstate(8 downto 5) AND Bstate(3 downto 0)) XOR (Fstate(8 downto 5) AND Astate(26 downto 23)) XOR (Fstate(8 downto 5) AND Astate(3 downto 0)) XOR
		(Bstate(3 downto 0) AND Estate(3 downto 0)) XOR (Bstate(3 downto 0) AND Dstate(9 downto 6)) XOR  (Bstate(3 downto 0) AND Dstate(3 downto 0)) XOR 
		(Astate(26 downto 23) AND Estate(3 downto 0)) XOR (Astate(26 downto 23) AND Dstate(9 downto 6)) XOR (Astate(26 downto 23) AND Dstate(3 downto 0)) XOR 
		(Astate(3 downto 0) AND Estate(3 downto 0)) XOR (Astate(3 downto 0) AND Dstate(9 downto 6)) XOR (Astate(3 downto 0) AND Dstate(3 downto 0)) XOR
		(Fstate(8 downto 5) AND Estate(3 downto 0)) XOR (Fstate(8 downto 5) AND Dstate(9 downto 6)) XOR (Fstate(8 downto 5) AND Dstate(3 downto 0));

	z_out <= ks;

------- NOT WORKING (NOT IN SYNCH. WITH CLOCK)
----	Gstate <= (m(3 downto 0) XOR Astate(3 downto 0) XOR Cstate(3 downto 0) XOR Bstate(3 downto 0) XOR "1111" XOR 
----      (Fstate(17 downto 14) AND Astate(26 downto 23)) XOR (Astate(26 downto 23) AND Dstate(9 downto 6)) XOR (Dstate(9 downto 6) AND Fstate(17 downto 14)) XOR
----      (Fstate(3 downto 0) AND Cstate(7 downto 4)) XOR (Estate(6 downto 3) AND Cstate(7 downto 4)) XOR (Estate(3 downto 0) AND Cstate(7 downto 4)) XOR 
----      (Fstate(3 downto 0) AND Bstate(8 downto 5)) XOR (Estate(6 downto 3) AND Bstate(8 downto 5)) XOR (Estate(3 downto 0) AND Bstate(8 downto 5)) XOR
----      (ca(3 downto 0) AND Estate(6 downto 3)) XOR (cb(3 downto 0) AND ks(3 downto 0))) and ((not reset) & (not reset) & (not reset) & (not reset));
----	
	
	UPDATE_G : process (Clock,Reset,Astate,Bstate,Cstate,Dstate,Estate,Fstate,m,ca,cb,ks)
		begin
		if (Reset = '1') then
			Gstate <= "0000";
		elsif (Clock'EVENT and Clock = '1') then
			Gstate <= m(3 downto 0) XOR Astate(3 downto 0) XOR Cstate(3 downto 0) XOR Bstate(3 downto 0) XOR "1111" XOR 
      (Fstate(17 downto 14) AND Astate(26 downto 23)) XOR (Astate(26 downto 23) AND Dstate(9 downto 6)) XOR (Dstate(9 downto 6) AND Fstate(17 downto 14)) XOR
      (Fstate(3 downto 0) AND Cstate(7 downto 4)) XOR (Estate(6 downto 3) AND Cstate(7 downto 4)) XOR (Estate(3 downto 0) AND Cstate(7 downto 4)) XOR 
      (Fstate(3 downto 0) AND Bstate(8 downto 5)) XOR (Estate(6 downto 3) AND Bstate(8 downto 5)) XOR (Estate(3 downto 0) AND Bstate(8 downto 5)) XOR
      (ca(3 downto 0) AND Estate(6 downto 3)) XOR (cb(3 downto 0) AND ks(3 downto 0));
	
		end if;
	end process;
	
	UPDATE_ROUND_COUNTER : process(Clock, Reset)
		begin
		if (Reset = '1') then
			round_counter <= "000000000000";
		elsif (Clock'EVENT and Clock = '1') then
				round_counter <= round_counter + "100";
		end if;
	end process UPDATE_ROUND_COUNTER;
	
	STORE_KEY : process (round_counter, key)
	variable x : integer range 11 downto 0;
		begin
		x := to_integer(unsigned(round_counter));
		if(round_counter <= 124) then
			stored_key(x+3 downto x) <= key;
		end if;
	end process STORE_KEY;
	
	UPDATE_M : process (round_counter, key, iv, ad, pt, stored_key)
	
	variable y : integer range 11 downto 0;
		begin
		y := to_integer(unsigned(round_counter and ("000001111111")));
		
		if (round_counter <= 124) then														-- Load Key
			m <= key;
		elsif (round_counter <= 252) then													-- Load IV
			m <= iv;
		elsif (round_counter = 256) then											
			m <= "0001" XOR stored_key(3 downto 0);
		elsif (round_counter <= 1788) then 													-- 256 + 1535
			m <= stored_key(y+3 downto y);
	
		elsif (round_counter <= 1916) then													-- Load AD 256 + 1535 + 128
			m <= ad;
		elsif (round_counter = 1920) then 
			m <= "0001";
		elsif (round_counter <= 2172) then													-- 256 + 1535 + 128 + 1 + 255
																										-- round_counter <= 2175 and round_counter 
			m <= "0000";
			
		elsif (round_counter <= 2300) then													-- Generate ciphertext 256 + 1535 + 128 + 1 + 255 + 128
			m <= pt;
		elsif (round_counter = 2304) then
			m <= "0001";

		elsif (round_counter <= 3324) then 													-- 256 + 1535 + 128 + 1 + 255 + 128 + 1 + 255 + 768
			m <= "0000";
		
--		else
--			m <= "UUUU";
		end if;
	end process UPDATE_M;

	UPDATE_CA : process (round_counter)
		begin

		if (round_counter <= 2044) then								-- 1791 + 128 + 128
			ca <= "1111";
		elsif (round_counter <= 2172) then 								-- 1791 + 128 + 256
			ca <= "0000";
			
		elsif (round_counter <= 2428) then 								-- 1791 + 128 + 128 + 384
			ca <= "1111";
		elsif (round_counter <= 2556) then 								-- 1791 + 128 + 128 + 512
			ca <= "0000";
			
		elsif (round_counter <= 3324) then 								-- 1791 + 128 + 128 + 1280
			ca <= "1111";
			
--		else
--			ca <= "UUUU";
		end if;
	end process UPDATE_CA;
	
	UPDATE_CB : process (round_counter)
		begin

		if (round_counter <= 2172) then								-- 1791 + 128 + 256
			cb <= "1111";
			-- cb <= 
		elsif (round_counter <= 2556) then								-- 1791 + 128 + 128 + 512
			cb <= "0000";
			
		elsif (round_counter <= 3324) then								-- 1791 + 128 + 128 + 1280
			cb <= "1111";
		
--		else
--			cb <= "UUUU";
		end if;
	end process UPDATE_CB;
	
	UPDATE_VALID : process (round_counter)
		begin	
		if (round_counter <= 2172) then									-- 1791 + 128 + 256
			valid <= '0';
		elsif (round_counter <= 2300) then								-- 1791 + 128 + 256 + 128
			valid <= '1';
		elsif (round_counter < 3200) then								-- 1792 + 128 + 128 + 512 + (768 - 128)
			valid <= '0';
		elsif (round_counter <= 3324) then								-- 1792 + 128 + 128 + 512 + (767)
			valid <= '1';
		else
			valid <= '0';
		end if;
	end process UPDATE_VALID;
	
end Behavioral;