-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- Parallel-In, Parallel-out Register (15 bits)
-- *************************************************************************
Library ieee;
use ieee.STD_LOGIC_1164.all;

-- -------------------------------------------------------------------------
ENTITY PIPO_Register IS
-- -------------------------------------------------------------------------
	PORT(
		Clk			: in STD_LOGIC; 	-- System clock at the rate of 50MHz.
		Reset		: in STD_LOGIC;		-- System reset.
		Write_Data	: in STD_LOGIC;		-- Permission to write.
		Data_In		: in STD_LOGIC_VECTOR(14 DOWNTO 0); -- Incoming data (to write).
		Data_Out	: out STD_LOGIC_VECTOR(14 DOWNTO 0) -- Outcoming data (to read).
	);
END PIPO_Register;

ARCHITECTURE behav of PIPO_Register is
SIGNAL Data_Internal : STD_LOGIC_VECTOR(14 DOWNTO 0) := (OTHERS => '0');
BEGIN
  -- Whether permission to write is 1 or 0, output the stored data.
  Data_Out  <= Data_Internal; -- Parallel out.
  

  PROCESS_WRITE : Process(Clk)
    BEGIN
      IF rising_edge(Clk) THEN  
			IF(Reset = '1') THEN -- At reset, the output data will be composed of only 1s.
				Data_Internal <= (OTHERS => '1');
			ELSE
				If(Write_Data = '1') THEN  -- Permission to write granted
					Data_Internal <= Data_In;  -- Parallel in.
				END IF;
			END IF;
		END IF;
    END PROCESS;
END behav;