
draw:
	
	addi sp, sp, -88
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp)
	sw s4, 16(sp)
	sw s5, 20(sp)
	sw s6, 24(sp)
	sw s7, 28(sp)
	sw s8, 32(sp)
	sw s9, 36(sp)
	sw s10, 40(sp)
	sw s11, 44(sp)
	sw ra, 48(sp)
	
	
	
	
	addi s1, zero, 7
	la s2, qr_version
	lb s2, 0(s2) 
	blt s2, s1 draw_save_version_infos_pass
		
		addi s3, s2, -7
		
		slli s3, s3, 2
		la s0, versions_infos
		add s0, s3, s0
		
		lw s4, 0(s0)
		
		sw s4, 52(sp)
	draw_save_version_infos_pass:
	
	
	
	
	la s0, error_correction_level
	lb s0, 0(s0)

	slli s0, s0, 4
	

	addi s1, zero, 8
	addi s2, zero, 0 
	addi s3, sp, 56 
	

	la s4, format_infos
	add s4, s0, s4
	draw_get_format_infos_loop:
	
		lh s5, 0(s4)
		sh s5, 0(s3)
		
	
		addi, s4, s4, 2
	
		addi, s3, s3, 2
		
		
		addi, s2, s2, 1
		blt s2, s1, draw_get_format_infos_loop
		
	
	

	la s0, qr_version
	lb s0, 0(s0)

	addi s0, s0, -1
	addi s1, zero, 7
	mul s0, s0, s1
	

	addi s1, zero, 7
	addi s2, zero, 0 
	addi s3, sp, 72 
	

	la s4, align_positions
	add s4, s0, s4
	draw_alignment_pattern_loop:
		lb s5, 0(s4)
		sb s5, 0(s3)
		
	
		addi, s4, s4, 1
	
		addi, s3, s3, 1
		
	
		addi s2, s2, 1
		blt s2, s1, draw_alignment_pattern_loop
	
	
	

	la s0, qr_version
	lb s0, 0(s0)
	sb s0, 79(sp)
	
	
	
	
	la s0, error_correction_level
	lb s0, 0(s0)
	sb s0, 80(sp)
	
	
	li a1, 0xFeFeFe
	jal ra, clear_screen
	

	lb a1, 79(sp)
	jal ra, get_module_size

	addi, s0, zero, 0
	beq s0, a0, end

	sw a0, 84(sp)
	
	
	lb s0, 79(sp)
	addi s0, s0, -1
	addi s1, zero, 4
	mul s1, s1, s0
	addi s1, s1, 21
	lw s2, 84(sp)
	mul s1, s1, s2

	mv a1, s1
	li a2, 0
	li a3, DISPLAY_WIDTH
	li a4, DISPLAY_HEIGHT
	li a5, 0xffffff
	jal ra, draw_rectangle

	li a1, 0
	mv a2, s1
	li a3, DISPLAY_WIDTH
	li a4, DISPLAY_HEIGHT
	li a5, 0xffffff
	jal ra, draw_rectangle
	
	
	lb s1, 79(sp)
	addi s1, s1, -1
	slli s1, s1, 2
	addi s1, s1, 13
	lw s2, 84(sp)
	addi s3, s1, 1

	lw s0, 84(sp)

	addi a1, zero, 0
	addi a2, zero, 0
	slli a3, s0, 3
	li a4, 0xFFFFFF
	jal ra, draw_square

	addi a1, zero, 0
	addi a2, zero, 0
	lw a3, 84(sp)
	jal ra, draw_finder_pattern

	mul a1, s1, s2
	addi a2, zero, 0
	slli a3, s0, 3
	li a4, 0xFFFFFF
	jal ra, draw_square
	
	mul a1, s3, s2
	addi a2, zero, 0
	lw a3, 84(sp)
	jal ra, draw_finder_pattern

	addi a1, zero, 0
	mul a2, s1, s2
	slli a3, s0, 3
	li a4, 0xFFFFFF
	jal ra, draw_square

	addi a1, zero, 0
	mul a2, s3, s2
	lw a3, 84(sp)
	jal ra, draw_finder_pattern
	

	addi a1, sp, 72
	lw a2, 84(sp)
	jal ra, alignment_pattern
	

	lw a1, 84(sp)
	lb a2, 79(sp)
	jal ra, timing_pattern
	

	lw a1, 84(sp)
	lb a2, 79(sp)
	jal ra, reserve_format_info_space
	

	lw a1, 84(sp)
	lb a2, 79(sp)
	jal ra, single_dark_module
	

	lw a1, 84(sp)
	lb a2, 79(sp)
	lw a3, 52(sp)
	jal ra, place_version_infos
	

	li s3, 0x7FFFFFFF
	addi s5, zero, 0 
	addi s4, zero, 0 
	
	draw_loop_through_masks:
	
		lw a1, 84(sp)
		lb a2, 79(sp)
		li a3, FINAL_DATA
		jal ra, place_data
	
		
		lw a1, 84(sp)
		lb a2, 79(sp)
		mv a3, s4
		jal ra, mask_data
	
	
		lw a1, 84(sp)
		lb a2, 79(sp)
		mv a3, s4
		addi a4, sp, 56 
		jal ra, write_format_infos
	
	
		lw a1, 84(sp)
		lb a2, 79(sp)
		jal ra, calc_penalty
		
		bge a0, s3, draw_loop_through_masks_skip
			mv s3, a0
			mv s5, s4
		draw_loop_through_masks_skip:
	
		addi s4, s4, 1
		addi s6, zero, 8
		blt s4, s6, draw_loop_through_masks
	

	addi s6, zero, 7
	beq s6, s5, draw_skip_redraw_of_data
		lw a1, 84(sp)
		lb a2, 79(sp)
		li a3, FINAL_DATA
		jal ra, place_data
	
		lw a1, 84(sp)
		lb a2, 79(sp)
		mv a3, s5
		jal ra, mask_data
	
		lw a1, 84(sp)
		lb a2, 79(sp)
		mv a3, s5
		addi a4, sp, 56 
		jal ra, write_format_infos
	draw_skip_redraw_of_data:
	

	lw a1, 84(sp)
	lb a2, 79(sp)
	jal ra, draw_final_qr
	
	end:
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)
	lw s6, 24(sp)
	lw s7, 28(sp)
	lw s8, 32(sp)
	lw s9, 36(sp)
	lw s10, 40(sp)
	lw s11, 44(sp)
	lw ra, 48(sp)
	addi sp, sp, 88
	ret


