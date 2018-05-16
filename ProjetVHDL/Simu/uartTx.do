vlib work
vcom -93 ..\\Src\\IP_UART\\CounterMod12.vhd
vcom -93 ..\\Src\\IP_UART\\FDiv_Emission.vhd
vcom -93 ..\\Src\\IP_UART\\Register_Tx10bits.vhd
vcom -93 ..\\Src\\IP_UART\\FSM_Emission.vhd
vcom -93 ..\\Src\\IP_UART\\UART_Emission.vhd
vcom -93 UART_TestBench.vhd
vsim -voptargs=+acc work.uart_tb(uart_tx_tb)

add wave  Clk 
add wave  Reset
add wave  Tick104us
add wave  Count12
add wave  WriteData
add wave  Trigger
add wave  TxData_In
add wave  TxDatum_Out
add wave  TxEnd
add wave  Idle_State
add wave  LoopCount

run -a