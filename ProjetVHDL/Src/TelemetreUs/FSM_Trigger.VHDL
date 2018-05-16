-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
--
-- *************************************************************************
-- Finite State Machine (Moore) for TRIG.
-- Sends a pulse that lasts 10us to TRIG.
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all; 
USE ieee.numeric_std.all;
use ieee.STD_LOGIC_unsigned.all;

-- -------------------------------------------------------------------------
ENTITY FSM_TRIGGER IS
-- -------------------------------------------------------------------------
PORT(
	Clk				: IN STD_LOGIC; -- System clock at the rate of 50MHz.
	Reset			: IN STD_LOGIC; -- System reset 
	Tick_Trigger	: IN STD_LOGIC; -- Tick at the rate of 100KHz.
	Trigger		: IN STD_LOGIC; -- Trigger FSM.
	Pulse			: OUT STD_LOGIC; -- Pulse signal.
	Idle_State		: OUT STD_LOGIC -- Indicate whether the current state is 'Idle' / 'Finish'.
);
END FSM_TRIGGER;


ARCHITECTURE Stuctural OF FSM_TRIGGER IS
	TYPE STATE_TYPE IS (Idle,Send,Finish);  -- Define the states
 	SIGNAL PS : STATE_TYPE;    -- Present State
 	SIGNAL FS : STATE_TYPE;    -- Future State
    SIGNAL Count : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL Pulse_Internal : STD_LOGIC;
	
BEGIN
	DETERMINE_PRESENT_STATE : PROCESS(Clk,Reset,FS)
    BEGIN
		IF  rising_edge(Clk)  THEN
			IF Reset = '1' THEN
				PS <= Idle;
			ELSE 
				PS <= FS;
			END IF; 
		END IF;
	END PROCESS;
	
	DETERMINE_FUTURE_STATE : PROCESS(Trigger, Tick_Trigger, PS)	
	BEGIN
	CASE PS IS
    WHEN Idle =>  --Do nothing
		Pulse <= '0';
		Idle_State <= '1';
		
		IF Trigger = '0' THEN
			FS <= Idle;
		ELSE 
			FS <= Send;
		END IF;	
		
    WHEN Send => --Pulse is maintained high until the next tick
		Pulse <= '1';
		Idle_State <= '0';
		
		IF Tick_Trigger = '0' THEN
			FS <= Send;
		ELSE 
			FS <= Finish; --Tick detected. End the pulse
		END IF;
    WHEN Finish => --Pulse return at 0. End of FSM. Repeats until the Trigger resets to 0.
		Pulse <= '0';
		Idle_State <= '1';
		
		IF Trigger = '1' THEN
			FS <= Finish;
		ELSE 
			FS <= Idle;
		END IF;	
  WHEN OTHERS =>
			FS <= Idle;
	  END CASE;
	END PROCESS;
    
END;
  