get_module_size:

	addi sp, sp, -20
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp)
	sw a1, 16(sp)
	

	mv s0, a1
	
	
	li s1, 4
	addi s0, s0, -1
	mul s0, s0, s1
	addi s0, s0, 21
	li s1, DISPLAY_WIDTH
	li s2, DISPLAY_HEIGHT
	
	
	blt s1, s2, get_module_size_side_if
		mv s3, s2
		j get_module_size_side_both
	get_module_size_side_if:
		mv s3, s1
	get_module_size_side_both:
	

	div a0, s3, s0
	

	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw a1, 16(sp)
	addi sp, sp 20
	
	ret


draw_finder_pattern:
	
	addi sp, sp, -24
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	sw a1, 12(sp)
	sw a2, 16(sp)
	sw a3, 20(sp)
	

	addi, s0, zero, 7
	mul s0, a3, s0

	mv a1, a1
	mv a2, a2
	mv a3, s0
	li a4, 0x000000
	jal ra, draw_square
	
	lw a1, 12(sp)
	lw a2, 16(sp)
	lw a3, 20(sp)
	


	addi, s0, zero, 5
	mul s0, a3, s0

	add a1, a1, a3
	add a2, a2, a3
	mv a3, s0
	li a4, 0xFFFFFF
	jal ra, draw_square

	lw a1, 12(sp)
	lw a2, 16(sp)
	lw a3, 20(sp)
	


	addi, s0, zero, 3
	mul s0, a3, s0

	addi, s1, zero, 2
	mul s1, s1, a3

	add a1, a1, s1
	add a2, a2, s1
	mv a3, s0
	li a4, 0x000000
	jal ra, draw_square

	lw a1, 12(sp)
	lw a2, 16(sp)
	lw a3, 20(sp)
	

	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	lw a1, 12(sp)
	lw a2, 16(sp)
	lw a3, 20(sp)
	addi sp, sp, 24
	
	ret


alignment_pattern:
	addi sp, sp, -52
	sw a1, 0(sp)
	sw ra, 4(sp)
	sw a2, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s5, 32(sp)
	sw s6, 36(sp)
	sw s7, 40(sp)
	sw s8, 44(sp)
	sw s9, 48(sp)
	
	addi s0, zero, 7 
	addi s6, zero, 2 
	

	addi s1, zero, 0 
	alignment_pattern_dim1:
		addi s2, zero, 0 
		alignment_pattern_dim2:
		
			
			add s8, a1, s1
			add s9, a1, s2
		
			lb s8, 0(s8)
			andi s8, s8, 0xFF 
			lb s9, 0(s9)
			andi s9, s9, 0xFF
			
			beq s8, zero, alignment_pattern_dim1_end
			beq s9, zero, alignment_pattern_dim1_end
		
		
			addi s4, s1, -2 
			alignment_pattern_dim3:
				addi s5, s2, -2 
				alignment_pattern_dim4:
				
				
					
					add a1, s8, s4
					add a2, s9, s5
					lw a3, 8(sp)
					jal ra, get_module_color
					lw a1, 0(sp)
					lw a2, 8(sp)
					
		
					li s7, 0x00fefefe
					bne s7, a0, alignment_pattern_draw_end
					
			
					addi, s5, s5, 1
					blt s5, s6, alignment_pattern_dim4
				
			
				addi, s4, s4, 1
				blt s4, s6, alignment_pattern_dim3
				
	
			lw s4, 8(sp)
			addi a1, s8, -2
			mul a1, a1, s4
			addi a2, s9, -2
			mul a2, a2, s4
			addi s5, zero, 5
			mul a3, s5, s4
			li a4, 0x000000
			jal ra, draw_square
			lw a1, 0(sp)
			lw a2, 8(sp)
			
		
			lw s4, 8(sp)
			addi a1, s8, -1
			mul a1, a1, s4
			addi a2, s9, -1
			mul a2, a2, s4
			addi s5, zero, 3
			mul a3, s5, s4
			li a4, 0xffffff
			jal ra, draw_square
			lw a1, 0(sp)
			lw a2, 8(sp)
			
		
			lw s4, 8(sp)
			mv a1, s8
			mul a1, a1, s4
			mv a2, s9
			mul a2, a2, s4
			mv a3, s4
			li a4, 0x000000
			jal ra, draw_square
			lw a1, 0(sp)
			lw a2, 8(sp)	
				
			
			alignment_pattern_draw_end:
		
		
			addi s2, s2, 1
		
			add s3, s2, a1
			lb s3, 0(s3)
			beq s3, zero, alignment_pattern_dim2_end
			blt s2, s0, alignment_pattern_dim2
		alignment_pattern_dim2_end:
			
		
		addi s1, s1, 1
	
		add s3, s1, a1
		lb s3, 0(s3)
		beq s3, zero, alignment_pattern_dim1_end
		blt s1, s0, alignment_pattern_dim1
	alignment_pattern_dim1_end:

	lw a1, 0(sp)
	lw ra, 4(sp)
	lw a2, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s5, 32(sp)
	lw s6, 36(sp)
	lw s7, 40(sp)
	lw s8, 44(sp)
	lw s9, 48(sp)
	addi sp, sp, 52
	ret

	
