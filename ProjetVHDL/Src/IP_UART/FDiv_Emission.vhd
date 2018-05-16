-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason 
--
-- *************************************************************************
-- Frequency Divider for 9600Hz Clock (104.17us) 
-- It produces a Tick every 104.17us for FSM Emission.
-- *************************************************************************

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_unsigned.all;


-- -------------------------------------------------------------------------
ENTITY FDiv_Emission IS 
-- -------------------------------------------------------------------------
 PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: out STD_LOGIC
);
END FDiv_Emission;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of FDiv_Emission IS
-- -------------------------------------------------------------------------

SIGNAL Count: STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0'); 

BEGIN

PROCESS(Clk,Reset)
BEGIN
IF rising_edge(Clk) THEN
	IF Reset='1' THEN 
		Count <= (OTHERS => '0');
		Tick <= '0';
	ELSE 
		IF Count = "1010001010111" THEN -- if count = 50e6/9600 then,
			Count <= (OTHERS => '0'); -- Reset the count.
			Tick <= '1'; -- Tick high
		ELSE 
			Count <= Count + 1;
			Tick <= '0'; -- Tick low
		END IF;
	END IF;
END IF;
END PROCESS;

END behavioral; 
