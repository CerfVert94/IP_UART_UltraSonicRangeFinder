-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- Projet VHDL (EISE3)
-- IP Telemetre Ultrason
-- 
-- *************************************************************************
-- 7 Segments Decoder (Negative logic).
-- A digit is converted to 7 segment-format.
-- *************************************************************************

Library IEEE;
use ieee.std_logic_1164.all;

-- -------------------------------------------------------------------------
ENTITY Decoder7Seg is
-- -------------------------------------------------------------------------
PORT(
	Digit	 	: in std_logic_vector(3 DOWNTO 0); --Digit
	SevenSeg 	: out std_logic_vector(6 DOWNTO 0) --Digit expressed in the 7 segment-format.
);
END Decoder7Seg;

-- -------------------------------------------------------------------------
ARCHITECTURE behavioral of Decoder7Seg is
-- -------------------------------------------------------------------------

BEGIN
	WITH Digit SELECT
		SevenSeg <= "1000000" WHEN "0000", --0
					"1111001" WHEN "0001", --1
					"0100100" WHEN "0010", --2
					"0110000" WHEN "0011", --3
					"0011001" WHEN "0100", --4
					"0010010" WHEN "0101", --5
					"0000010" WHEN "0110", --6
					"1111000" WHEN "0111", --7
					"0000000" WHEN "1000", --8
					"0010000" WHEN "1001", --9
					"0000110" WHEN OTHERS; --E (Error)
END behavioral;