-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Telemetre Ultrason block
-- *************************************************************************

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- -------------------------------------------------------------------------
ENTITY TELEMETRE_ULTRASON IS PORT(
-- -------------------------------------------------------------------------
	Clk			: in STD_LOGIC;
	Reset			: in STD_LOGIC; 
	Trigger		: in STD_LOGIC; 
	Echo			: in STD_LOGIC;
	Digit1		: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	Digit2		: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	Digit3		: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	DigitSS1		: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS2		: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	DigitSS3		: out STD_LOGIC_VECTOR(6 DOWNTO 0);
	Pulse			: out STD_LOGIC
); 
END TELEMETRE_ULTRASON ;



ARCHITECTURE Stuctural OF TELEMETRE_ULTRASON  is

-- **************************************************************************
-- *************************** Frequency Dividers ***************************
	COMPONENT FDiv_Trigger IS
	PORT(
		Clk		: in STD_LOGIC; -- System Clock at the rate of 50MHz
		Reset	: in STD_LOGIC; -- System reset
		Tick 	: out STD_LOGIC -- Tick rate of 100kHz (10us).
	);
	END COMPONENT;

	COMPONENT FDiv_Echo IS  
	PORT(
		Clk		: in STD_LOGIC; -- System Clock at the rate of 50MHz
		Reset	: in STD_LOGIC; -- System reset
		Tick 	: out STD_LOGIC -- 170kHz (5.8uS) Tick 
	);
	END COMPONENT;

	COMPONENT FDiv_Timeout is 
	PORT(
		Clk		: in STD_LOGIC; -- System Clock at the rate of 50MHz
		Reset	: in STD_LOGIC; -- System reset
		Tick 	: out STD_LOGIC -- 25ms tick(40Hz)
	);
	END COMPONENT;

-- **************************************************************************
-- ******************************* 7 segments *******************************
	COMPONENT Decoder7Seg is
	PORT(
		Digit	 	: in STD_LOGIC_VECTOR(3 DOWNTO 0); --Digit
		SevenSeg 	: out STD_LOGIC_VECTOR(6 DOWNTO 0) --Digit expressed in the 7 segment-format.
	);
	END COMPONENT;
	COMPONENT Display7Seg IS
	PORT(	
		Data 	: in std_logic_vector(14 DOWNTO 0);	-- Number to show on the 7 segment display.
		Digit1  : out std_logic_vector(3 DOWNTO 0);	-- Digit of ones expressed.
		Digit2  : out std_logic_vector(3 DOWNTO 0);	-- Digit of tens expressed.
		Digit3  : out std_logic_vector(3 DOWNTO 0);	-- Digit of hundreds expressed.
		DigitSS1  : out std_logic_vector(6 DOWNTO 0);	-- Digit of ones expressed in 7 segment format
		Digitss2  : out std_logic_vector(6 DOWNTO 0);	-- Digit of tens expressed in 7 segment format 
		DigitSS3  : out std_logic_vector(6 DOWNTO 0)	-- Digit of hundreds expressed in 7 segment format
		); 
	END COMPONENT;
-- **************************************************************************
-- ************************** Finite State Machine **************************
	COMPONENT FSM_ECHO IS
	PORT(
		Clk   			: IN STD_LOGIC; -- System clock at the rate of 50MHz.
		Reset   		: IN STD_LOGIC; -- System reset 
		Echo			: IN STD_LOGIC; -- Signal echo from HR-SC04
		Tick_Timeout	: IN STD_LOGIC; -- Tick at the rate of 40Hz to wait until timeout.
		Write_Data 		: OUT STD_LOGIC; -- Send a command to save current distance measured to a PIPO register.
		Idle_State		: OUT STD_LOGIC -- Indicate whether the current state is 'Idle' / 'Finish'.
	);
	END COMPONENT;

	COMPONENT FSM_TRIGGER IS
	PORT(
		Clk				: IN STD_LOGIC; -- System clock at the rate of 50MHz.
		Reset			: IN STD_LOGIC; -- System reset 
		Tick_Trigger	: IN STD_LOGIC; -- Tick at the rate of 100KHz.
		Trigger		: IN STD_LOGIC; -- Trigger FSM.
		Pulse			: OUT STD_LOGIC; -- Pulse signal.
		Idle_State		: OUT STD_LOGIC -- Indicate whether the current state is 'Idle' / 'Finish'.
	);
	END COMPONENT;