get_module_color:
	addi sp, sp, -32
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw ra, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	
	
	
	mul s1, a2, a3
	li s2, DISPLAY_WIDTH
	mul s1, s1, s2
	slli s1, s1, 2
	
	mul s2, a1, a3
	slli s2, s2, 2
	add s3, s2, s1
	
	
	li s4, DISPLAY_ADDRESS
	add s3, s3, s4
	lw a0, 0(s3)

	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw ra, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	addi sp, sp, 32
	ret
	

timing_pattern:
	addi sp, sp, -36
	sw a1, 0(sp)
	sw ra, 4(sp)
	sw a2, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s7, 32(sp)
	

	addi s1, zero, 6

	addi s2, a2, -1
	slli s2, s2, 2
	addi s2, s2, 13
	
	addi s3, zero, 8
	
	
	li s4, 0x000000
	
	timing_pattern_loop:
		
		
		mv a3, a1
		mv a1, s1
		mv a2, s3
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a2, 8(sp)
					
	
		li s7, 0x00fefefe
		bne s7, a0, timing_pattern_skip_draw_v
		
	
		mv a3, a1
		mul a1, s1, a3
		mul a2, s3, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		timing_pattern_skip_draw_v:
		
	
		mv a3, a1
		mv a1, s3
		mv a2, s1
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a2, 8(sp)
					
	
		li s7, 0x00fefefe
		bne s7, a0, timing_pattern_skip_draw_h
		
	
		mv a3, a1
		mul a1, s3, a3
		mul a2, s1, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		timing_pattern_skip_draw_h:
		
	
		li s0, 0xFFFFFF
		xor s4, s4, s0
		
	
		addi s3, s3, 1
		blt s3, s2, timing_pattern_loop
	
	lw a1, 0(sp)
	lw ra, 4(sp)
	lw a2, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s7, 32(sp)
	addi sp, sp, 36
	ret


reserve_format_info_space:
	addi sp, sp, -32
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	

	li s4, 0xfbfbfb
	

	addi s0, a2, -1
	slli s0, s0, 2

	addi s1, s0, 21

	addi s0, s0, 13	

	addi s2, zero, 8
	
	reserve_format_info_space_lul:
	
		mv a3, a1
		mv a1, s2
		mv a2, s0
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a4, 8(sp)
					
	
		li s3, 0x00fefefe
		bne s3, a0, reserve_format_info_space_skip_draw_ul
		
		
		mv a3, a1
		mul a1, s2, a3
		mul a2, s0, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		reserve_format_info_space_skip_draw_ul:
		
	
		mv a3, a1
		mv a1, s0
		mv a2, s2
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a4, 8(sp)
					
	
		li s3, 0x00fefefe
		bne s3, a0, reserve_format_info_space_skip_draw_or
		
	
		mv a3, a1
		mul a1, s0, a3
		mul a2, s2, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		reserve_format_info_space_skip_draw_or:
		
	
		addi s0, s0, 1
		blt s0, s1, reserve_format_info_space_lul
	


	addi s1, zero, 9
	
	addi s0, zero, 0

	addi s2, zero, 8
	
	reserve_format_info_space_ol:
	
		mv a3, a1
		mv a1, s2
		mv a2, s0
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a4, 8(sp)
					
	
		li s3, 0x00fefefe
		bne s3, a0, reserve_format_info_space_skip_draw_olv
		
		
		mv a3, a1
		mul a1, s2, a3
		mul a2, s0, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		reserve_format_info_space_skip_draw_olv:
		
		
		mv a3, a1
		mv a1, s0
		mv a2, s2
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a4, 8(sp)
					
	
		li s3, 0x00fefefe
		bne s3, a0, reserve_format_info_space_skip_draw_olh
		
	
		mv a3, a1
		mul a1, s0, a3
		mul a2, s2, a3
		mv a4, s4
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 8(sp)
		
		reserve_format_info_space_skip_draw_olh:
	
		addi s0, s0, 1
		blt s0, s1, reserve_format_info_space_ol
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	addi sp, sp, 32
	ret
	

single_dark_module:
	addi sp, sp, -20
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	

	mv a3, a1
	addi s0, zero, 8
	mul a1, a3, s0
	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 13
	mul a2, s1, a3
	addi a4, zero, 0x000000
	jal ra, draw_square
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	addi sp, sp, 20
	ret


place_version_infos:
	addi sp, sp, -52
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw ra, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s5, 32(sp)
	sw s6, 36(sp)
	sw s7, 40(sp)
	sw s8, 44(sp)
	sw s9, 48(sp)
	

	addi s1, zero, 7
	blt a2, s1 place_version_infos_end

		addi s1, zero, 0 
		addi s3, zero, 6 
		addi s4, zero, 3 
		addi s5, zero, 0 
		addi s8, a2, -1 
		slli s8, s8, 2
		addi s8, s8, 10
		place_version_infos_loop_x_l:
			addi s2, zero, 0 
			place_version_infos_loop_y_l:
				
				addi s6, zero, 1 
				sll s6, s6, s5 
				and s6, s6, a3 
				srl s6, s6, s5 
				beq s6, zero, place_version_infos_l_white
					li s7, 0x000000
					j place_version_infos_l_both
				place_version_infos_l_white:
					li s7, 0xFFFFFF
				place_version_infos_l_both:
				
			
				add s9, s8, s2
				mv a3, a1
				mul a1, s9, a3
				mul a2, s1,a3
				mv a4, s7
				jal ra, draw_square
				lw a1, 0(sp)
				lw a2, 4(sp)
				lw a3, 8(sp)
				
			
				add s9, s8, s2
				mv a3, a1
				mul a1, s1, a3
				mul a2, s9,a3
				mv a4, s7
				jal ra, draw_square
				lw a1, 0(sp)
				lw a2, 4(sp)
				lw a3, 8(sp)
				
			
				addi s5, s5, 1
				
		
				addi s2, s2, 1
				blt s2, s4, place_version_infos_loop_y_l
				

			addi s1, s1, 1
			blt s1, s3, place_version_infos_loop_x_l
	
	place_version_infos_end:
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw ra, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s5, 32(sp)
	lw s6, 36(sp)
	lw s7, 40(sp)
	lw s8, 44(sp)
	lw s9, 48(sp)
	addi sp, sp, 52
	ret


