##########################################################################################################################################
#начинается вторая часть генерации qr-кода: вычисление кодов коррекции ошибок и форматирование сообщения
p2_start:

	#сохранить сохраненный регистр
	addi sp, sp, -20
	sw s1, 0(sp)
	sw s2, 4(sp)
	sw s3, 8(sp)
	sw s4, 12(sp)
	sw ra, 16(sp)

	#получить qr-версию
	la t0, qr_version
	lbu s1, (t0)									#s1: qr-версия

	#получить уровень коррекции ошибок
	la t0, error_correction_level
	lbu s2, (t0)									#s2: уровень коррекции ошибок

	#вычислить адрес правильного адреса разметки и количество кодов коррекции ошибок
	addi t0, s1, -1
	slli t0, t0, 4
	slli t1, s2, 2
	add t2, t1, t0
	la s3, block_partitioning
	add s3, s3, t2									#s3: правильный адрес раздела

	#вычислить количество кодов коррекции ошибок
	addi t0, s1, -1
	slli t0, t0, 2
	add t1, t0, s2
	la s4, number_of_ecls
	add s4, s4, t1
	lbu s4, (s4)									#s4: количество кодов коррекции ошибок

	#начните кодировать сообщение
	add a1, s3, zero
	add a3, s4, zero
	jal ra, p2_encode
	
	#восстановить сохраненный регистр 
	lw s1, 0(sp)
	lw s2, 4(sp)
	lw s3, 8(sp)
	lw s4, 12(sp)
	lw ra, 16(sp)
	addi sp, sp, 20

	#возврат к главному
	jalr zero, 0(ra)
##########################################################################################################################################

	
##########################################################################################################################################

p2_encode:
	

	addi sp, sp, -44
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s3, 8(sp)
	sw s4, 12(sp)
	sw s5, 16(sp)
	sw s7, 20(sp)
	sw s8, 24(sp)
	sw s9, 28(sp)
	sw s10, 32(sp)
	sw s11, 36(sp)
	sw ra, 40(sp)
	

	add s1, zero, a1							
	add s3, zero, a3							
	

	lbu t1, 0(s1)
	lbu t2, 2(s1)
	add s7, t1, t2							
	

	li s8, 0								
	
	
	li s11, 1								
	
	
	p2_encode_loop_groups:
		
		addi s10, s11, -1
		slli s10, s10, 1
		add s10, s1, s10						
		
		
		lbu t1, 0(s10)
		beqz t1, p2_encode_end
		
		
		li s9, 1						
		
	
		p2_encode_loop_blocks:
			
			add a1, zero, s11
			add a2, zero, s9
			lb a3, 0(s1)
			lb a4, 1(s1)
			lb a5, 1(s10)
			jal ra, p2_get_adress_of_message_block
			add s4, a0, zero				
			
			
			add a1, zero, s11
			add a2, zero, s9
			lb a3, 0(s1)
			add a4, s3, zero
			jal ra, p2_get_adress_of_errorcode_block
			add s5, a0, zero				
			
		
			add a1, s8, zero
			add a2, s4, zero
			lbu a3, 1(s1)
			add a4, s7, zero
			lbu a5, 2(s1)
			lbu a6, 1(s10)
			jal ra, p2_zip_to_final_data
			
		
			lb t0, 0(s1)
			add t1, s8, t0 
			add a1, s4, zero
			add a2, s3, zero
			add a3, s5, zero
			lbu a4, 1(s10)
			jal ra, p2_calc_error_correction_code
			
			
			lbu t0, 0(s1)
			lbu t1, 1(s1)
			mul t2, t1, t0
			lbu t0, 2(s1)
			lbu t1, 3(s1)
			mul t3, t1, t0
			add t4, t3, t2
			
		
			add a1, s8, t4
			add a2, s5, zero
			add a3, s3, zero
			add a4, s7, zero
			add a5, s7, zero
			add a6, s3, zero
			jal ra, p2_zip_to_final_data
			
			
			lb t1, 0(s10)
			addi s9, s9, 1
			addi s8, s8, 1	
			ble s9, t1, p2_encode_loop_blocks
			
	
		li, t6, 2
		addi s11, s11, 1
		ble s11, t6, p2_encode_loop_groups
		
	p2_encode_end:

	mul t0, s6, s7
	mul t1, s3, s7
	add t2, t1, t0
	
	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s3, 8(sp)
	lw s4, 12(sp)
	lw s5, 16(sp)
	lw s7, 20(sp)
	lw s8, 24(sp)
	lw s9, 28(sp)
	lw s10, 32(sp)
	lw s11, 36(sp)
	lw ra, 40(sp)
	addi sp, sp, 44
	
	jalr zero, 0(ra)
##########################################################################################################################################



##########################################################################################################################################

