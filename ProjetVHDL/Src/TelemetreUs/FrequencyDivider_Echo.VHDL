-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
--
-- *************************************************************************
-- Frequency Divider for 17000Hz Clock (58us) 
-- It produces a tick every 58us to calculate the distance from signal ECHO. 
-- The time length of 58us in ECHO signal corresponds to 1cm 
-- *************************************************************************
	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
-- -------------------------------------------------------------------------
ENTITY FDiv_Echo IS  
-- -------------------------------------------------------------------------
PORT(
	Clk		: in std_logic; -- System clock at the rate of 50MHz
	Reset	: in std_logic; -- System reset
	Tick 	: out std_logic -- 17000Hz (58uS) Tick 
);
END FDiv_Echo;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral OF FDiv_Echo IS
-- -------------------------------------------------------------------------

SIGNAL Count: std_logic_vector(11 DOWNTO 0) := (OTHERS => '0'); 

BEGIN
	
	PROCESS(Clk,Reset)
	BEGIN
	IF rising_edge(Clk) THEN
		IF Reset='1' THEN 
			Count <= (OTHERS =>'0');
			Tick  <= '0';
		ELSE 
			-- 101101111101 = 2941 = 50e6/17e3 = 1.00 cm
			-- 000100100110 =  294 = 50e6/17e4 = 0.10 cm
			--	000000011101 =   29 = 50e6/17e5 = 0.01 cm
			IF Count = "101101111101" THEN --50e6/17e3 = 2941
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