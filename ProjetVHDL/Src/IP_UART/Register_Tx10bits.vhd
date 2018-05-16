-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- 10 bits shift register designed for IP UART Reception.
-- When shifted to the right, a bit 1 is added (Parallel input)
-- Output is the least significant bit (Serial output)
-- *************************************************************************
Library ieee;
use ieee.STD_LOGIC_1164.all;

ENTITY Register_Tx10Bits IS 
PORT(
	Clk, Reset,Tick : in STD_LOGIC;
	WriteData : in STD_LOGIC;
	Data_In : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	Datum_Out : out STD_LOGIC
	);
END Register_Tx10Bits;

ARCHITECTURE behavioral of Register_Tx10Bits IS

Signal Data_Internal : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '1');

BEGIN

	Datum_Out <= Data_Internal(0); --Output

	Process(Clk)
	BEGIN
		IF rising_edge(Clk) THEN
			IF(Reset = '1') THEN
				Data_Internal <= (OTHERS => '1');
			ELSE
				IF WriteData = '1' AND Tick = '1'THEN --Permission to write
					Data_Internal(8 DOWNTO 1) <= Data_In; -- Write data in the middle 
					Data_Internal(0) <= '0'; -- Write the start bit
				ELSE
					IF Tick = '1' THEN
						Data_Internal(9) <= '1'; --'1' in the MSB (stop bit)
						Data_Internal(8 DOWNTO 0)<=Data_Internal(9 DOWNTO 1);
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END behavioral;

