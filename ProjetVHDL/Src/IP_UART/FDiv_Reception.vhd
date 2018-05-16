-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Frequency Divider for 19200Hz Clock (52.08us) 
-- It produces a Tick every 52.08us for FSM Reception.
-- *************************************************************************
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_unsigned.all;


-- -------------------------------------------------------------------------
ENTITY FDiv_Reception IS 
-- -------------------------------------------------------------------------
 PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: out STD_LOGIC
);
END FDiv_Reception;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of FDiv_Reception IS
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
				IF Count = "0101000101011" THEN -- if count = 50e6/19200 then,
					Count <= (OTHERS => '0');
					Tick <= '1';
				ELSE 
					Count <= Count + 1;
					Tick <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END behavioral; 
