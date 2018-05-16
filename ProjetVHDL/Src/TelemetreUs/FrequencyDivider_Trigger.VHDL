-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Frequency Divider for 100kHz Clock (10us) 
-- It is designed to produce a tick after 10us its activation.
-- *************************************************************************
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	
-- -------------------------------------------------------------------------
ENTITY FDiv_Trigger IS
-- -------------------------------------------------------------------------
PORT(
	Clk		: in std_logic; -- System Clock at the rate of 50MHz
	Reset	: in std_logic; -- System reset
	Tick 	: out std_logic -- Tick rate of 100kHz (10us).
);
END FDiv_Trigger;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of FDiv_Trigger is
-- -------------------------------------------------------------------------

SIGNAL Count: std_logic_vector(10 DOWNTO 0) := (OTHERS => '0'); 

BEGIN
	PROCESS(Clk,Reset)
	BEGIN
	IF rising_edge(Clk) THEN
		IF Reset ='1' THEN 
			Count <= (OTHERS =>'0');
			Tick  <= '0';
		ELSE 
			IF Count = "00111110100" THEN --50e6/100e3 = 500
				Count <= (OTHERS =>'0');
				Tick  <= '1';
			ELSE 
				Count <= Count + 1;
				Tick  <= '0';
			END IF;
		END IF;
	END IF;
	END PROCESS;
END behavioral; 