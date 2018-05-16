-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Reference Design of IP UART + Telemetre Ultrason
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- -------------------------------------------------------------------------
ENTITY ReferenceDesign IS PORT(
-- -------------------------------------------------------------------------
	Clk				: in STD_LOGIC;
	Reset				: in STD_LOGIC; 
	Echo				: in STD_LOGIC;
	TxData_In		: in STD_LOGIC_VECTOR(7 DOWNTO 0);
	RxDatum_In		: in STD_LOGIC;
	TxDatum_Out		: out STD_LOGIC;
	DigitSS1			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS2			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS3			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	Pulse				: out STD_LOGIC); 
END ReferenceDesign;



ARCHITECTURE Stuctural OF ReferenceDesign  is


COMPONENT TELEMETRE_ULTRASON IS 
PORT(
	Clk				: in STD_LOGIC;
	Reset				: in STD_LOGIC; 
	Trigger			: in STD_LOGIC; 
	Echo				: in STD_LOGIC;
	Digit1			: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	Digit2			: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	Digit3			: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	DigitSS1			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS2			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS3			: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	Pulse				: out STD_LOGIC); 
END COMPONENT;

COMPONENT UART_Reception IS PORT(
	Clk			: in STD_LOGIC;
	Reset			: in STD_LOGIC;
	RxDatum_In	: in STD_LOGIC;
	RxEnd			: out STD_LOGIC;
	RxData_Out	: out STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT ;

COMPONENT UART_Emission IS PORT(
	Clk			: in STD_LOGIC;
	Reset			: in STD_LOGIC;
	Trigger		: in STD_LOGIC;
	TxData_In	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
	TxDatum_Out	: out STD_LOGIC;
	TxEnd			: out STD_LOGIC);
END COMPONENT ;

-- -------------------------------------------------------------------------
COMPONENT FSM_SERIAL_TX IS
-- -------------------------------------------------------------------------
PORT(
	Clk   		: IN STD_LOGIC; -- System clock at the rate of 50MHz.
	Reset   		: IN STD_LOGIC; -- System reset 
	Trigger		: IN STD_LOGIC; -- Trigger Data Tramission
	TxEnd			: IN STD_LOGIC; 
	Data1			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- The digit of ones in the measured distance
	Data2			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- The digit of tens in the measured distance
	Data3			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- The digit of hundreds in the measured distance
	Trigger_UART: OUT STD_LOGIC; -- Trigger UART
	Data_Out		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Decoder7Seg is
PORT(
	Digit: in std_logic_vector(3 DOWNTO 0);
	SevenSeg : out std_logic_vector(6 DOWNTO 0)
);
END component;


SIGNAL Tick_Emission : STD_LOGIC;
SIGNAL Count_Emission : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL WriteData_Emission : STD_LOGIC;


SIGNAL Reset_Internal : STD_LOGIC;
SIGNAL Trigger_Internal : STD_LOGIC;

SIGNAL SIGNAL_OBSOLETE1 : STD_LOGIC;
SIGNAL SIGNAL_OBSOLETE2 : STD_LOGIC;
SIGNAL Data_Internal	:  STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL Trigger_Display : STD_LOGIC;
SIGNAL Trigger_Tx : STD_LOGIC;
SIGNAL Trigger_Sensor : STD_LOGIC;
SIGNAL TxEnd : STD_LOGIC;
SIGNAL Digit1	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Digit2	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Digit3	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL State_Trigger_Internal	:  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL State_Echo_Internal		: STD_LOGIC_VECTOR(3 DOWNTO 0);
--SIGNAL DistanceData	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DistanceData	: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL CH1	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CH2	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CH3	: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL Tick : STD_LOGIC;
BEGIN
	Reset_Internal <= NOT  Reset;
	
	Trigger_Sensor <= '1' WHEN Data_Internal = "01010011" ELSE --'S' ou 's' 
							'1' WHEN Data_Internal = "01110011" ELSE
							'0';
	Trigger_Display <= '1' WHEN Data_Internal = "01000100" ELSE
							 '1' WHEN Data_Internal = "01100100" ELSE
							 '0';

	
	C0: COMPONENT UART_Reception PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset_Internal,
		RxDatum_In	=> RxDatum_In,
		RxEnd			=> SIGNAL_OBSOLETE1,
		RxData_Out	=> Data_Internal);	
	
	C1: COMPONENT UART_Emission PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset_Internal,
		Trigger		=> Trigger_Tx,
		TxData_In	=> DistanceData,
		TxDatum_Out	=> TxDatum_Out,
		TxEnd 		=> TxEnd);
		
	CH1 <= Std_LOGIC_VECTOR(Unsigned(Digit3) + 48);
	CH2 <= Std_LOGIC_VECTOR(Unsigned(Digit2) + 48);
	CH3 <= Std_LOGIC_VECTOR(Unsigned(Digit1) + 48);	
		
	C2: COMPONENT TELEMETRE_ULTRASON PORT MAP(
		Clk				=> Clk,
		Reset				=> Reset_Internal,
		Trigger			=> Trigger_Sensor,
		Echo				=> Echo,
		Digit1			=> Digit1(3 DOWNTO 0),
		Digit2			=> Digit2(3 DOWNTO 0),
		Digit3			=> Digit3(3 DOWNTO 0),
		DigitSS1			=> DigitSS1,
		DigitSS2			=> DigitSS2,
		DigitSS3			=> DigitSS3,
		Pulse				=> Pulse);

		
	C3: COMPONENT FSM_SERIAL_TX PORT MAP(
		Clk   			=> Clk,
		Reset   			=> Reset_Internal,
		Trigger			=> Trigger_Display,
		TxEnd				=> TxEnd,
		Data1				=> CH1,
		Data2				=> CH2,
		Data3				=> CH3,
		Trigger_UART	=> Trigger_Tx,
		Data_Out			=> DistanceData);

END Stuctural;

