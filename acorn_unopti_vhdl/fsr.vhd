LIBRARY ieee;
USE ieee.std_logic_1164.all;
--use ieee.std_logic_textio.all;


ENTITY lfsr IS
	GENERIC ( LEN : INTEGER := 2;
				 TAP : INTEGER := 0);
	PORT (	
		Reset	: IN 	STD_LOGIC;
		Zin 	: IN 	STD_LOGIC;
		Clock : IN 	STD_LOGIC;
		Z : OUT STD_LOGIC_VECTOR(LEN-1 DOWNTO 0)
		);
END lfsr;

ARCHITECTURE b_lfsr OF lfsr IS
	SIGNAL Qt: STD_LOGIC_VECTOR(LEN-1 DOWNTO 0);
	SIGNAL Sin: STD_LOGIC;
BEGIN
	PROCESS (Clock, Reset)
	BEGIN
			IF (Reset = '1') THEN
				Qt <= (others => '0');
			ELSIF(Clock'EVENT AND Clock = '1' ) THEN
				Genbits: FOR i IN 0 TO LEN-2 LOOP
					Qt(i) <= Qt(i+1);
				END LOOP;
				Qt(LEN-1) <= Sin;
			END IF;
	END PROCESS;
	Sin <= Qt(0) XOR Qt(TAP) XOR Zin;

	Z <= Qt;
END b_lfsr;

--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
----use ieee.std_logic_textio.all;
--
--ENTITY nfsr IS
--	GENERIC ( LEN : INTEGER := 2);
--	PORT (	
--		Reset	: IN 	STD_LOGIC;
--		m 	: IN 	STD_LOGIC;
--		Clock : IN 	STD_LOGIC;
--		a0, c0, b0, f14, a23, d6, f0, c4, e3, e0, b5, ca, cb, ks : IN STD_LOGIC;
--		Z : OUT STD_LOGIC_VECTOR(LEN-1 DOWNTO 0)
--		);
--END nfsr;
--
--ARCHITECTURE b_nfsr OF nfsr IS
--	SIGNAL Qt: STD_LOGIC_VECTOR(LEN-1 DOWNTO 0);
--	SIGNAL Sin: STD_LOGIC;
--
--BEGIN
--	PROCESS (Clock, Reset)
--
--	BEGIN
--			IF (Reset = '1') THEN
--				Qt <= (others => '0');
--			ELSIF(Clock'EVENT AND Clock = '1' ) THEN
--				Genbits: FOR i IN 0 TO LEN-2 LOOP
--					Qt(i) <= Qt(i+1);
--				END LOOP;
--				Qt(LEN-1) <= Sin;
--			END IF;
--
--	END PROCESS;
--	Sin <= m XOR a0 XOR c0 XOR b0 XOR '1' XOR 
--      (f14 AND a23) XOR (a23 AND d6) XOR (d6 AND f14) XOR
--      (f0 AND c4) XOR (e3 AND c4) XOR (e0 AND c4) XOR 
--      (f0 AND b5) XOR (e3 AND b5) XOR (e0 AND b5) XOR
--      (ca AND e3) XOR (cb AND ks);
--	Z <= Qt;
--END b_nfsr;