; --- sram memory ---
.dseg
.org	sram_start

line_buffer:
	.byte	buffer_size
; ---