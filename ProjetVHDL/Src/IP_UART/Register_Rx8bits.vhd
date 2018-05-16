-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
--  
-- *************************************************************************
-- 8 bits shift register designed for IP UART Reception.
-- When write permission is granted, a datum from the input Datum_in is 
-- written in the most significant digit(serial input).
-- The output is on 8 bits of data (parallel ouput)
-- *************************************************************************
Library ieee;
use ieee.STD_LOGIC_1164.all;

ENTITY Register_Rx8Bits IS 
PORT(
	Clk			: in STD_LOGIC;
	Reset		: in STD_LOGIC;
	Tick		: in STD_LOGIC;
	WriteData 	: in STD_LOGIC;
	Datum_In 	: in STD_LOGIC;
	Data_Out 	: out STD_LOGIC_VECTOR(7 DOWNTO 0));
END Register_Rx8Bits;

ARCHITECTURE behavioral of Register_Rx8Bits IS

SIGNAL Data_Internal : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN

	Data_Out <= Data_Internal;

	Process(Clk)
	BEGIN
		IF Rising_Edge(Clk) THEN	
			IF Reset = '1' THEN 
				Data_Internal <= (OTHERS=>'0');
			ELSE 
				If Tick = '1' AND WriteData='1' THEN  -- Synchronized on the baud rate.
					Data_Internal(7) <= Datum_In; --Datum_In in the MSB.
					Data_Internal(6 DOWNTO 0)<=Data_Internal(7 DOWNTO 1); --Shift right
				END IF;
			END IF;
		END IF;
	END PROCESS;
END behavioral;