place_data:
	addi sp, sp, -64 
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw ra, 12(sp)
	sw s0, 16(sp)
	sw s1, 20(sp)
	sw s2, 24(sp)
	sw s3, 28(sp)
	sw s4, 32(sp)
	sw s5, 36(sp)
	sw s6, 40(sp)
	sw s7, 44(sp)
	sw s8, 48(sp)
	sw s9, 52(sp)
	sw s10, 56(sp)
	sw s11, 60(sp)


	addi s0, a2, -1
	slli s0, s0, 2
	addi s0, s0, 20 
	mv s1, s0	
	mv s11, a3	
	
	mv s2, s0 
	mv s3, s1 
	addi s4, zero, 0 
	

	place_data_while_main:
		addi s5, zero, 7 
		
		lb s9, 0(s11)	
		
		
		addi s11, s11, 1
		
		
		place_data_while_zz:
		
		
			bne s2, zero, place_data_while_zz_skip_check
				beq s3, s1, place_data_while_main_end
			place_data_while_zz_skip_check:
		
			
			mv a3, a1
			mv a1, s2
			mv a2, s3
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
						
			
			li s7, 0x00ffffff
			beq s7, a0, place_data_zz_skip_bad_module
			li s7, 0x00000000
			beq s7, a0, place_data_zz_skip_bad_module
			li s7, 0x00fbfbfb
			beq s7, a0, place_data_zz_skip_bad_module
			li s7, 0x00fafafa
			beq s7, a0, place_data_zz_skip_bad_module
		
			
			addi s8, zero, 1 
			sll s8, s8, s5 
			and s8, s8, s9 
			srl s8, s8, s5 
			beq s8, zero, place_data_zz_white
				li s10, 0xFDFDFD
				j place_data_zz_both
			place_data_zz_white:
				li s10, 0xFCFCFC
			place_data_zz_both:
			
			
			mv a3, a1
			mul a1, s2, a3
			mul a2, s3, a3
			mv a4, s10
			jal ra, draw_square
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			
		
			addi s5, s5, -1
			
		
			place_data_zz_skip_bad_module:
				
			
			
				addi s8, zero, 2
				rem s8, s2, s8
				
				addi, s6, zero, 6
				bgt s2, s6 place_data_zz_skip_invert
					xori s8, s8, 0x01
				place_data_zz_skip_invert:
				
				
				bne s4, zero, place_data_zz_skip_up
				
					
					beq s8, zero, place_data_zz_skip_left_up
					
						bne s3, zero, place_data_zz_skip_left_up_y_not_zero
							
							addi s4, zero, 1 
							j place_data_zz_skip_left_up_y_not_zero_both
						place_data_zz_skip_left_up_y_not_zero:
							
							addi s3, s3, -1
							addi s2, s2, 1
							j place_data_zz_skip_up_both
						place_data_zz_skip_left_up_y_not_zero_both:
							
			
					place_data_zz_skip_left_up:
						addi s2, s2, -1
						j place_data_zz_skip_up_both
				place_data_zz_skip_up:
					
					
					beq s8, zero, place_data_zz_skip_left_down
					
						blt s3, s1, place_data_zz_skip_left_down_y_not_ymax
							
							addi s4, zero, 0 
							j place_data_zz_skip_left_up_y_not_max_both
						place_data_zz_skip_left_down_y_not_ymax:
							
							addi s3, s3, 1
							addi s2, s2, 1
							j place_data_zz_skip_up_both
						place_data_zz_skip_left_up_y_not_max_both:
						
					
					place_data_zz_skip_left_down:
						addi s2, s2, -1
						j place_data_zz_skip_up_both
						
				place_data_zz_skip_up_both:
					
					addi s6, zero, 6
					bne s2, s6, place_data_while_if_not_coloum_7_skip
						addi s2, s2, -1
					place_data_while_if_not_coloum_7_skip:
		
			
			bge s5, zero, place_data_while_zz

		
		beq zero, zero, place_data_while_main
		
	place_data_while_main_end:

	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw ra, 12(sp)
	lw s0, 16(sp)
	lw s1, 20(sp)
	lw s2, 24(sp)
	lw s3, 28(sp)
	lw s4, 32(sp)
	lw s5, 36(sp)
	lw s6, 40(sp)
	lw s7, 44(sp)
	lw s8, 48(sp)
	lw s9, 52(sp)
	lw s10, 56(sp)
	lw s11, 60(sp)
	addi sp, sp, 64
	ret


