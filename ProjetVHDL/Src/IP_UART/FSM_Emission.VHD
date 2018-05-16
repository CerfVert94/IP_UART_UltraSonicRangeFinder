-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Finite State Machine for UART Emission.
-- *************************************************************************

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all; 
USE ieee.numeric_std.all;

ENTITY FSM_Emission IS PORT(
Clk : IN STD_LOGIC;	-- System Clock
Reset : IN STD_LOGIC; -- Reset
Tick : IN STD_LOGIC; -- Tick 104.17us.
Trigger : IN STD_LOGIC; -- Activates the FSM.
Count : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Counter
WriteData : OUT STD_LOGIC; --Permission to write into register.
Idle_State : OUT STD_LOGIC; -- Indicate whether the FSM is idle.
TxEnd : OUT STD_LOGIC -- Indicate the end of transmission.
);
END FSM_Emission;


ARCHITECTURE structural OF FSM_Emission IS

TYPE STATE_TYPE IS (Idle,Start,Transfer,Finish);-- Define the states
SIGNAL PS : STATE_TYPE;--Present State.

BEGIN
	
	SET_PS: PROCESS (Clk,Reset,PS,Tick,Trigger,Count)
	BEGIN
		IF Rising_Edge(Clk) THEN
			IF(Reset = '1') THEN
				PS <= Idle;
			ELSE
				CASE PS IS
					WHEN Idle => --Idle : Do nothing
						Idle_State <= '1';
						WriteData <= '0';
						TxEnd<='0';
						IF(Trigger = '1') THEN
							PS <= Start;
						ELSE
							PS <= Idle;
						END IF;
					WHEN Start =>  --Start : Grant the permission to write into the register
						Idle_State <= '0';
						WriteData <= '1';
						TxEnd<='0';
						IF(Tick = '1') THEN 
							PS <= Transfer;
						END IF;
					WHEN Transfer => --Transfer : Remove the permission to write and repeat up until count 10 (10 * 104.17 us).
						Idle_State <= '0';
						WriteData <= '0';
						TxEnd<='0';
						IF(Tick = '1') THEN 
							IF(Count = "1010")THEN --Count 10 => Finish
								PS <= Finish;
							ELSE
								PS <= Transfer;
							END IF;
						END IF;
				
					WHEN Finish => --Finish : Signal the end of transfer and repeat until Trigger is reset to 0.
						Idle_State <= '1';
						WriteData <= '0';
						TxEnd <= '1';
						IF(Trigger = '0') THEN
							PS <= Idle;
						ELSE
							PS <= Finish;
						END IF;
		
					WHEN OTHERS => --Error
						Idle_State <= '1';
						WriteData <= '0';
						PS <= Idle;
					END CASE;
				END IF;
			END IF;
	END PROCESS SET_PS;
	
	
END structural;


