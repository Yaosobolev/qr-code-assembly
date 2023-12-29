#a1: x, a2:y, a3: ����
draw_pixel:
	#��������� �������� � ����� 

	addi sp, sp, -20
	sw s0, 0(sp)	#��� �������������� ��������� � �����  ��������� �������
	sw s1, 4(sp)	#��� ����������� ������ display_address
	sw a1, 8(sp)
	sw a2, 12(sp)
	sw a3, 16(sp)
	
	#���������� ���������� �����
	li s0, DISPLAY_WIDTH
	mul s0, a2, s0
	#���������� ������� � ������
	add s0, a1, s0
	
	#��������� , ���������� �� 4, ��� ��� �������� ������ ������� �� rgb-.
	slli s0, s0, 2
	
	#���������� ����������� �����
	li s1, DISPLAY_ADDRESS
	add s0, s0, s1

	#���������� colour � ������ ���������
	sw a3, 0(s0)

	#������������� ����������� �������� stack
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw a1, 8(sp)
	lw a2, 12(sp)
	lw a3, 16(sp)
	addi sp, sp, 20
	ret

#a1: x link oben, a2: y rechts oben, a3: ������ � ��������, a4: ����
draw_square:
	#��������� �������� � �����
	addi sp, sp, -28
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw a4, 12(sp)
	sw s0, 16(sp)	#������� �� ��� y
	sw s1, 20(sp)	#������� �� ��� x
	sw ra, 24(sp)	#ra ist ������ ��������
	
	addi s1, zero, 0	#���������� counter y
	draw_square_loopy:
		addi s0, zero, 0	#���������� counter x
		draw_square_loopx:	
			#���������� �������� ��� ��������� �������
			add a1, a1, s0
			add a2, a2, s1
			add a3, zero, a4
			jal ra, draw_pixel
			#������������� �������� �� �����, ��������� ��� ����� ����������
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			lw a4, 12(sp)
			
			#increment  ���������� ���������� x �� �������
			addi s0, s0, 1
			#���� x �������
			blt s0, a3, draw_square_loopx
		#���������� x ������� � ������ ��������
		add s0, zero, a3
		
		#increment ��������� ���������� y �� �������
		addi s1, s1, 1
		#���� y �������			
		blt s1, a3, draw_square_loopy

		#��������� �������� �� �����
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw a4, 12(sp)
	lw s0, 16(sp)
	lw s1, 20(sp)
	lw ra, 24(sp)
	addi sp, sp, 28

	ret
	
#a1: x ������ �����, a2: y ������ �����, a3: x ����� ������, a4: y ����� ������, a5: ����
draw_rectangle:
	#��������� �������� � �����
	addi sp, sp, -32
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw a4, 12(sp)
	sw a5, 16(sp)
	sw s0, 20(sp)
	sw s1, 24(sp)
	sw ra, 28(sp)
	
	add s1, zero, a2 
	
	draw_rectangle_loopy:
	
		add s0, zero, a1 #���������� counter y
		draw_rectangle_loopx:	
			#����� draw pixel
			add a1, zero, s0
			add a2, zero, s1
			add a3, zero, a5
			jal ra, draw_pixel
			#������������� ������ �� �����, ������� ����� ����������
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			lw a4, 12(sp)
			lw a5, 16(sp)
			
			#������� ��� ����� x
			addi s0, s0, 1
			bne s0, a3, draw_rectangle_loopx
		
		#������� ��� ����� y
		addi s1, s1, 1			
		bne s1, a4, draw_rectangle_loopy


	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw a4, 12(sp)
	lw a5, 16(sp)
	lw s0, 20(sp)
	lw s1, 24(sp)
	lw ra, 28(sp)
	addi sp, sp, 32

	ret
	
#a1: ����
clear_screen:
	#��������� �������� � �����
	addi sp, sp, -24
	sw a1, 0(sp)
	sw s0, 4(sp)	#y counter
	sw s1, 8(sp)	#x counter
	sw s2, 12(sp)	#display_width
	sw s3, 16(sp)	#display_height
	sw ra, 20(sp)
	
	li s2, DISPLAY_WIDTH
	li s3, DISPLAY_HEIGHT
	
	addi s0, zero, 0	#���������� ������� y
	clear_screen_loopy:
		addi s1, zero, 0	#���������� ������� x
		clear_screen_loopx:
			#���������� �������� ��� ������ �������
			add a3, zero, a1
			add a1, zero, s1
			add a2, zero, s0
			jal ra, draw_pixel
			#�������������� �����������
			lw a1, 0(sp)
			
			#��������� counter x �� �������
			addi s1, s1, 1
			#������� loopx
			blt s1, s2, clear_screen_loopx
		
		#��������� counter y �� �������
		addi s0, s0, 1
		blt s0, s3, clear_screen_loopy			
	
		#�������� �� �������� ������
	lw a1, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw ra, 20(sp)
	addi sp, sp, 24
	
	ret
