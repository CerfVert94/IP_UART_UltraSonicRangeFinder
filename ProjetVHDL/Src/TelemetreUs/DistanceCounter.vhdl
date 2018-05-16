-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
--  
-- *************************************************************************
-- Distance Counter
-- The count increments each time when the tick is high. 
-- The distance is proportional to the count.
-- *************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


-- -------------------------------------------------------------------------
ENTITY DistanceCounter IS
-- -------------------------------------------------------------------------
PORT(
	Clk		: in std_logic; --
	Reset	: in std_logic;
	Tick	: in std_logic;
	Count 	: out std_logic_vector(14 DOWNTO 0)
);
END DistanceCounter;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of DistanceCounter is
-- -------------------------------------------------------------------------

SIGNAL Count_Internal: std_logic_vector(14 DOWNTO 0) := (OTHERS => '0'); 
BEGIN

PROCESS(Clk,Reset)
BEGIN
	IF rising_edge(Clk) THEN
		IF Reset='1' THEN 
			Count_Internal <= (OTHERS =>'0');
		ELSE 
			IF (Tick = '1') THEN
				Count_Internal <= Count_Internal + 1;
			END IF;
		END IF;
	END IF;
END PROCESS;

Count  <= Count_Internal;
END behavioral; 