-- **************************************************************************
-- ******************* Distance Counter / Data register  ********************
	COMPONENT DistanceCounter IS
	PORT(
		Clk		: in STD_LOGIC;
		Reset	: in STD_LOGIC;
		Tick	: in STD_LOGIC;
		Count 	: out STD_LOGIC_VECTOR(14 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT PIPO_Register IS
	PORT(
		Clk			: in STD_LOGIC; 
		Reset			: in STD_LOGIC;
		Write_Data	: in STD_LOGIC;
		Data_In		: in STD_LOGIC_VECTOR(14 DOWNTO 0);
		Data_Out	: out STD_LOGIC_VECTOR(14 DOWNTO 0)
	);
	END COMPONENT;
-- **************************************************************************
-- **************************************************************************

SIGNAL Tick_Trigger: STD_LOGIC; 
SIGNAL Tick_Timeout: STD_LOGIC; 
SIGNAL Tick_Echo: STD_LOGIC; 
SIGNAL FSM_Trigger_Idle : STD_LOGIC; 
SIGNAL FSM_Echo_Idle : STD_LOGIC; 
SIGNAL Trigger_Internal : STD_LOGIC; 
SIGNAL Write_Data : STD_LOGIC; 
SIGNAL Count : STD_LOGIC_VECTOR(14 downto 0); 
SIGNAL Distance : STD_LOGIC_VECTOR(14 downto 0); 

BEGIN
	--Trigger_Internal <= NOT Trigger; -- Button is negative logic.
	--Reset_Internal <= NOT  Reset;
-- Frequency Dividers
	C1 : COMPONENT FDiv_Trigger PORT MAP(
		Clk		=> Clk,
		Reset 	=> FSM_Trigger_Idle,
		Tick 		=> Tick_Trigger);
	
	C2 : COMPONENT FDiv_Echo PORT MAP(
		Clk 	=> Clk,
		Reset	=> FSM_Echo_Idle,
		Tick 	=> Tick_Echo);

	C3: COMPONENT FDiv_TimeOut PORT MAP(
		Clk => Clk,
		Reset => FSM_Echo_Idle,
		Tick => Tick_Timeout);

-- Finite State Machines	
	C4 : COMPONENT FSM_TRIGGER PORT MAP(
		Clk				=> Clk,
		Reset				=> Reset,
		Tick_Trigger	=> Tick_Trigger,
		Trigger			=> Trigger,
		Pulse				=> Pulse,
		Idle_State		=> FSM_Trigger_Idle);
		
	C5 : COMPONENT FSM_ECHO PORT MAP(
		Clk				=> Clk,
		Reset				=> Reset,
		Tick_Timeout	=> Tick_Timeout,
		ECHO				=> ECHO,
		Write_Data		=> Write_Data,
		Idle_State		=> FSM_Echo_Idle);
	
-- Distance Count/Save/Display
	C8 : COMPONENT DistanceCounter PORT MAP(
		Clk	=> Clk,
		Reset	=> FSM_Echo_Idle,
		Tick	=> Tick_Echo,
		Count	=> Count);
	
	C6 : COMPONENT PIPO_Register PORT MAP(
		Clk			=>Clk,
		Reset			=>Reset,
		Write_Data	=>Write_Data,
		Data_In		=>Count,
		Data_Out		=>Distance);
	
	C7: COMPONENT Display7Seg PORT MAP(
		Data	=> Distance,
		Digit1  => Digit1,
		Digit2  => Digit2,
		Digit3  => Digit3,
		DigitSS1 => DigitSS1,
		Digitss2 => Digitss2,
		DigitSS3 => DigitSS3);
	

END Stuctural;

