-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- Projet VHDL (EISE3)
-- IP Telemetre Ultrason
-- 
-- *************************************************************************
-- Finite State Machine (Moore) for transmission of multiple sets of data.
-- *************************************************************************

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all; 
USE ieee.numeric_std.all;
use ieee.STD_LOGIC_unsigned.all;


-- -------------------------------------------------------------------------
ENTITY FSM_SERIAL_TX IS
-- -------------------------------------------------------------------------
PORT(
	Clk   		: IN STD_LOGIC; -- System clock at the rate of 50MHz.
	Reset   		: IN STD_LOGIC; -- System reset 
	Trigger		: IN STD_LOGIC; -- Trigger Data Tramission
	TxEnd			: IN STD_LOGIC; 
	Data1			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	Data2			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	Data3			: IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	Trigger_UART: OUT STD_LOGIC; -- Trigger UART
	Data_Out		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END FSM_SERIAL_TX;


ARCHITECTURE Stuctural OF FSM_SERIAL_TX IS

COMPONENT FDiv_Emission IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: out STD_LOGIC
	);
END COMPONENT;

COMPONENT UART_Emission IS PORT(
	Clk			: in STD_LOGIC;
	Reset			: in STD_LOGIC;
	Trigger		: in STD_LOGIC;
	TxData_In	: in STD_LOGIC_VECTOR(7 DOWNTO 0);
	TxDatum_Out	: out STD_LOGIC;
	TxEnd			: out STD_LOGIC
	);
END COMPONENT;

COMPONENT CounterMod6 IS 
PORT(
	Clk		: in STD_LOGIC;
	Reset	: in STD_LOGIC;
	Tick	: in STD_LOGIC;
	Count	: out STD_LOGIC_VECTOR(3 DOWNTO 0)
);
END COMPONENT;


TYPE STATE_TYPE IS (Idle, Transfer, Hold, Finish);  -- Define the states
SIGNAL PS : STATE_TYPE;    -- State present
SIGNAL FS : STATE_TYPE;    -- State futur

SIGNAL TxData_In : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Count : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Reset_Internal : STD_LOGIC;
SIGNAL TxEnd_Internal : STD_LOGIC;
--SIGNAL Trigger_UART : STD_LOGIC;
BEGIN


	
	
	DETERMINE_PRESENT_STATE : PROCESS(Clk,Reset)
    BEGIN
		IF  rising_edge(Clk)  THEN
			IF Reset = '1' THEN
				PS <= IDLE;
			ELSE 
				PS <= FS;
			END IF; 
		END IF;
	END PROCESS;
	
	C1: COMPONENT CounterMod6 PORT MAP(
		Clk	=> Clk,
		Reset	=> Reset_Internal,
		Tick	=> TxEnd,
		Count	=> Count);
		
	
	DETERMINE_FUTURE_STATE : PROCESS(CLK,TxEnd,Data1,Data2,Data3,PS)	
	BEGIN
		CASE PS IS
			WHEN IDLE =>
				Trigger_UART <= '0';
				Reset_Internal <= '1';
				
				IF Trigger = '1' THEN
					FS <= Transfer;
				ELSE	
					FS <= Idle;
				END IF;
		
			WHEN Transfer =>
				CASE Count IS
					WHEN "0000" =>
						TxData_In <= Data1;
						FS <= Hold;
					WHEN "0001" =>
						TxData_In <= Data2;
						FS <= Hold;
					WHEN "0010" =>
						TxData_In <= Data3;
						FS <= Hold;
					WHEN "0011" =>
						TxData_In <= "01000011"; -- C
						FS <= Hold;
					WHEN "0100" =>
						TxData_In <= "01001101"; -- M
						FS <= Hold;
					WHEN "0101" =>
						TxData_In <= "00100000"; -- Space
						FS <= Finish;
					WHEN OTHERS =>
					
				END CASE;
				Reset_Internal <= '0';
				Trigger_UART <= '1';
				Data_Out <= TxData_In;
			WHEN Hold =>
				Reset_Internal <= '0';
				Trigger_UART <= '0';
				Data_Out <= TxData_In;
				IF TxEnd = '1' THEN
					FS <= Transfer;
				END IF;		
			WHEN Finish =>
				Reset_Internal <= '0';
				Trigger_UART <= '0';
				IF Trigger = '1' THEN
					FS <= Finish;
				ELSE	
					FS <= Idle;
				END IF;
		END CASE;
	END PROCESS;
	--IdleState <= Reset_Emission;
	
END;
  
