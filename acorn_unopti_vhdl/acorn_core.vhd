
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all; --- Safe to use? http://electronics.stackexchange.com/questions/4482/vhdl-converting-from-an-integer-type-to-a-std-logic-vector
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;

--library STD;
--use STD.textio.all;

entity acornv2_core is
	PORT (	
		Reset	: IN 	STD_LOGIC;
		key : IN STD_LOGIC;
		iv : IN STD_LOGIC;
		ad : IN STD_LOGIC;
		pt : IN STD_LOGIC;
		Clock : IN 	STD_LOGIC;
		z_out : OUT STD_LOGIC; -- Key-stream/Tag
		valid : OUT STD_LOGIC);

end acornv2_core;

architecture Behavioral of acornv2_core is

	COMPONENT lfsr
	GENERIC ( LEN : INTEGER;
				 TAP : INTEGER) ;
	PORT (	
		Reset	: IN 	STD_LOGIC ;
		Zin 	: IN 	STD_LOGIC ;
		Clock : IN 	STD_LOGIC ;
		Z		: OUT STD_LOGIC_VECTOR (LEN-1 DOWNTO 0)) ;
	END COMPONENT;
	
--	COMPONENT nfsr
--	GENERIC ( LEN : INTEGER) ;
--	PORT (	
--		Reset	: IN 	STD_LOGIC;
--		m : IN STD_LOGIC;
--		Clock : IN 	STD_LOGIC;
--		a0, c0, b0, f14, a23, d6, f0, c4, e3, e0, b5, ca, cb, ks : IN STD_LOGIC;
--		Z :  OUT STD_LOGIC_VECTOR (LEN-1 DOWNTO 0)) ;
--	END COMPONENT;
	 
    

   -- Signals
   signal ca, cb, ks, m : std_logic := '0';
	signal Astate : std_logic_vector (60 downto 0);
	signal Bstate : std_logic_vector (45 downto 0);
	signal Cstate : std_logic_vector (46 downto 0);
	signal Dstate : std_logic_vector (38 downto 0);
	signal Estate : std_logic_vector (36 downto 0);
	signal Fstate : std_logic_vector (58 downto 0);  
	signal Gstate : std_logic_vector ( 3 downto 0);  
	signal round_counter : std_logic_vector (11 downto 0) := (others => '0');
	--	constant adlen, ptlen, taglen : integer := 128;
	signal stored_key : std_logic_vector (127 downto 0) := (others => '0');
BEGIN
 
   A: lfsr
	GENERIC MAP (LEN => 61,
					TAP => 23)
	PORT MAP (
          Reset => Reset,
          Zin => Bstate(0),
          Clock => Clock,
			 Z => Astate
   );

	B: lfsr
	GENERIC MAP (LEN => 46,
					TAP => 5)
	PORT MAP (
          Reset => Reset,
          Zin => Cstate(0),
          Clock => Clock,
			 Z => Bstate
   );
	
	C: lfsr
	GENERIC MAP (LEN => 47,
					TAP => 4)
	PORT MAP (
          Reset => Reset,
          Zin => Dstate(0),
          Clock => Clock,
			 Z => Cstate
   );	
	
	D: lfsr
	GENERIC MAP (LEN => 39,
					TAP => 6)
	PORT MAP (
          Reset => Reset,
          Zin => Estate(0),
          Clock => Clock,
			 Z => Dstate
   );	
	
	E: lfsr
	GENERIC MAP (LEN => 37,
					TAP => 3)
	PORT MAP (
          Reset => Reset,
          Zin => Fstate(0),
          Clock => Clock,
			 Z => Estate
   );	

	F: lfsr
	GENERIC MAP (LEN => 59,
					TAP => 5)
	PORT MAP (
          Reset => Reset,
          Zin => Gstate(0),
          Clock => Clock,
			 Z => Fstate);	
	
