-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Counter Mod 12. 
-- Counter that increments until 11.
-- *************************************************************************

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_unsigned.all;
	
-- -------------------------------------------------------------------------
ENTITY CounterMod12 IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: in STD_LOGIC;
	Count	: out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END CounterMod12;

ARCHITECTURE behavioral of CounterMod12 IS

SIGNAL Count_Internal: STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); 

BEGIN
	PROCESS(Clk,Reset)
	BEGIN
		IF rising_edge(Clk) THEN
			IF Reset='1' THEN 	--Reset
				Count_Internal <= (OTHERS =>'0');
			ELSE 
				IF (Tick = '1') THEN --Synchronized with the tick.
					IF Count_Internal = "1011" THEN -- Increment until 11. 
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

