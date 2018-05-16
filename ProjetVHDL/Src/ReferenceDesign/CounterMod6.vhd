-- KO Roqyun / FAYE Mohamet Cherif / RHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP Telemetre Ultrason
-- 
-- *************************************************************************
-- Counter Mod 12. 
-- It produces a Tick every 58us to calculate the dIStance from SIGNAL ECHO. 
-- *************************************************************************

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_unsigned.all;
	
-- -------------------------------------------------------------------------
ENTITY CounterMod6 IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: in STD_LOGIC;
	Count	: out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END CounterMod6;

ARCHITECTURE behavioral of CounterMod6 IS

SIGNAL Count_Internal: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 

BEGIN
	PROCESS(Clk,Reset)
	BEGIN
		IF rising_edge(Clk) THEN
			IF Reset='1' THEN 	--Reset
				Count_Internal <= (OTHERS =>'0');
			ELSE 
				IF (Tick = '1') THEN
					IF Count_Internal = "0110" THEN -- Increment until 12. 
						Count_Internal <= (OTHERS =>'0'); -- Reset count.
					ELSE 
						Count_Internal <= Count_Internal + 1; -- Increment.
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	Count <= Count_Internal; -- Output
END behavioral; 