--	G: nfsr
--	GENERIC MAP (LEN => 4)
--	PORT MAP (
--			 a0 => Astate(0), c0 => Cstate(0), b0 => Bstate(0), f14 => Fstate(14), a23 => Astate(23), d6 => Dstate(6), f0 => Fstate(0), c4 => Cstate(4), e3 => Estate(3), e0 => Estate(0), b5 => Bstate(5), 
--			 ca => ca, cb => cb, ks => ks,
--          Reset => Reset,
--          m => m,
--          Clock => Clock,
--			 Z => Gstate
--   );	

	ks <= Astate(12) XOR  Dstate(0) XOR Cstate(4) XOR Cstate(0) XOR 
	(Fstate(5) AND Bstate(0)) XOR (Fstate(5) AND Astate(23)) XOR (Fstate(5) AND Astate(0)) XOR
	(Bstate(0) AND Estate(0)) XOR (Bstate(0) AND Dstate(6)) XOR  (Bstate(0) AND Dstate(0)) XOR 
	(Astate(23) AND Estate(0)) XOR (Astate(23) AND Dstate(6)) XOR (Astate(23) AND Dstate(0)) XOR 
	(Astate(0) AND Estate(0)) XOR (Astate(0) AND Dstate(6)) XOR (Astate(0) AND Dstate(0)) XOR
	(Fstate(5) AND Estate(0)) XOR (Fstate(5) AND Dstate(6)) XOR (Fstate(5) AND Dstate(0));

	z_out <= ks;

	UPDATE_G : process (Clock,Reset,Astate,Bstate,Cstate,Dstate,Estate,Fstate,m,ca,cb,ks)
		begin
		if (Reset = '1') then
			Gstate <= "0000";
		elsif (Clock'EVENT and Clock = '1') then
			Gstate(3) <= m XOR Astate(0) XOR Cstate(0) XOR Bstate(0) XOR '1' XOR 
      (Fstate(14) AND Astate(23)) XOR (Astate(23) AND Dstate(6)) XOR (Dstate(6) AND Fstate(14)) XOR
      (Fstate(0) AND Cstate(4)) XOR (Estate(3) AND Cstate(4)) XOR (Estate(0) AND Cstate(4)) XOR 
      (Fstate(0) AND Bstate(5)) XOR (Estate(3) AND Bstate(5)) XOR (Estate(0) AND Bstate(5)) XOR
      (ca AND Estate(3)) XOR (cb AND ks);

			Gstate(0) <= Gstate(1); Gstate(1) <= Gstate(2); Gstate(2) <= Gstate(3);
		end if;
	end process;


	
	UPDATE_ROUND_COUNTER : process(Clock, Reset)
		begin
		if (Reset = '1') then
			round_counter <= (others => '0');
		elsif (Clock'EVENT and Clock = '1') then
				round_counter <= round_counter + '1';
		end if;
	end process UPDATE_ROUND_COUNTER;
	
	STORE_KEY : process (round_counter, key)
		begin
		if (round_counter <= 127) then
			stored_key(to_integer(unsigned(round_counter))) <= key;					----- DOES THAT INCREASE HARDWARE??
		end if;
	end process STORE_KEY;
	
	UPDATE_M : process (round_counter, key, iv, ad, pt, stored_key)
		begin
		if (round_counter <= 127) then														-- Load Key
			m <= key;
		elsif (round_counter <= 255) then													-- Load IV
			m <= iv;
		elsif (round_counter = 256) then											
			m <= '1' XOR stored_key(0);
		elsif (round_counter <= 1791) then			-- 256 + 1535
			m <= stored_key(to_integer(unsigned(round_counter and ("000001111111"))));
		elsif (round_counter <= 1919) then						-- 256 + 1535 + 128  -- Load AD
			m <= ad;
		elsif (round_counter = 1920) then 						-- 256 + 1535 + 128 + 1
			m <= '1';
		elsif (round_counter <= 2175) then						-- 256 + 1535 + 128 + 1 + 255
			m <= '0';
		elsif (round_counter <= 2303) then						-- Generate ciphertext -- 256 + 1535 + 128 + 1 + 255 + 128
			m <= pt;
		elsif (round_counter = 2304) then						-- 256 + 1535 + 128 + 1 + 255 + 128 + 1
			m <= '1';
--		elsif (round_counter <= 2559) then						-- 256 + 1535 + 128 + 1 + 255 + 128 + 1 + 255
--			m <= '0';
		elsif (round_counter <= 3327) then						-- 256 + 1535 + 128 + 1 + 255 + 128 + 1 + 255 + 768
			m <= '0';
--		else
--			m <= 'U';
		end if;
	end process UPDATE_M;

	UPDATE_CA : process (round_counter)
		begin
--		if (round_counter <= 1791) then
--			ca <= '1';
--		
--		els
		if (round_counter <= 2047) then						-- 1791 + 128 + 128
			ca <= '1';
		elsif (round_counter <= 2175) then					-- 1791 + 128 + 256
			ca <= '0';
			
		elsif (round_counter <= 2431) then					-- 1791 + 128 + 128 + 384
			ca <= '1';
		elsif (round_counter <= 2559) then					-- 1791 + 128 + 128 + 512
			ca <= '0';
			
		elsif (round_counter <= 3327) then					-- 1791 + 128 + 128 + 1280
			ca <= '1';
			
--		else
--			ca <= 'U';
		end if;
	end process UPDATE_CA;
	
	UPDATE_CB : process (round_counter)
		begin
--		if (round_counter <= 1791) then
--			cb <= '1';
--			
			
--		els
		if (round_counter <= 2175) then									-- 1791 + 128 + 256
			cb <= '1';
			
		elsif (round_counter <= 2559) then								-- 1791 + 128 + 128 + 512
			cb <= '0';
			
		elsif (round_counter <= 3327) then								-- 1791 + 128 + 128 + 1280
			cb <= '1';
		
--		else
--			cb <= 'U';
		end if;
	end process UPDATE_CB;
	
	UPDATE_VALID : process (round_counter)
		begin	
		if (round_counter <= 2175) then									-- 1791 + 128 + 256
			valid <= '0';
		elsif (round_counter <= 2303) then								-- 1791 + 128 + 256 + 128
			valid <= '1';
		elsif (round_counter < 3200) then								-- 1792 + 128 + 128 + 512 + (768 - 128)
			valid <= '0';
		elsif (round_counter <= 3327) then								-- 1792 + 128 + 128 + 512 + (767)
			valid <= '1';
		else
			valid <= '0';
		end if;
	end process UPDATE_VALID;
	
end Behavioral;