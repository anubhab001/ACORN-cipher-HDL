LIBRARY ieee;
USE ieee.std_logic_1164.all;
--use ieee.std_logic_textio.all;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
--use ieee.std_logic_textio.all;


ENTITY lfsr IS
	GENERIC ( LEN : INTEGER := 5;
				 TAP : INTEGER := 0);
	PORT (	
		Reset	: IN 	STD_LOGIC;
		Zin 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
		Clock : IN 	STD_LOGIC;
		Z : OUT STD_LOGIC_VECTOR(LEN-1 DOWNTO 0)
		);
END lfsr;


ARCHITECTURE b_lfsr OF lfsr IS
	SIGNAL Qt: STD_LOGIC_VECTOR(LEN-1 DOWNTO 0);
	SIGNAL Sin: STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
	PROCESS(Reset, Clock)
	BEGIN 
			IF (Reset = '1') THEN
				Qt <= (others => '0');
			ELSIF(Clock'EVENT AND Clock = '1' ) THEN
				Genbits: FOR i IN 0 TO (LEN-5) LOOP
					Qt(i) <= Qt(i+4);
				END LOOP;
				Qt(LEN-1 DOWNTO LEN-4) <= Sin;
			END IF;
	END PROCESS;
	Sin <= Qt(3 DOWNTO 0) XOR Qt(TAP+3 downto TAP) XOR Zin;
	Z <= Qt;
END b_lfsr;

------
------
------LIBRARY ieee;
------USE ieee.std_logic_1164.all;
--------use ieee.std_logic_textio.all;
------
------ENTITY nfsr IS
------	GENERIC ( LEN : INTEGER := 6);
------	PORT (	
------		Reset	: IN 	STD_LOGIC;
------		m 	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
------		Clock : IN 	STD_LOGIC;
------		a0, c0, b0, f14, a23, d6, f0, c4, e3, e0, b5, ca, cb, ks : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
------		Z : OUT STD_LOGIC_VECTOR(LEN-1 DOWNTO 0)
------		);
------END nfsr;
------
------ARCHITECTURE b_nfsr OF nfsr IS
------	SIGNAL Qt: STD_LOGIC_VECTOR(LEN-1 DOWNTO 0);
------	SIGNAL Sin: STD_LOGIC_VECTOR(3 DOWNTO 0);
------
------BEGIN
------	PROCESS (Clock, Reset)
------	BEGIN
------			IF (Reset = '1') THEN
------				Qt <= (others => '0');
------			ELSIF(Clock'EVENT AND Clock = '1' ) THEN
------				Qt(LEN-1 downto LEN-4) <= Sin;
------			END IF;
------
------	END PROCESS;
------	Sin(3 downto 0) <=  m(3 downto 0) XOR a0(3 downto 0) XOR c0(3 downto 0) XOR b0(3 downto 0) XOR "1111" XOR 
------      (f14(3 downto 0) AND a23(3 downto 0)) XOR (a23(3 downto 0) AND d6(3 downto 0)) XOR (d6(3 downto 0) AND f14(3 downto 0)) XOR
------      (f0(3 downto 0) AND c4(3 downto 0)) XOR (e3(3 downto 0) AND c4(3 downto 0)) XOR (e0(3 downto 0) AND c4(3 downto 0)) XOR 
------      (f0(3 downto 0) AND b5(3 downto 0)) XOR (e3(3 downto 0) AND b5(3 downto 0)) XOR (e0(3 downto 0) AND b5(3 downto 0)) XOR
------      (ca(3 downto 0) AND e3(3 downto 0)) XOR (cb(3 downto 0) AND ks(3 downto 0));
------	Z <= Qt;
------END b_nfsr;