p2_zip_to_final_data:
	

	addi sp, sp, -32
	sw, s1, 0(sp)
	sw, s2, 4(sp)
	sw, s3, 8(sp)
	sw, s4, 12(sp)
	sw, s5, 16(sp)
	sw, s6, 20(sp)
	sw, s10, 24(sp)
	sw, s11, 28(sp)
	
								
	add s1, a1, zero									
	add s2, a2, zero								
	add s3, a3, zero									
	add s4, a4, zero									
	add s5, a5, zero									
	add s6, a6, zero									
	

	li t0, FINAL_DATA
	add s11, s1, t0										


	li s10, 0									
	
	sub s11, s11, s4

	p2_zip_to_final_data_loop_full_blocks:
	
		bge s10, s3, p2_zip_to_final_data_loop_full_blocks_end
		
	
		add t0, s2, s10
		lbu t1, (t0)
		

		add s11, s11, s4
		sb t1, (s11)
		

		addi s10, s10, 1
		beq zero, zero, p2_zip_to_final_data_loop_full_blocks

	p2_zip_to_final_data_loop_full_blocks_end:
	

	
	p2_zip_to_final_data_loop_long_blocks:
		
		bge s10, s6, p2_zip_to_final_data_loop_long_blocks_end
		
	
		add t0, s2, s10
		lbu t1, (t0)
		
	
		add s11, s11, s5
		sb t1, (s11)
		
	
		addi s10, s10, 1
		beq zero, zero, p2_zip_to_final_data_loop_long_blocks
		  
	p2_zip_to_final_data_loop_long_blocks_end:  
	
	
	lw, s1, 0(sp)
	lw, s2, 4(sp)
	lw, s3, 8(sp)
	lw, s4, 12(sp)
	lw, s5, 16(sp)
	lw, s6, 20(sp)
	lw, s10, 24(sp)
	lw, s11, 28(sp)
	addi sp, sp, 32
	
	jalr zero, 0(ra)
##########################################################################################################################################


##########################################################################################################################################

p2_get_adress_of_message_block:


	li a0, MESSAGE_CODEWORD_ADDRESS
	
	
	mul t0, a3, a4
	addi a1, a1, -1
	mul t0, t0, a1
	add a0, a0, t0


	addi t1, a2, -1
	mul t1, a5, t1
	add a0, a0, t1
	
	jalr zero, 0(ra)
##########################################################################################################################################


##########################################################################################################################################

p2_get_adress_of_errorcode_block:


	li a0, EC_CODEWORD_ADDRESS
	

	mul t0, a3, a4
	addi a1, a1, -1
	mul t0, t0, a1
	add a0, a0, t0


	addi t1, a2, -1
	mul t1, a4, t1
	add a0, a0, t1
	
	jalr zero, 0(ra)
##########################################################################################################################################


##########################################################################################################################################

p2_calc_error_correction_code:


	addi sp, sp, -44
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp)
	sw s4, 16(sp)
	sw s6, 20(sp)
	sw s7, 24(sp)
	sw s8, 28(sp)
	sw s10, 32(sp)
	sw s11, 36(sp)
	sw ra, 40(sp)
	

	add s1, zero, a1								
	add s2, zero, a2							
	add s3, zero, a3								
	add s4, zero, a4								
	
	
	add a2, zero, s2
	jal ra, p2_get_gpo_adress
	add s11, zero, a0								
	

	add s10, zero, s4
	ble s2, s4, p2_calc_error_correction_code_max_end
	add s10, zero, s2								
	p2_calc_error_correction_code_max_end:
	

	add a1, zero, s3
	add a2, zero, s1
	add a3, zero, s4
	add a4, zero, s10
	jal ra, p2_initialize_ECC
	
	
	add s8, zero, zero								
	

	p2_calc_error_correction_code_loop_outer:
	
		bge s8, s4, p2_calc_error_correction_code_loop_outer_end
	
	
		la t0, i2a
		lbu t1, (s3)
		add t2, t1, t0
		addi t2, t2, -1		
		lbu s7, (t2)								
		

		add s6, zero, zero						
		
	
		p2_calc_error_correction_code_loop_inner:
		
			bgt s6, s10, p2_calc_error_correction_code_loop_inner_end
			
			
			add s0, zero, zero						
			addi t0, s2, 1
			bge s6, t0, p2_calc_error_correction_code_loop_inner_zero
			
			
			add t0, s11, s6
			lbu t1, (t0)
			
			
			add s0, t1, s7
			
			
			li t2, 256
			blt s0, t2, p2_calc_error_correction_code_loop_inner_skip_modulo
			addi s0, s0, -255
			p2_calc_error_correction_code_loop_inner_skip_modulo:
			
			
			la t0, a2i
			add t1, t0, s0
			lbu s0, (t1)
			
			p2_calc_error_correction_code_loop_inner_zero:
			
			add t0, s6, s3
			lbu t1, (t0)
			xor s0, s0, t1
			sb s0, (t0)
			
			
			addi s6, s6, 1
			beq zero, zero, p2_calc_error_correction_code_loop_inner		
			
		p2_calc_error_correction_code_loop_inner_end:
		
	
		add a1, zero, s3
		addi a2, s10, 1
		jal ra, p2_delete_first_byte_and_move
		
		
		addi s8, s8, 1
		beq zero, zero, p2_calc_error_correction_code_loop_outer
			
	p2_calc_error_correction_code_loop_outer_end:
				

	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s6, 20(sp)
	lw s7, 24(sp)
	lw s8, 28(sp)
	lw s10, 32(sp)
	lw s11, 36(sp)
	lw ra, 40(sp)
	addi sp, sp, 44
	
	jalr zero, 0(ra)
