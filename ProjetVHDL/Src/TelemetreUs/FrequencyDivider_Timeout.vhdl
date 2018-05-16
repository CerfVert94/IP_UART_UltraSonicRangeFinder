
-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Frequency Divider for 16.6Hz Clock (6ms)
-- It produces a tick every 60ms to measure the timeout for the telemeter.
-- *************************************************************************
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;

-- -------------------------------------------------------------------------
ENTITY FDiv_Timeout is 
-- -------------------------------------------------------------------------
PORT(
	Clk		: in std_logic; -- System Clock at the rate of 50MHz
	Reset	: in std_logic; -- System reset
	Tick 	: out std_logic -- 60ms tick(6ms)
);
END FDiv_Timeout;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of FDiv_Timeout is
-- -------------------------------------------------------------------------

SIGNAL Count: std_logic_vector(21 DOWNTO 0) := (OTHERS => '0'); 

BEGIN

	PROCESS(Clk, Reset)
	BEGIN
		if rising_edge(Clk) THEN
			if Reset = '1' THEN 
				Count <= (OTHERS =>'0');
				Tick  <= '0';
			else 
				if Count = "1011011100011011000000" THEN --50e6/16.6Hz = 3e6
					Count <= (OTHERS =>'0');
					Tick  <= '1';
				else 
					Count <= Count + 1;
					Tick  <= '0';
				END if;
			END if;
		END if;
	END PROCESS;
END behavioral; 