mask_data:
	addi sp, sp, -40
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw ra, 12(sp)
	sw s0, 16(sp)
	sw s1, 20(sp)
	sw s2, 24(sp)
	sw s3, 28(sp)
	sw s4, 32(sp)
	sw s5, 36(sp)


	addi s0, a2, -1
	slli s0, s0, 2
	addi s0, s0, 21	
	
	addi s1, zero, 0 
	
	mask_data_loopy:
		addi s2, zero, 0 
		mask_data_loopx:
		
			mask_data_switch.0:
				addi s3, zero, 0
				bne s3, a3, mask_data_switch.1
				
			
				add s4, s1, s2
				addi s3, zero, 2
				rem s4, s4, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.1:
				addi s3, zero, 1
				bne s3, a3, mask_data_switch.2
			
			
				addi s3, zero, 2
				rem s4, s1, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.2:
				addi s3, zero, 2
				bne s3, a3, mask_data_switch.3
				
			
				addi s3, zero, 3
				rem s4, s2, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.3:
				addi s3, zero, 3
				bne s3, a3, mask_data_switch.4
				
			
			
				add s4, s1, s2
				addi s3, zero, 3
				rem s4, s4, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.4:
				addi s3, zero, 4
				bne s3, a3, mask_data_switch.5
				
				
				addi s3, zero, 2
				div s4, s1, s3
				addi s3, zero, 3
				div s3, s2, s3
				add s4, s3, s4
				addi s3, zero, 2
				rem s4, s4, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.5:
				addi s3, zero, 5
				bne s3, a3, mask_data_switch.6
				
				
				
				mul s5, s1, s2
				addi s3, zero, 2
				rem s4, s5, s3
				addi s3, zero, 3
				rem s5, s5, s3
				add s4, s4, s5
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.6:
				addi s3, zero, 6
				bne s3, a3, mask_data_switch.7
				
				
				mul s5, s1, s2
				addi s3, zero, 2
				rem s4, s5, s3
				addi s3, zero, 3
				rem s5, s5, s3
				add s4, s4, s5
				addi s3, zero, 2
				rem s4, s4, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.7:
				addi s3, zero, 7
				bne s3, a3, mask_data_switch.end
				
			
				add s5, s1, s2
				addi s3, zero, 2
				rem s4, s5, s3
				mul s5, s1, s2
				addi s3, zero, 3
				rem s5, s5, s3
				add s4, s4, s5
				addi s3, zero, 2
				rem s4, s4, s3
				
				beq zero, zero mask_data_switch.end
			mask_data_switch.end:

			bne s4, zero, mask_data_loop_skip_module
			
				mv a3, a1
				mv a1, s2
				mv a2, s1
				jal ra, get_module_color
				lw a1, 0(sp)
				lw a2, 4(sp)
				lw a3, 8(sp)
			
			
				li s5, 0xFDFDFD
				bne a0, s5, mask_data_loop_try_white
					li a4, 0xFCFCFC
					j mask_data_loop_try_both
				
			
				mask_data_loop_try_white:
				li s5, 0xFCFCFC
				bne a0, s5, mask_data_loop_skip_module
					li a4, 0xFDFDFD
				mask_data_loop_try_both:
			
				mv a3, a1
				mul a1, s2, a3
				mul a2, s1, a3
				jal ra, draw_square
				lw a1, 0(sp)
				lw a2, 4(sp)
				lw a3, 8(sp)
			
			mask_data_loop_skip_module:
			
			
			addi s2, s2, 1
			blt s2, s0, mask_data_loopx
	
		
		addi s1, s1, 1
		blt s1, s0, mask_data_loopy
	

	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw ra, 12(sp)
	lw s0, 16(sp)
	lw s1, 20(sp)
	lw s2, 24(sp)
	lw s3, 28(sp)
	lw s4, 32(sp)
	lw s5, 36(sp)
	addi sp, sp, 40
	ret
	

write_format_infos:
	addi sp, sp, -52
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw a4, 12(sp)
	sw ra, 16(sp)
	sw s0, 20(sp)
	sw s1, 24(sp)
	sw s2, 28(sp)
	sw s3, 32(sp)
	sw s4, 36(sp)
	sw s5, 40(sp)
	sw s6, 44(sp)
	sw s8, 48(sp)
	

	slli a3, a3, 1	
	add a4, a4, a3
	lh s0, 0(a4)
	
	
	addi s2, zero, 14
	addi s3, zero, 0 
	addi s5, zero, 0 
	addi s6, zero, 8 
	

	write_format_infos_upper_left:
	
	
		mv a3, a1
		mv a1, s5
		mv a2, s6
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a2, 4(sp)
		lw a3, 8(sp)
		lw a4, 12(sp)
		
		li s7, 0x00ffffff
		beq s7, a0, write_format_infos_skip_bad_module
		li s7, 0x00000000
		beq s7, a0, write_format_infos_skip_bad_module
		
		
		addi s8, zero, 1 
		sll s8, s8, s2 
		and s8, s8, s0 
		srl s8, s8, s2 
		beq s8, zero, write_format_infos_white
			li s8, 0xFBFBFB
			j write_format_infos_both
		write_format_infos_white:
			li s8, 0xFAFAFA
		write_format_infos_both:	
			

		mv a3, a1
		mul a1, s5, a3
		mul a2, s6, a3
		mv a4, s8
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 4(sp)
		lw a3, 8(sp)
		lw a4, 12(sp)
			
	
		addi s2, s2, -1
		
		
		write_format_infos_skip_bad_module:
	
		addi s4, zero, 7
		bgt s5, s4, write_format_infos_go_upwards
			addi s5, s5, 1
			j write_format_infos_go_upwards_both
		
		write_format_infos_go_upwards:
			addi s6, s6, -1
			
		write_format_infos_go_upwards_both:
		
	
		bge, s2, zero, write_format_infos_upper_left
	
	
	
	addi s2, zero, 14
	addi s3, zero, 0 
	addi s5, zero, 8 

	addi s6, a2, -1
	slli s6, s6, 2
	addi s6, s6, 20
	mv s1, s6
	addi s1, s1, -6 
	
	
	write_format_infos_left_and_right:
	
		
		mv a3, a1
		mv a1, s5
		mv a2, s6
		jal ra, get_module_color
		lw a1, 0(sp)
		lw a2, 4(sp)
		lw a3, 8(sp)
		lw a4, 12(sp)
		
		li s7, 0x00ffffff
		beq s7, a0, write_format_infos_skip_bad_module_left_and_right
		li s7, 0x00000000
		beq s7, a0, write_format_infos_skip_bad_module_left_and_right
		
	
		addi s8, zero, 1
		sll s8, s8, s2 
		and s8, s8, s0 
		srl s8, s8, s2 
		beq s8, zero, write_format_infos_white_left_and_right
			li s8, 0xFBFBFB
			j write_format_infos_both_left_and_right
		write_format_infos_white_left_and_right:
			li s8, 0xFAFAFA
		write_format_infos_both_left_and_right:	
			
	
		mv a3, a1
		mul a1, s5, a3
		mul a2, s6, a3
		mv a4, s8
		jal ra, draw_square
		lw a1, 0(sp)
		lw a2, 4(sp)
		lw a3, 8(sp)
		lw a4, 12(sp)
			
	
		addi s2, s2, -1
		
	
		write_format_infos_skip_bad_module_left_and_right:

		ble s6, s1, write_format_infos_go_downwards
			addi s6, s6, -1
			j write_format_infos_go_downwards_both

		write_format_infos_go_downwards:
			addi s9, zero, 8
			bne s5, s9 write_format_infos_left_and_right_x_changed
				addi s5, s1, -2 
			write_format_infos_left_and_right_x_changed:
			addi s5, s5, 1
			addi s6, zero, 8
			
		write_format_infos_go_downwards_both:
		

		bge, s2, zero, write_format_infos_left_and_right
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw a4, 12(sp)
	lw ra, 16(sp)
	lw s0, 20(sp)
	lw s1, 24(sp)
	lw s2, 28(sp)
	lw s3, 32(sp)
	lw s4, 36(sp)
	lw s5, 40(sp)
	lw s6, 44(sp)
	lw s8, 48(sp)
	addi sp, sp, 52
	ret
	

