transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl {G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl/uart_byte_tx.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl {G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl/uart_tx_top.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl {G:/XiaoMeige_fpga_System/class/class11_uart_tx/rtl/key_filter.v}
vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class11_uart_tx/prj/ip {G:/XiaoMeige_fpga_System/class/class11_uart_tx/prj/ip/issp.v}

vlog -vlog01compat -work work +incdir+G:/XiaoMeige_fpga_System/class/class11_uart_tx/prj/../testbench {G:/XiaoMeige_fpga_System/class/class11_uart_tx/prj/../testbench/uart_byte_tx_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  uart_byte_tx_tb

add wave *
view structure
view signals
run -all
