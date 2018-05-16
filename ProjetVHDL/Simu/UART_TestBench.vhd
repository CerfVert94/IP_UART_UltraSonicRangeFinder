-- KO Roqyun / FAYE Mohamet Cherif / RAHARISOA Timothe
-- EISE3 - Projet VHDL 
-- IP UART + Telemetre Ultrason
-- 
-- *************************************************************************
-- UART Testbench 
-- Negative logic is used.
-- *************************************************************************

  use STD.TEXTIO.all;
Library IEEE;
  use IEEE.std_logic_TEXTIO.all;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.STD_LOGIC_ARITH.ALL;
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  
entity UART_TB is
end UART_TB ;



ARCHITECTURE UART_RX_TB OF UART_TB  is 

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

COMPONENT Register_Rx8Bits IS 
PORT(
	Clk			: in STD_LOGIC;
	Reset		: in STD_LOGIC;
	Tick		: in STD_LOGIC;
	WriteData 	: in STD_LOGIC;
	Datum_In 	: in STD_LOGIC;
	Data_Out 	: out STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;



SIGNAL Clk : STD_LOGIC;
SIGNAL Reset : STD_LOGIC;
SIGNAL Tick52us : STD_LOGIC;
SIGNAL Count19 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL WriteData : STD_LOGIC;
SIGNAL RxDatum_In : STD_LOGIC := '1';
SIGNAL RxDatum_Out : STD_LOGIC;
SIGNAL RxData : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL PrevRxData : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
SIGNAL RxEnd : STD_LOGIC;
SIGNAL Idle_State : STD_LOGIC;
SIGNAL LoopCount : STD_LOGIC_VECTOR(1 downto 0) := "00";

BEGIN
  
  CLK <= '1' after 10 ns when CLK = '0' else
         '0' after 10 ns;

  UART_RX_PROCESS : process 
  variable L : line;
  
  procedure TestError (Count : STD_LOGIC_VECTOR(4 downto 0); Data : STD_LOGIC_VECTOR(7 downto 0)) is
  begin
	 write(L, now); 
  if(Count19 = Count) then	
   write (L, Ht & string'("Count Pass : "));
	 hwrite(L, Count19);
   write (L, string'("="));
	 hwrite(L, Count);
 	 writeline(output,L);
  else
   write (L, Ht & string'("Count Failure : "));
	 hwrite(L, Count19);
   write (L, string'("!="));
	 hwrite(L, Count);
 	 writeline(output,L);
    assert false report string'("Count error : ") severity failure; 
  end if;

	 write(L, now); 
  if(RxData = Data) then 
   write (L, Ht & string'("Data Pass : "));
	 hwrite(L, RxData);
   write (L, string'("="));
	 hwrite(L, Data);
 	 writeline(output,L);
  else
   write (L, Ht & string'("Data Failure : "));
	 hwrite(L, RxData);
   write (L, string'("!="));
	 hwrite(L, Data);
 	 writeline(output,L);
   assert false report string'("Output error") severity failure; 
  end if;
  
	 write(L, now); 
 	 writeline(output,L);
	 
  end procedure TestError;
  
  BEGIN 
  wait for 504200 ns; --start : 10010101
	write(L, now);
	write(L, Ht&string'("Testing reception for 10010101 at a randomly chosen moment."));
  writeline(output,L);
    
  RxDatum_In <= '0'; wait for 104020 ns; --start
  TestError("00001","0" & PrevRxData(7 downto 1));
  RxDatum_In <= '1'; wait for 104020 ns; --b0
  TestError("00011","10" & PrevRxData(7 downto 2));
  RxDatum_In <= '0'; wait for 104020 ns; --b1
  TestError("00101","010" & PrevRxData(7 downto 3));
  RxDatum_In <= '1'; wait for 104020 ns; --b2
  TestError("00111","1010" & PrevRxData(7 downto 4));
  RxDatum_In <= '0'; wait for 104020 ns; --b3
  TestError("01001","01010" & PrevRxData(7 downto 5));
  RxDatum_In <= '1'; wait for 104020 ns; --b4
  TestError("01011","101010" & PrevRxData(7 downto 6));
  RxDatum_In <= '0'; wait for 104020 ns; --b5
  TestError("01101","0101010" & PrevRxData(7 downto 7));
  RxDatum_In <= '0'; wait for 104020 ns; --b6
  TestError("01111","00101010");
  RxDatum_In <= '1'; wait for 104020 ns; --b7
  TestError("00000","10010101");
  RxDatum_In <= '1'; wait for 104020 ns; --Stop
  TestError("00000","10010101");
 	  
	wait for 1 ms; --wait 
	write(L, now);
	write(L, Ht&string'("Check if the RxData is modified. If yes, severe error and test will stop."));
  writeline(output,L);
  TestError("00000","10010101");
  PrevRxData<="10010101";
    
	write(L, now);
	write (L, Ht&string'("Testing reception for 00001111 at a randomly chosen moment"));
  wait for 250200 ns; 
  RxDatum_In <= '0'; wait for 104020 ns; --start
  TestError("00001","0" & PrevRxData(7 downto 1));
  RxDatum_In <= '1'; wait for 104020 ns; --b0
  TestError("00011","10" & PrevRxData(7 downto 2));
  RxDatum_In <= '1'; wait for 104020 ns; --b1
  TestError("00101","110" & PrevRxData(7 downto 3));
  RxDatum_In <= '1'; wait for 104020 ns; --b2
  TestError("00111","1110" & PrevRxData(7 downto 4));
  RxDatum_In <= '1'; wait for 104020 ns; --b3
  TestError("01001","11110" & PrevRxData(7 downto 5));
  RxDatum_In <= '0'; wait for 104020 ns; --b4
  TestError("01011","011110" & PrevRxData(7 downto 6));
  RxDatum_In <= '0'; wait for 104020 ns; --b5
  TestError("01101","0011110" & PrevRxData(7 downto 7));
  RxDatum_In <= '0'; wait for 104020 ns; --b6
  TestError("01111","00011110");
  RxDatum_In <= '0'; wait for 104020 ns; --b7
  TestError("00000","00001111");
  RxDatum_In <= '1'; wait for 104020 ns; --Stop
  TestError("00000","00001111");
	wait for 1 ms; --wait 
  wait for 134211 ns; 
	write(L, now);
	write(L, Ht&string'("Check if the RxData is modified. If yes, severe error and test will stop."));
  writeline(output,L);
  TestError("00000","00001111"); -- 
  PrevRxData<="00001111";
  
 	write(L, now);
	write (L, Ht&string'("Testing reception for 11110000 at a randomly chosen moment"));
  wait for 250200 ns; 
  RxDatum_In <= '0'; wait for 104020 ns; --start
  TestError("00001","0" & PrevRxData(7 downto 1));
  RxDatum_In <= '0'; wait for 104020 ns; --b0
  TestError("00011","00" & PrevRxData(7 downto 2));
  RxDatum_In <= '0'; wait for 104020 ns; --b1
  TestError("00101","000" & PrevRxData(7 downto 3));
  RxDatum_In <= '0'; wait for 104020 ns; --b2
  TestError("00111","0000" & PrevRxData(7 downto 4));
  RxDatum_In <= '0'; wait for 104020 ns; --b3
  TestError("01001","00000" & PrevRxData(7 downto 5));
  RxDatum_In <= '1'; wait for 104020 ns; --b4
  TestError("01011","100000" & PrevRxData(7 downto 6));
  RxDatum_In <= '1'; wait for 104020 ns; --b5
  TestError("01101","1100000" & PrevRxData(7 downto 7));
  RxDatum_In <= '1'; wait for 104020 ns; --b6
  TestError("01111","11100000");
  RxDatum_In <= '1'; wait for 104020 ns; --b7
  TestError("00000","11110000");
  RxDatum_In <= '1'; wait for 104020 ns; --Stop
  TestError("00000","11110000");
	wait for 1 ms; --wait 
  wait for 134211 ns; 
	write(L, now);
	write(L, Ht&string'("Check if the RxData is modified. If yes, severe error and test will stop."));
  writeline(output,L);
  TestError("00000","11110000"); 
  PrevRxData<="11110000";
  LoopCount <= LoopCount + 1;
  if( LoopCount = "11") then
	  write(L, now);
    write (L, string'("Received data are all valid.")&HT);
	  write(L, now);
    write (L, string'("End of Simulation"&HT));
    writeline (output,L);
    wait;
  end if;
  END PROCESS;
  
  
C0 : COMPONENT FDiv_Reception PORT MAP(
	Clk		=> Clk,
	Reset	=> Idle_State,
	Tick	=> Tick52us);


C1 : COMPONENT CounterMod19 PORT MAP(
	Clk		=> Clk,
	Reset	=> Idle_State,
	Tick	=> Tick52us,
	Count	=> Count19);

C2: COMPONENT FSM_Reception PORT MAP(
		Clk			=> Clk,
		Reset		=> Reset,
		Tick		=> Tick52us,
		RxDatum_In	=> RxDatum_In,
		Count		=> Count19,
		WriteData 	=> WriteData,
		RxEnd 		=> RxEnd,
		RxDatum_Out	=> RxDatum_Out,
		Idle_State 	=> Idle_State);
		
C3: COMPONENT Register_Rx8Bits PORT MAP(
		Clk			=> Clk,
		Reset		=> Reset,
		Tick		=> Tick52us,
		WriteData 	=> WriteData,
		Datum_In 	=> RxDatum_Out,
		Data_Out 	=> RxData);

END UART_RX_TB;


ARCHITECTURE UART_TX_TB OF UART_TB  is 

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

SIGNAL Clk : STD_LOGIC;
SIGNAL Reset : STD_LOGIC;
SIGNAL Tick104us : STD_LOGIC;
SIGNAL Count12 : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL WriteData : STD_LOGIC;
SIGNAL Trigger : STD_LOGIC := '0';
SIGNAL TxData_In : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL TxDatum_Out : STD_LOGIC;
SIGNAL TxEnd : STD_LOGIC;
SIGNAL Idle_State : STD_LOGIC;
SIGNAL LoopCount : STD_LOGIC_VECTOR(1 downto 0) := "00";


BEGIN
  
  UART_RX_PROCESS : process 
   variable L : line;
  procedure TestError (Count : STD_LOGIC_VECTOR(3 downto 0); Datum : STD_LOGIC) is
  begin
	 write(L, now); 
  if(Count12 = Count) then	
   write (L, Ht & string'("Count Pass : "));
	 hwrite(L, Count12);
   write (L, string'("="));
	 hwrite(L, Count);
 	 writeline(output,L);
  else
   write (L, Ht & string'("Count Failure : "));
	 hwrite(L, Count12);
   write (L, string'("!="));
	 hwrite(L, Count);
 	 writeline(output,L);
    assert false report string'("Count error : ") severity failure; 
  end if;

	 write(L, now); 
  if(TxDatum_Out = Datum) then 
   write (L, Ht & string'("Datum Pass : "));
	 write(L, TxDatum_Out);
   write (L, string'("="));
	 write(L, datum);
 	 writeline(output,L);
  else
   write (L, Ht & string'("Datum Failure : "));
	 write(L, TxDatum_Out);
   write (L, string'("!="));
	 write(L, datum);
 	 writeline(output,L);
   assert false report string'("Output error") severity failure; 
  end if;
  
	 write(L, now); 
 	 writeline(output,L);
	 
  end procedure TestError;
  
  BEGIN 
    
	 write(L, now);
	 write (L, Ht&string'("Testing emission for 10101100."));
  --if(rising_edge(clk)) then
    TxData_In <= "10101100"; 
    Trigger <= '1';
    wait for 20 ns;
    Trigger <= '0';
    TestError("0000",'1');  wait for 105 us; --Idle
    TestError("0001",'0');  wait for 105 us; --start
    TestError("0010",'0');  wait for 105 us; --b0
    TestError("0011",'0');  wait for 105 us; --b1
    TestError("0100",'1');  wait for 105 us; --b2
    TestError("0101",'1');  wait for 105 us; --b3
    TestError("0110",'0');  wait for 105 us; --b4
    TestError("0111",'1');  wait for 105 us; --b5
    TestError("1000",'0');  wait for 105 us; --b6
    TestError("1001",'1');  wait for 105 us; --b7
    TestError("1010",'1');  wait for 105 us; --stop
    wait for 150 us;
    
    
    TxData_In <= "10101111"; 
	 write(L, now);
	 write (L, Ht&string'("Testing emission for 10101111."));
    Trigger <= '1';
    wait for 20 ns;
    Trigger <= '0';
    TestError("0000",'1');  wait for 105 us; --Idle
    TestError("0001",'0');  wait for 105 us; --start
    TestError("0010",'1');  wait for 105 us; --b0
    TestError("0011",'1');  wait for 105 us; --b1
    TestError("0100",'1');  wait for 105 us; --b2
    TestError("0101",'1');  wait for 105 us; --b3
    TestError("0110",'0');  wait for 105 us; --b4
    TestError("0111",'1');  wait for 105 us; --b5
    TestError("1000",'0');  wait for 105 us; --b6
    TestError("1001",'1');  wait for 105 us; --b7
    TestError("1010",'1');  wait for 105 us; --stop
    wait for 20 ns;
    
    TxData_In <= "00110011"; 
     write(L, now);
	 write (L, Ht&string'("Testing emission for 00110011."));
    Trigger <= '1';
    wait for 20 ns;
    Trigger <= '0';
    TestError("0000",'1');  wait for 105 us; --Idle
    TestError("0001",'0');  wait for 105 us; --start
    TestError("0010",'1');  wait for 105 us; --b0
    TestError("0011",'1');  wait for 105 us; --b1
    TestError("0100",'0');  wait for 105 us; --b2
    TestError("0101",'0');  wait for 105 us; --b3
    TestError("0110",'1');  wait for 105 us; --b4
    TestError("0111",'1');  wait for 105 us; --b5
    TestError("1000",'0');  wait for 105 us; --b6
    TestError("1001",'0');  wait for 105 us; --b7
    TestError("1010",'1');  wait for 105 us; --stop
    wait for 225 us;
    LoopCount <= LoopCount + 1;
   if( LoopCount = "11") then
    write (L, now);
    write (L, string'(" All emissions are correctly done."));
    writeline (output,L);
    write (L, now);
    write (L, string'(" End of Simulation")&HT);
    writeline (output,L);
    wait;
  end if;
  END PROCESS;
  
  CLK <= '1' after 10 ns when CLK = '0' else
         '0' after 10 ns;
  
  C0: COMPONENT FDiv_Emission PORT MAP(
		Clk	=> Clk,
		Reset	=> Idle_State,
		Tick	=> Tick104us);
	C1: COMPONENT CounterMod12 PORT MAP(
		Clk	=> Clk,
		Reset	=> Idle_State,
		Tick	=> Tick104us,
		Count	=> Count12);
	C2: COMPONENT FSM_Emission PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick104us,
		Trigger		=> Trigger,
		Count			=> Count12,
		WriteData	=> WriteData,
		Idle_State 	=> Idle_State,
		TxEnd 			=> TxEnd );
	C3: COMPONENT Register_Tx10Bits PORT MAP(
		Clk			=> Clk,
		Reset			=> Reset,
		Tick			=> Tick104us,
		WriteData	=> WriteData,
		Data_In		=> TxData_In,
		Datum_Out	=> TxDatum_Out);

END UART_TX_TB;

