
-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Finite State Machine (Moore) for ECHO.
-- Triggered by the high signal ECHO, it triggers several entities to calculate 
-- and save the distance measured by HR-SC04. 
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all; 
USE ieee.numeric_std.all;
use ieee.STD_LOGIC_unsigned.all;

-- -------------------------------------------------------------------------
ENTITY FSM_ECHO IS
-- -------------------------------------------------------------------------
PORT(
	Clk   			: IN STD_LOGIC; -- System clock at the rate of 50MHz.
	Reset   			: IN STD_LOGIC; -- System reset 
	Echo				: IN STD_LOGIC; -- Signal echo from HR-SC04
	Tick_Timeout	: IN STD_LOGIC; -- Tick at the rate of 40Hz to wait until timeout.
	Write_Data 		: OUT STD_LOGIC; -- Send a command to save current distance measured to a PIPO register.
	Idle_State	 	: OUT STD_LOGIC -- Indicate whether the current state is 'Idle' / 'Finish'.
);
END FSM_ECHO;


ARCHITECTURE Stuctural OF FSM_ECHO IS

TYPE STATE_TYPE IS (IDLE,MEASURE,TIMEOUT,FINISH);  -- Define the states
SIGNAL PS : STATE_TYPE;    -- State present
SIGNAL FS : STATE_TYPE;    -- State futur

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
	
	
	DETERMINE_FUTURE_STATE : PROCESS(Tick_Timeout,Echo,PS)	
	BEGIN
	CASE PS IS
		WHEN IDLE =>  --Do nothing. Detect echo to start.
			Write_Data <= '0';
			Idle_State <= '1'; 
			
			IF ECHO = '1' THEN	
				FS <= MEASURE; 
			ELSE
				FS <= IDLE; 
			END IF;
		WHEN MEASURE => --Save the measured distance in the register(Permission granted : Write_Data)
			Write_Data <= '1';
			Idle_State <= '0';	
			
			IF ECHO = '0' THEN
				FS <= TIMEOUT;
			ELSIF Tick_TIMEOUT = '1' THEN
				FS <= FINISH;
			ELSE
				FS <= MEASURE;
			END IF;	  
		
		WHEN TIMEOUT =>  -- Timeout. The obstacle is at more than maximum distance.
			Write_Data <= '0';
			Idle_State   <= '0';	
			
			FS <= IDLE;
				
		WHEN FINISH =>	 -- Finished. 
			Write_Data <= '0';
			Idle_State <= '1';	
			
			FS <= IDLE;
		WHEN OTHERS =>
			FS <= IDLE;
		END CASE;
	END PROCESS;
END;
  
