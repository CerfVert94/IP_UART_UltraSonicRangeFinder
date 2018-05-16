-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- UART EMISSION block
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
--USE ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY UART_Emission IS PORT(
	Clk			: in STD_LOGIC; --System Clock
	Reset		: in STD_LOGIC; --Reset
	Trigger		: in STD_LOGIC; -- Triggers the FSM
	TxData_In	: in STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data to send to the PC
	TxDatum_Out	: out STD_LOGIC; --Datum that is actually  sent to the PC
	TxEnd		: out STD_LOGIC -- Indication of the end of transmission.
);
END UART_Emission ;



ARCHITECTURE STRUCTURAL OF UART_Emission  IS 

COMPONENT FDiv_Emission IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: out STD_LOGIC
	);
END COMPONENT;

COMPONENT CounterMod12 IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: in STD_LOGIC;
	Count	: out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;


COMPONENT Register_Tx10Bits IS 
PORT(
	Clk, Reset,Tick : in STD_LOGIC;
	WriteData : in STD_LOGIC;
	Data_In : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	Datum_Out : out STD_LOGIC
	);
END COMPONENT;


COMPONENT FSM_Emission IS PORT(
	Clk			: IN STD_LOGIC;
	Tick		: IN STD_LOGIC;
	Reset		: IN STD_LOGIC;
	Trigger		: IN STD_LOGIC;
	Count		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	WriteData	: OUT STD_LOGIC;
	Idle_State	: OUT STD_LOGIC;
	TxEnd : OUT STD_LOGIC);
END COMPONENT;

SIGNAL FSM_IdleState : STD_LOGIC;
SIGNAL Tick_Emission : STD_LOGIC;
SIGNAL Count_Emission : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL WriteData_Emission : STD_LOGIC;

BEGIN

	--EMISSION PART(FPGA->PC)
	C0: COMPONENT FDiv_Emission PORT MAP(
		Clk	=> Clk,
		Reset	=> FSM_IdleState, --Local reset
		Tick	=> Tick_Emission);
	C1: COMPONENT CounterMod12 PORT MAP(
		Clk	=> Clk,
		Reset	=> FSM_IdleState,--Local reset
		Tick	=> Tick_Emission,
		Count	=> Count_Emission);
	C2: COMPONENT FSM_Emission PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick_Emission,
		Trigger		=> Trigger,
		Count			=> Count_Emission,
		WriteData	=> WriteData_Emission,
		Idle_State 	=> FSM_IdleState, -- Serves as a local reset for the frequency divider and counter
			TxEnd 			=> TxEnd );
	C3: COMPONENT Register_Tx10Bits PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick_Emission,
		WriteData	=> WriteData_Emission,
		Data_In		=> TxData_In,
		Datum_Out	=> TxDatum_Out);
		
END STRUCTURAL;
