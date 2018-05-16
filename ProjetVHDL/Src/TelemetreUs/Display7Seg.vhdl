-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- 7 Segments Display of 4 digits.
-- The number entered is converted to 4 digits of 7 segment-format.
-- *************************************************************************


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- -------------------------------------------------------------------------
ENTITY Display7Seg IS
-- -------------------------------------------------------------------------
 PORT(
	Data 	: in std_logic_vector(14 DOWNTO 0);	-- Number to show on the 7 segment display.
	Digit1  : out std_logic_vector(3 DOWNTO 0);	-- Digit of ones expressed.
	Digit2  : out std_logic_vector(3 DOWNTO 0);	-- Digit of tens expressed.
	Digit3  : out std_logic_vector(3 DOWNTO 0);	-- Digit of hundreds expressed.
	DigitSS1  : out std_logic_vector(6 DOWNTO 0);	-- Digit of ones expressed in 7 segment format
	DigitSS2  : out std_logic_vector(6 DOWNTO 0);	-- Digit of tens expressed in 7 segment format 
	DigitSS3  : out std_logic_vector(6 DOWNTO 0)	-- Digit of hundreds expressed in 7 segment format
	
); 
END Display7Seg;


-- -------------------------------------------------------------------------
ARCHITECTURE Structural of Display7Seg IS
-- -------------------------------------------------------------------------

SIGNAL Number			: unsigned(14 DOWNTO 0); -- Data (in UNSIGNED type).
SIGNAL Digit1_Internal	: unsigned(14 DOWNTO 0); -- Digit of ones (in UNSIGNED type).
SIGNAL Digit2_Internal	: unsigned(14 DOWNTO 0); -- Digit of hundreds (in UNSIGNED type).
SIGNAL Digit3_Internal	: unsigned(14 DOWNTO 0); -- Digit of thousands (in UNSIGNED type).

	
COMPONENT Decoder7Seg is
PORT(
	Digit: in std_logic_vector(3 DOWNTO 0);
	SevenSeg : out std_logic_vector(6 DOWNTO 0)
);
END component;

BEGIN
  -- Conversion from STD_LOGIC_VECTOR to UNSIGNED
  Number <= Unsigned(Data);
  
  -- Extract each digit from number.
  Digit1_Internal <= ((Number mod 10) / 1);
  Digit2_Internal <= ((Number mod 100) / 10);
  Digit3_Internal <= ((Number mod 1000) / 100);
  
  -- Conversion from UNSIGNED to STD_LOGIC_VECTOR
  Digit1 <= STD_LOGIC_VECTOR(Digit1_Internal(3 DOWNTO 0));
  Digit2 <= STD_LOGIC_VECTOR(Digit2_Internal(3 DOWNTO 0));
  Digit3 <= STD_LOGIC_VECTOR(Digit3_Internal(3 DOWNTO 0));
  
  -- Convert each digit into seven segment format.
  C0: component Decoder7Seg PORT map (
  Digit => STD_LOGIC_VECTOR(Digit1_Internal(3 DOWNTO 0)), 
  SevenSeg  => DigitSS1 );
  
  C1: component Decoder7Seg PORT map (
  Digit => STD_LOGIC_VECTOR(Digit2_Internal(3 DOWNTO 0)),
  SevenSeg  => DigitSS2 );
  
  C2: component Decoder7Seg PORT map (
  Digit => STD_LOGIC_VECTOR(Digit3_Internal(3 DOWNTO 0)),
  SevenSeg  => DigitSS3 );
  
  
END Structural;