draw_final_qr:
	addi sp, sp, -32
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp) 
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	

	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 21


	addi s2, zero, 0 
	draw_final_qr_loop_y:
		addi s3, zero, 0 
		draw_final_qr_loop_x:
		
	
			mv a3, a1
			mv a1, s3
			mv a2, s2
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
		
			
			li s4, 0xfbfbfb
			beq s4, a0 draw_final_qr_module_black
			
			li s4, 0xfdfdfd
			beq s4, a0 draw_final_qr_module_black
			
		
			li s4, 0xfafafa
			beq s4, a0 draw_final_qr_module_white
			
			li s4, 0xfcfcfc
			beq s4, a0 draw_final_qr_module_white
			
			j draw_final_qr_nothing_to_do
			
		
			draw_final_qr_module_black:
			li a4, 0x000000
			j draw_final_qr_draw_module
			
		
			draw_final_qr_module_white:
			li a4, 0xffffff
			j draw_final_qr_draw_module
			
			draw_final_qr_draw_module:
			mv a3, a1
			mul a1, s3, a3
			mul a2, s2, a3
			jal ra, draw_square
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			
			draw_final_qr_nothing_to_do:
	
			addi s3, s3, 1
			blt s3, s1, draw_final_qr_loop_x
		
	
		addi s2, s2, 1
		blt s2, s1, draw_final_qr_loop_y
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp) 
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	addi sp, sp, 32
	ret

calc_penalty:
	addi sp, sp, -16
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	

	addi s0, zero, 0
	
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	jal ra, penalty1
	add s0, s0, a0
	lw a1, 0(sp)
	lw a2, 4(sp)
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	jal ra, penalty2
	add s0, s0, a0
	lw a1, 0(sp)
	lw a2, 4(sp)
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	jal ra, penalty3
	add s0, s0, a0
	lw a1, 0(sp)
	lw a2, 4(sp)
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	jal ra, penalty4
	add s0, s0, a0
	lw a1, 0(sp)
	lw a2, 4(sp)
	

	mv a0, s0
	
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	addi sp, sp, 16
	ret


penalty1:
	addi sp, sp, -40
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s5, 32(sp)
	sw s6, 36(sp)
	

	addi s0, zero, 0
	
	
	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 21
	
	
	addi s2, zero, 0
	penalty1_loopy_h:
		addi s3, zero, 0
		addi s4, zero, 0
		addi s5, zero, 0
		penalty1_loopx_h:
			
			mv a3, a1
			mv a1, s3
			mv a2, s2
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			
			beq s3, zero, penalty1_x_zero_h
			
				bne a0, s4 penalty1_color_mismatch_h
					
					addi s5, s5, 1
					addi s6, zero, 5
					blt s5, s6, penalty1_color_mismatch_both_h
					bgt s5, s6, penalty1_count_greater_5_h
						addi s0, s0, 3
						j penalty1_color_mismatch_both_h
					penalty1_count_greater_5_h:
						addi s0, s0, 1
					j penalty1_color_mismatch_both_h
				penalty1_color_mismatch_h:
					
					mv s4, a0
					addi s5, zero, 1
				penalty1_color_mismatch_both_h:
				j penalty1_x_zero_both_h
			penalty1_x_zero_h:
				
				mv s4, a0
				addi s5, zero, 1
			penalty1_x_zero_both_h:
			
	
			addi s3, s3, 1
			blt s3, s1, penalty1_loopx_h
		
	
		addi s2, s2, 1
		blt s2, s1, penalty1_loopy_h
		

	addi s2, zero, 0
	penalty1_loopx_v:
		addi s3, zero, 0
		addi s4, zero, 0
		addi s5, zero, 0
		penalty1_loopy_v:
		
			mv a3, a1
			mv a1, s2
			mv a2, s3
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			
			beq s3, zero, penalty1_y_zero_v

				bne a0, s4 penalty1_color_mismatch_v
					
					addi s5, s5, 1
					addi s6, zero, 5
					blt s5, s6, penalty1_color_mismatch_both_v
					bgt s5, s6, penalty1_count_greater_5_v
						addi s0, s0, 3
						j penalty1_color_mismatch_both_v
					penalty1_count_greater_5_v:
						addi s0, s0, 1
					j penalty1_color_mismatch_both_v
				penalty1_color_mismatch_v:
					
					mv s4, a0
					addi s5, zero, 1
				penalty1_color_mismatch_both_v:
				j penalty1_y_zero_both_v
			penalty1_y_zero_v:
				
				mv s4, a0
				addi s5, zero, 1
			penalty1_y_zero_both_v:
			
		
			addi s3, s3, 1
			blt s3, s1, penalty1_loopy_v
		
	
		addi s2, s2, 1
		blt s2, s1, penalty1_loopx_v
	

	mv a0, s0
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s5, 32(sp)
	lw s6, 36(sp)
	addi sp, sp, 40
	ret

