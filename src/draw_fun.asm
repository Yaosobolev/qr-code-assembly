#a1: x, a2:y, a3: цвет
draw_pixel:
	#Сохраните значения в стеке 

	addi sp, sp, -20
	sw s0, 0(sp)	#для относительного положения и позже  финальная позиция
	sw s1, 4(sp)	#для кэширования адреса display_address
	sw a1, 8(sp)
	sw a2, 12(sp)
	sw a3, 16(sp)
	
	#определите правильную линию
	li s0, DISPLAY_WIDTH
	mul s0, a2, s0
	#Определите позицию в строке
	add s0, a1, s0
	
	#Вычислите , умноженное на 4, так как значение всегда состоит из rgb-.
	slli s0, s0, 2
	
	#определите необходимый адрес
	li s1, DISPLAY_ADDRESS
	add s0, s0, s1

	#Установите colour в нужное положение
	sw a3, 0(s0)

	#Перезагрузите сохраненные значения stack
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw a1, 8(sp)
	lw a2, 12(sp)
	lw a3, 16(sp)
	addi sp, sp, 20
	ret

#a1: x link oben, a2: y rechts oben, a3: ширина в пикселях, a4: цвет
draw_square:
	#Сохраните значения в стеке
	addi sp, sp, -28
	sw a1, 0(sp)
	sw a2, 4(sp)
	sw a3, 8(sp)
	sw a4, 12(sp)
	sw s0, 16(sp)	#счетчик по оси y
	sw s1, 20(sp)	#счетчик по оси x
	sw ra, 24(sp)	#ra ist звонок сохранен
	
	addi s1, zero, 0	#Установите counter y
	draw_square_loopy:
		addi s0, zero, 0	#Установите counter x
		draw_square_loopx:	
			#Установите параметр для рисования пикселя
			add a1, a1, s0
			add a2, a2, s1
			add a3, zero, a4
			jal ra, draw_pixel
			#перезагрузите значения из стека, поскольку они могли измениться
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			lw a4, 12(sp)
			
			#increment  увеличение переменной x на единицу
			addi s0, s0, 1
			#цикл x условие
			blt s0, a3, draw_square_loopx
		#Установите x обратно в начало квадрата
		add s0, zero, a3
		
		#increment увеличить переменную y на единицу
		addi s1, s1, 1
		#цикл y условие			
		blt s1, a3, draw_square_loopy

		#Загрузите значения из стека
	lw a1, 0(sp)
	lw a2, 4(sp)
	lw a3, 8(sp)
	lw a4, 12(sp)
	lw s0, 16(sp)
	lw s1, 20(sp)
	lw ra, 24(sp)
	addi sp, sp, 28

	ret
	
#a1: x вверху слева, a2: y вверху слева, a3: x внизу справа, a4: y внизу справа, a5: цвет
draw_rectangle:
	#Сохраните значения в стеке
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
	
		add s0, zero, a1 #Установите counter y
		draw_rectangle_loopx:	
			#Вызов draw pixel
			add a1, zero, s0
			add a2, zero, s1
			add a3, zero, a5
			jal ra, draw_pixel
			#Перезагрузите данные из стека, которые могли измениться
			lw a1, 0(sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			lw a4, 12(sp)
			lw a5, 16(sp)
			
			#Условие для цикла x
			addi s0, s0, 1
			bne s0, a3, draw_rectangle_loopx
		
		#Условие для цикла y
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
	
#a1: цвет‚
clear_screen:
	#Сохраните значения в стеке
	addi sp, sp, -24
	sw a1, 0(sp)
	sw s0, 4(sp)	#y counter
	sw s1, 8(sp)	#x counter
	sw s2, 12(sp)	#display_width
	sw s3, 16(sp)	#display_height
	sw ra, 20(sp)
	
	li s2, DISPLAY_WIDTH
	li s3, DISPLAY_HEIGHT
	
	addi s0, zero, 0	#установить счетчик y
	clear_screen_loopy:
		addi s1, zero, 0	#установить счетчик x
		clear_screen_loopx:
			#Установите параметр для вызова функции
			add a3, zero, a1
			add a1, zero, s1
			add a2, zero, s0
			jal ra, draw_pixel
			#Восстановление регистрация
			lw a1, 0(sp)
			
			#Увеличьте counter x на единицу
			addi s1, s1, 1
			#Условие loopx
			blt s1, s2, clear_screen_loopx
		
		#Увеличьте counter y на единицу
		addi s0, s0, 1
		blt s0, s3, clear_screen_loopy			
	
		#значения из магазина стеков
	lw a1, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw ra, 20(sp)
	addi sp, sp, 24
	
	ret
