-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- UART RECEPTION block
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
--USE ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY UART_Reception IS PORT(
	Clk			: in STD_LOGIC; --System Clock 
	Reset			: in STD_LOGIC; -- Reset
	RxDatum_In	: in STD_LOGIC; -- Datum received
	RxEnd			: out STD_LOGIC; -- Indication of the end of transmission
	RxData_Out	: out STD_LOGIC_VECTOR(7 DOWNTO 0) -- The series of datum received and stored.
);
END UART_Reception ;



ARCHITECTURE STRUCTURAL OF UART_Reception  IS 

COMPONENT FDiv_Reception IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: out STD_LOGIC
);
END COMPONENT;


COMPONENT CounterMod19 IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: in STD_LOGIC;
	Count	: out STD_LOGIC_VECTOR(4 DOWNTO 0)
);
END COMPONENT;

COMPONENT Register_Rx8Bits IS 
PORT(
	Clk			: in STD_LOGIC;
	Reset		: in STD_LOGIC;
	Tick		: in STD_LOGIC;
	WriteData 	: in STD_LOGIC;
	Datum_In 	: in STD_LOGIC;
	Data_Out 	: out STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT FSM_Reception IS PORT(
	Clk			: IN STD_LOGIC;
	Tick		: IN STD_LOGIC;
	Reset		: IN STD_LOGIC;
	RxDatum_In		: IN STD_LOGIC;
	Count		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	WriteData 	: OUT STD_LOGIC;
	RxEnd 		: OUT STD_LOGIC;
	RxDatum_Out 	: OUT STD_LOGIC;
	Idle_State 	: OUT STD_LOGIC
);
END COMPONENT;



COMPONENT HexDecoder7Seg is
PORT(
	Digit	 		: in std_logic_vector(3 DOWNTO 0); --Digit
	SevenSeg 	: out std_logic_vector(6 DOWNTO 0) --Digit expressed in the 7 segment-format.
);
END COMPONENT;

SIGNAL Idle_FSM_Emission : STD_LOGIC;
SIGNAL Tick_Emission : STD_LOGIC;
SIGNAL Count_Emission : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL WriteData_Emission : STD_LOGIC;
SIGNAL RxDatum_Internal : STD_LOGIC_VECTOR(7 DOWNTO 0);


SIGNAL Idle_FSM_Reception : STD_LOGIC;
SIGNAL Tick_Reception : STD_LOGIC;
SIGNAL Count_Reception : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL WriteData_Reception : STD_LOGIC;
SIGNAL RxDatum_Out : STD_LOGIC;

SIGNAL UData_Internal : UNSIGNED(7 DOWNTO 0);
SIGNAL HexDigit : UNSIGNED(7 DOWNTO 0);


BEGIN	
	--RECEPTION PART (PC->FPGA)
	C0: COMPONENT FDiv_Reception PORT MAP(
		Clk	=> Clk,
		Reset	=> Idle_FSM_Reception, -- local reset
		Tick	=> Tick_Reception);
	C1: COMPONENT CounterMod19 PORT MAP(
		Clk	=> Clk,
		Reset	=> Idle_FSM_Reception, -- local reset-- local reset
		Tick	=> Tick_Reception,
		Count	=> Count_Reception);
	C2: COMPONENT FSM_Reception PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick_Reception,
		RxDatum_In	=> RxDatum_In,
		Count			=> Count_Reception,
		WriteData 	=> WriteData_Reception,
		RxEnd 		=> RxEnd,
		RxDatum_Out	=> RxDatum_Out,
		Idle_State 	=> Idle_FSM_Reception); -- Serves as a local reset for the frequency divider and counter
	C3: COMPONENT Register_Rx8Bits PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick_Reception,
		WriteData 	=> WriteData_Reception,
		Datum_In 	=> RxDatum_Out,
		Data_Out 	=> RxDatum_Internal);
		
		RxData_Out <= RxDatum_Internal;
		UData_Internal <= UNSIGNED(RxDatum_Internal);

		

	--ASCII_TO_DEC:PROCESS(RxDatum_Internal)
	--BEGIN
		--IF (96 < RxDatum_Internal) and (RxDatum_Internal < 103) THEN -- 'a' ~ 'f'
			--HexDigit <= UData_Internal - 87; -- -97 + 10 = -87
		--ELSIF (64 < RxDatum_Internal) and (RxDatum_Internal < 71) THEN -- 'A' ~ 'F'
			--HexDigit <= UData_Internal - 55; -- -65 + 10 = -87
		--ELSIF (47 < RxDatum_Internal) and (RxDatum_Internal < 58) THEN -- '0'~'9'
--			HexDigit <= UData_Internal - 48;
	--	ELSE
		--	HexDigit <= "00001000";
--		END IF;
--	END PROCESS;
		 
--	C8: COMPONENT HexDecoder7Seg PORT MAP(
	--	Digit 	=> STD_LOGIC_VECTOR(HexDigit(3 DOWNTO 0)),
	--	SevenSeg => Display);
			
END STRUCTURAL;