penalty2:
	addi sp, sp, -32
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	

	addi s0, zero, 0
	

	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 20
	
	addi s2, zero, 0 
	penalty2_loopy:
		addi s3, zero, 0
		penalty2_loopx:
		
	
			mv a3, a1
			mv a1, s3
			mv a2, s2
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			mv s4, a0 
		
	
			mv a3, a1
			addi a1, s3, 1
			mv a2, s2
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			bne s4, a0 penalty2_skip_penalty
			
			
			mv a3, a1
			mv a1, s3
			addi a2, s2, 1
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			bne s4, a0 penalty2_skip_penalty
			
		
			mv a3, a1
			addi a1, s3, 1
			addi a2, s2, 1
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			bne s4, a0 penalty2_skip_penalty
			
		
			addi s0, s0, 3
			
			penalty2_skip_penalty:

			addi s3, s3, 1
			blt s3, s1, penalty2_loopx
		
	
		addi s2, s2, 1
		blt s2, s1, penalty2_loopy
	
	
	mv a0, s0
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	addi sp, sp, 32
	ret
	

penalty_tmp_color_to_final:
	addi sp, sp, -12
	sw a1, 0(sp)
	sw ra, 4(sp)
	sw s0, 8(sp)
	
	penalty_tmp_color_to_final_case_fbfbfb:
		li s0, 0xfbfbfb
		bne a1, s0, penalty_tmp_color_to_final_case_fdfdfd
			li a0, 0x000000
		j penalty_tmp_color_to_final_end
	penalty_tmp_color_to_final_case_fdfdfd:
		li s0, 0xfdfdfd
		bne a1, s0, penalty_tmp_color_to_final_case_fafafa
			li a0, 0x000000
		j penalty_tmp_color_to_final_end
	penalty_tmp_color_to_final_case_fafafa:
		li s0, 0xfafafa
		bne a1, s0, penalty_tmp_color_to_final_case_fcfcfc
			li a0, 0xffffff
		j penalty_tmp_color_to_final_end
	penalty_tmp_color_to_final_case_fcfcfc:
		li s0, 0xfcfcfc
		bne a1, s0, penalty_tmp_color_to_final_default
			li a0, 0xffffff
		j penalty_tmp_color_to_final_end
	penalty_tmp_color_to_final_default:
		mv a0, a1
	penalty_tmp_color_to_final_end:	
	lw a1, 0(sp)
	lw ra, 4(sp)
	lw s0, 8(sp)
	addi sp, sp, 12
	ret
	