##########################################################################################################################################

	
			
##########################################################################################################################################	

p2_get_gpo_adress:

	

	li, t0, 7
	beq a2, t0, p2_gpo7
	li, t0, 10
	beq a2, t0, p2_gpo10
	li, t0, 13
	beq a2, t0, p2_gpo13
	li, t0, 15
	beq a2, t0, p2_gpo15
	li, t0, 16
	beq a2, t0, p2_gpo16
	li, t0, 17
	beq a2, t0, p2_gpo17
	li, t0, 18
	beq a2, t0, p2_gpo18
	li, t0, 20
	beq a2, t0, p2_gpo20
	li, t0, 22
	beq a2, t0, p2_gpo22
	li, t0, 24
	beq a2, t0, p2_gpo24
	li, t0, 26
	beq a2, t0, p2_gpo26
	li, t0, 28
	beq a2, t0, p2_gpo28
	li, t0, 30
	beq a2, t0, p2_gpo30
	

	li a7, 93
	li a0, 42
	ecall
	
	
	p2_gpo7:
		la a0, gpo7
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo10:
		la a0, gpo10
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo13:
		la a0, gpo13
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo15:
		la a0, gpo15
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo16:
		la a0, gpo16
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo17:
		la a0, gpo17
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo18:
		la a0, gpo18
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo20:
		la a0, gpo20
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo22:
		la a0, gpo22
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo24:
		la a0, gpo24
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo26:
		la a0, gpo26
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo28:
		la a0, gpo28
		beq zero, zero, p2_get_gpo_adress_end
	p2_gpo30:
		la a0, gpo30
		beq zero, zero, p2_get_gpo_adress_end
		
		
	p2_get_gpo_adress_end:	
	jalr zero, 0(ra)
##########################################################################################################################################


##########################################################################################################################################

p2_delete_first_byte_and_move:


	addi sp, sp, -12
	sw s1, 0(sp)
	sw s2, 4(sp)
	sw s11, 8(sp)
	

	add s1, zero, a1							
	add s2, zero, a2								


	li s11, 1								
	
	
	ble s2, s11, p2_delete_first_byte_and_move_error
	

	p2_delete_first_byte_and_move_loop:
		
		bge s11, s2, p2_delete_first_byte_and_move_end
		
	
		add t0, s1, s11
		lbu t1, 0(t0)
		sb t1, -1(t0)
		
		
		addi s11, s11, 1
		beq zero, zero, p2_delete_first_byte_and_move_loop	
	p2_delete_first_byte_and_move_end:
		
		
		add t0, s1, s11
		sb zero, -1(t0)
		
	p2_delete_first_byte_and_move_error:
	

	lw s1, 0(sp)
	lw s2, 4(sp)
	lw s11, 8(sp)
	addi sp, sp, 12
	
	jalr zero, 0(ra)
##########################################################################################################################################	
	
	
##########################################################################################################################################

p2_initialize_ECC:


	addi sp, sp, -16
	sw s1, 0(sp)
	sw s2, 4(sp)
	sw s3, 8(sp)
	sw s4, 12(sp)
	sw s11, 16(sp)
	
	
	add s1, zero, a1								
	add s2, zero, a2								
	add s3, zero, a3							
	add s4, zero, a4								


	bgt s3, s4, p2_initialize_ECC_error

	
	li s11, 0									
	
	
	p2_initialize_ECC_copy:
		
		bge s11, s3, p2_initialize_ECC_copy_end
		
		
		add t1, s11, s2
		lbu t2, (t1)
		
	
		add t3, s11, s1
		sb t2, (t3)
		
	
		addi s11, s11, 1
		beq zero, zero, p2_initialize_ECC_copy
	p2_initialize_ECC_copy_end:
	
	
	p2_initialize_ECC_zeros:
		
		bge s11, s4, p2_initialize_ECC_zeros_end
		
		
		add t1, s11, s1
		sb zero, (t1)
		
	
		addi s11, s11, 1
		beq zero, zero, p2_initialize_ECC_zeros	
	p2_initialize_ECC_zeros_end:
	
	
	lw s1, 0(sp)
	lw s2, 4(sp)
	lw s3, 8(sp)
	lw s4, 12(sp)
	lw s11, 16(sp)
	addi sp, sp, 16
	
	
	jalr zero, 0(ra)
	
	p2_initialize_ECC_error:
	
		li a7, 93
		li a0, 40
		ecall
##########################################################################################################################################
