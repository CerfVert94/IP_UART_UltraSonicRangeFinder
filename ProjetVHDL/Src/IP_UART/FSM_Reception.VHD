-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Finite State Machine for UART Reception.
-- *************************************************************************
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all; 
USE ieee.numeric_std.all;
USE ieee.STD_LOGIC_unsigned.all;


ENTITY FSM_Reception IS PORT(
	Clk			: IN STD_LOGIC;-- System Clock
	Reset			: IN STD_LOGIC; --Reset
	Tick			: IN STD_LOGIC;-- Tick 52.8us.
	RxDatum_In		: IN STD_LOGIC; -- Datum coming from the PC
	Count			: IN STD_LOGIC_VECTOR(4 DOWNTO 0); --Counter
	WriteData 	: OUT STD_LOGIC; -- Permission to write into a register
	RxEnd 		: OUT STD_LOGIC; -- Signals the end of transmission
	RxDatum_Out	: OUT STD_LOGIC; -- Datum to store in the register
	Idle_State	: OUT STD_LOGIC -- Indicate the state of FSM
);
END FSM_Reception;


ARCHITECTURE structural OF FSM_Reception IS

TYPE STATE_TYPE IS (Idle,Start,Skip,Transfer, Finish);-- Define the states
SIGNAL PS : STATE_TYPE;-- Present state
BEGIN
	SET_PS: PROCESS (Clk,PS,Tick,RxDatum_In,Count)
	BEGIN
		IF Rising_Edge(Clk) THEN
			IF(Reset = '1') THEN
				PS <= Idle;
			ELSE
				CASE PS IS
					WHEN Idle => -- Idle state :  nothing
						WriteData <= '0';
						RxDatum_Out <= '0';
						RxEnd <= '0';
						Idle_State <= '1';
			
						IF(RxDatum_In = '0') THEN
							PS <= Start;
						ELSE
							PS <= Idle;
						END IF;
				WHEN Start => -- Start state : grant permission to write a start bit into the register.
					WriteData <= '1';
					RxDatum_Out <= '0';
					RxEnd <= '0';
					Idle_State <= '0';
			
					IF(Tick = '1') THEN
						PS <= Skip;
					ELSE
						PS <= Start;
					END IF;
				WHEN Skip => -- Wait : Do nothing
					WriteData <= '0';
					RxDatum_Out <= RxDatum_In;
					RxEnd <= '0';
					Idle_State <= '0';
			
					IF(Tick = '1') THEN
						PS<=Transfer;
					ELSE
						PS<=Skip;
					END IF;
				WHEN Transfer => -- Transfer : grant a permission write RxDatum_In into the register
					WriteData <= '1';
					RxDatum_Out <= RxDatum_In;
					RxEnd <= '0';
					Idle_State <= '0'; 
			
					IF(Tick = '1') THEN
						IF(Count = "10000") THEN --Counter reaches 16, finish. If not, back to skip.
							PS<=Finish; 
						ELSE
							PS<=Skip;
						END IF;
					ELSE
						PS<=Transfer;
					END IF; 
				WHEN Finish => -- Finish : Loop until stop bit received.
					WriteData <= '0';
					RxDatum_Out <= RxDatum_In;
					RxEnd <= '1';
					Idle_State <= '1'; 
			
					IF(RxDatum_In = '0') THEN
						PS <= Finish;
					ELSE
						PS <= Idle;
					END IF;
				WHEN OTHERS =>
					PS <= Idle;
				END CASE;
	
			END IF;
		END IF;
	END PROCESS SET_PS;


END structural;

