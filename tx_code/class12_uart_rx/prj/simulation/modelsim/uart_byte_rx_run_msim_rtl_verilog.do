transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class12_uart_rx/rtl {G:/XiaoMeige_fpga_System/class/class12_uart_rx/rtl/uart_byte_rx.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class12_uart_rx/rtl {G:/XiaoMeige_fpga_System/class/class12_uart_rx/rtl/uart_rx_top.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/ip {G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/ip/issp.v}

vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/../testbench {G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/../testbench/uart_byte_rx_tb.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/../rtl {G:/XiaoMeige_fpga_System/class/class12_uart_rx/prj/../rtl/uart_byte_tx.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  uart_byte_rx_tb

add wave *
view structure
view signals
run -all