penalty3:
	addi sp, sp, -100
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s5, 32(sp)
	sw s6, 36(sp)
	sw s8, 40(sp)
	sw s9, 44(sp)
	sw s10, 48(sp)
	sw s11, 52(sp)
	

	li s0, 0x000000
	li s1, 0xffffff
	sw s0, 56(sp)
	sw s1, 60(sp)
	sw s0, 64(sp)
	sw s0, 68(sp)
	sw s0, 72(sp)
	sw s1, 76(sp)
	sw s0, 80(sp)
	sw s1, 84(sp)
	sw s1, 88(sp)
	sw s1, 92(sp)
	sw s1, 96(sp)
	

	addi s0, zero, 0
	

	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 21
	

	addi s2, zero, 0 
	penalty3_loopy_h:
		addi s3, zero, 0
		penalty3_loopx_h:
			
			addi s4, s1, -11
			bge s3, s4, penalty3_too_close_end_h
				
				addi s4, zero, 0
				penalty3_loop_pattern_end_h:
					
					mv a3, a1
					add a1, s3, s4
					mv a2, s2
					jal ra, get_module_color
					lw a1, 0(sp)
					lw a2, 4(sp)
			
					mv a1, a0
					jal ra, penalty_tmp_color_to_final
					lw a1, 0(sp)
					
				
					slli s5, s4, 2 
					addi s5, s5, 56
					add s5, s5, sp
					lw s6, 0(s5)
					
				
					bne a0, s6, penalty3_too_close_end_h
					
					addi s6, zero, 10
					beq s4, s6, penalty3_skip_penalty_end_h 
						
						addi s4, s4, 1
						j penalty3_loop_pattern_end_h
					penalty3_skip_penalty_end_h:
						
						addi s0, s0, 40
			
			penalty3_too_close_end_h:
			
			addi s4, zero, 10
			blt s3, s4, penalty3_too_close_begin_h
				
				addi s4, zero, 0
				penalty3_loop_pattern_begin_h:
					
					mv a3, a1
					sub a1, s3, s4
					mv a2, s2
					jal ra, get_module_color
					lw a1, 0(sp)
					lw a2, 4(sp)
			
					mv a1, a0
					jal ra, penalty_tmp_color_to_final
					lw a1, 0(sp)
					
				
					slli s5, s4, 2 
					addi s5, s5, 56
					add s5, s5, sp
					lw s6, 0(s5)
					
					
					bne a0, s6, penalty3_too_close_begin_h
					
					addi s6, zero, 10
					beq s4, s6, penalty3_skip_penalty_begin_h 
						
						addi s4, s4, 1
						j penalty3_loop_pattern_begin_h
					penalty3_skip_penalty_begin_h:
			
						addi s0, s0, 40
		
			penalty3_too_close_begin_h:
		
			addi s3, s3, 1
			blt s3, s1, penalty3_loopx_h
			

		addi s2, s2, 1
		blt s2, s1, penalty3_loopy_h
		
	
	addi s2, zero, 0 
	penalty3_loopx_v:
		addi s3, zero, 0 
		penalty3_loopy_v:
			
			addi s4, s1, -11
			bge s3, s4, penalty3_too_close_end_v
			
				addi s4, zero, 0
				penalty3_loop_pattern_end_v:
					
					mv a3, a1
					add a2, s3, s4
					mv a1, s2
					jal ra, get_module_color
					lw a1, 0(sp)
					lw a2, 4(sp)
			
					mv a1, a0
					jal ra, penalty_tmp_color_to_final
					lw a1, 0(sp)
					
					
					slli s5, s4, 2 
					addi s5, s5, 56
					add s5, s5, sp
					lw s6, 0(s5)
					
					bne a0, s6, penalty3_too_close_end_v
					
					addi s6, zero, 10
					beq s4, s6, penalty3_skip_penalty_end_v 
						
						addi s4, s4, 1
						j penalty3_loop_pattern_end_v
					penalty3_skip_penalty_end_v:
						
						addi s0, s0, 40
			
			penalty3_too_close_end_v:
			
			addi s4, zero, 10
			blt s3, s4, penalty3_too_close_begin_v
				
				addi s4, zero, 0
				penalty3_loop_pattern_begin_v:
					
					mv a3, a1
					sub a2, s3, s4
					mv a1, s2
					jal ra, get_module_color
					lw a1, 0(sp)
					lw a2, 4(sp)
			
					mv a1, a0
					jal ra, penalty_tmp_color_to_final
					lw a1, 0(sp)
					
				
					slli s5, s4, 2 
					addi s5, s5, 56
					add s5, s5, sp
					lw s6, 0(s5)
					
					
					bne a0, s6, penalty3_too_close_begin_v
					
					addi s6, zero, 10
					beq s4, s6, penalty3_skip_penalty_begin_v
						
						addi s4, s4, 1
						j penalty3_loop_pattern_begin_v
					penalty3_skip_penalty_begin_v:
						
						addi s0, s0, 40
		
			penalty3_too_close_begin_v:
		
			addi s3, s3, 1
			blt s3, s1, penalty3_loopy_v
			

		addi s2, s2, 1
		blt s2, s1, penalty3_loopx_v
	

	mv a0, s0
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s5, 32(sp)
	lw s6, 36(sp)
	lw s8, 40(sp)
	lw s9, 44(sp)
	lw s10, 48(sp)
	lw s11, 52(sp)
	addi sp, sp, 100
	ret


penalty4:
	addi sp, sp, -44
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw ra, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)
	sw s3, 24(sp)
	sw s4, 28(sp)
	sw s5, 32(sp)
	sw s6, 36(sp)
	sw s7, 40(sp)
	
	
	addi s0, zero, 0
	
	
	addi s1, a2, -1
	slli s1, s1, 2
	addi s1, s1, 21
	
	addi s2, zero, 0
	addi s3, zero, 0
	penalty4_loopy:
		addi s4, zero, 0
		penalty4_loopx:
		
			
			mv a3, a1
			mv a1, s4
			mv a2, s3
			jal ra, get_module_color
			lw a1, 0(sp)
			lw a2, 4(sp)
			
			mv a1, a0
			jal ra, penalty_tmp_color_to_final
			lw a1, 0(sp)
			
			li s5, 0x000000
			bne s5, a0, penalty4_skip
				
				addi s2, s2, 1
			penalty4_skip:
			
			addi s4, s4, 1
			blt s4, s1, penalty4_loopx
			
	
		addi s3, s3, 1
		blt s3, s1, penalty4_loopy
			
	
	mul s1, s1, s1 
	
	
	addi s5, zero, 100
	mul s6, s2, s5
	add s7, s2, s1
	srli s7, s7, 1
	add s7, s6, s7
	div s7, s7, s1
	
	
	addi s5, zero, 5
	div s6, s7, s5
	mul s6, s6, s5
	
	
	add s5, s6, s5
	
	
	addi s6, s6, -50
	bge s6, zero, penalty4_betrag_1_already
		addi s7, zero, -1
		mul s6, s6, s7
	penalty4_betrag_1_already:
	

	addi s5, s5, -50
	bge s5, zero, penalty4_betrag_2_already
		addi s7, zero, -1
		mul s5, s5, s7
	penalty4_betrag_2_already:
	
	
	blt s6, s5, penalty4_end
	mv s6, s5
	
	
	
	penalty4_end:
	addi s7, zero, 10
	mul a0, s6, s7
	

	mv a0, s0
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw ra, 8(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	lw s3, 24(sp)
	lw s4, 28(sp)
	lw s5, 32(sp)
	lw s6, 36(sp)
	lw s7, 40(sp)
	addi sp, sp, 44
	ret


.include "draw_fun.asm"
