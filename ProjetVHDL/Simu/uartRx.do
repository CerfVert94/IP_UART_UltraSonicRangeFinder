vlib work
vcom -93 ..\\Src\\IP_UART\\CounterMod19.vhd
vcom -93 ..\\Src\\IP_UART\\FDiv_Reception.vhd
vcom -93 ..\\Src\\IP_UART\\Register_Rx8bits.vhd
vcom -93 ..\\Src\\IP_UART\\FSM_Reception.vhd
vcom -93 ..\\Src\\IP_UART\\UART_Reception.vhd
vcom -93 UART_TestBench.vhd
vsim -voptargs=+acc work.uart_tb(uart_rx_tb)

add wave  Clk 
add wave  Reset 
add wave  Tick52us
add wave  Count19 
add wave  WriteData
add wave  RxDatum_In
add wave  RxDatum_Out
add wave  RxData
add wave  RxEnd
add wave  Idle_State
run -a