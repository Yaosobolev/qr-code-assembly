UI:
    #сохранить ra в stackpointer
    sw ra, (sp)
    #t0 используется как переменная для различных адресов 
    #welcome message
    li a7, 4
    la a0, p1_UI_welcome_message
    ecall

    li a7, 8
    li a0,MESSAGE_CODEWORD_ADDRESS#Загрузите сюда адрес из входного буфера
    addi a0, a0, 0x3 #################### Для последующего кодирования пригодятся 3 стартовых байта пространства --> плюс 3
    li a1,512    #максимальное количество символов --> Режим байтов: 40-L макс.символов = 512
    ecall

    p1_Get_Error_Correction:
        #Уровень исправления ошибок: сообщение на дисплее
        li a7, 4
        la a0, p1_user_Message2
        ecall
        #Уровень исправления ошибок: Чтение Int
        li a7, 5
        la t0, error_correction_level
        ecall
        sb a0, 0(t0) 

        #управление входом
        #t3 используется в качестве переменной для различных операторов сравнения ветвей
        li t3, 3
        bgt a0,t3,p1_Get_Error_Correction.invalidLevel
        bltz a0, p1_Get_Error_Correction.invalidLevel

    #Пропустить секцию с неправильным вводом, если ввод был нормальным
    j p1_Get_String_Length


    p1_Get_Error_Correction.invalidLevel:
        li a7, 4
        la a0, p1_user_Message2_invalidInput
        ecall 
        j p1_Get_Error_Correction




p1_Get_String_Length:
    #a1 равно *string --> адрес строкиstring
    li a1, MESSAGE_CODEWORD_ADDRESS
    addi a1, a1, 0x3 #Строка была сохранена на 3 байта позже, чем MESSAGE_CODEWORD_ADDRESS
    #t0 увеличивается с каждым отсчитанным зарядом
    add t0, zero, zero
    #ascii значение для '\n'
    li t3, 10 

p1_loop_Char_Amount_count.start:
    add t1, t0, a1
    lb t1, 0(t1)
    beqz t1, p1_loop_Char_Amount_count.end
    beq t1, t3, p1_loop_Char_Amount_count.end

    addi t0, t0, 1
    j p1_loop_Char_Amount_count.start



p1_loop_Char_Amount_count.end:



#Теперь нам нужно определить версию по количеству символов в строке И заданному уровню коррекции ошибок level
#уровень коррекции ошибок по-прежнему сохраняется в a0 --> из пользовательского ввода, иначе может быть загружен  
#t3 = значение сравнения для проверки того, какой уровень был установлен
mv t3, zero
beq a0, t3, p1_switch_statement_error_correction_level.L #L=0

li t3, 1
beq a0, t3, p1_switch_statement_error_correction_level.M

li t3, 2
beq a0, t3, p1_switch_statement_error_correction_level.Q

li t3, 3
beq a0, t3, p1_switch_statement_error_correction_level.H

#################
#Проблема со значением коррекции ошибок! Перейдите к началу программы снова!#
j UI
#################


#t0 = str.length(input)
#сохраняет версию
#t4 максимальная сумма для одной версии
#t5 получил адрес таблицы max_message_codeword --> в qr_data.asm

p1_switch_statement_error_correction_level.L:
    la t5, max_message_codeword
    mv t3, zero
    j p1_for_loop_version_table


p1_switch_statement_error_correction_level.M:
    la t5, max_message_codeword
    mv t3, zero
    addi t5, t5, 2
    j p1_for_loop_version_table

p1_switch_statement_error_correction_level.Q:
    la t5, max_message_codeword
    mv t3, zero
    addi t5,t5, 4
    j p1_for_loop_version_table

p1_switch_statement_error_correction_level.H:
    la t5, max_message_codeword
    mv t3, zero
    addi t5, t5, 6
    j p1_for_loop_version_table


################
p1_for_loop_version_table:
    lh t4, 0(t5)
    addi t3, t3, 1
    ble t0, t4, p1_qr_version 
    addi t5, t5, 8
    j p1_for_loop_version_table
#################

#################
p1_qr_version:

#t3 сохраняет номер версии (1-40)
    la t4, qr_version
    sb t3, 0(t4)





#Процесс для версии до 9 и далее отличается, поэтому здесь код будет ветвиться
#напоминание:
#В регистре t3 по-прежнему сохраняется информация о версии
#

li t6, 9
ble t3, t6, p1_version_OneToNine
j p1_version_GreaterThanNine




#Ввод сохраняется на 3 байта левее, чем обычно, чтобы освободить место для индикатора количества символов и индикатора режима выбора
#Оба индикатора будут сохранены непосредственно перед данными и будут сдвинуты настолько, насколько это необходимо, чтобы добраться до адреса начала (0x10140000).

#напоминание:
#t0 = Сумма символов
#t3 = Информация о версии (0-3)



p1_version_OneToNine:
#Счетчик символов должен быть длиной 8 бит --> Сохранить байт, сумма сохраняется в t0
    li a2, MESSAGE_CODEWORD_ADDRESS
    li s0, 0x4 #Индикатор выбора режима --> только байтовый режим -> всегда 0100 или '4''
    sb s0, 0x1(a2)
    sb t0, 0x2(a2)
    #сдвиг на 4 бита 3 раза
    #строка сохраняется на 3 байта вправо
    #количество символов непосредственно перед ним
    #выберите режим непосредственно перед символом Count
    #--> 12 ведущих нулей, которые не несут никакой информации
    jal p1_ShiftBy4Bits
    jal p1_ShiftBy4Bits
    jal p1_ShiftBy4Bits

    j p1_PadBytes #следующий этап кодирования данных для их обработки в qr-код

p1_version_GreaterThanNine:	
    #В режиме ByteMode индикатор количества символов для версий с 10 по 26 равен индикатору для версий 27-40
    #Счетчик символов должен иметь длину 16 бит
    #--> сохранить в виде полуслова по адресу, следующему за индикатором режима выбора
    li a2, MESSAGE_CODEWORD_ADDRESS
    li s0, 0x4 #как и в младших версиях, всегда выбирается режим ByteMode
    sb s0, 0(a2)
    sb t0, 0x2(a2)
    srli s11, t0,8
    sb s11, 0x1(a2)
    #сдвиг на 4 бита, чтобы буфер начинался непосредственно с нужной информации, а не с 4 ведущих нулей
    jal p1_ShiftBy4Bits

    j p1_PadBytes #следующий этап кодирования данных для их обработки в qr-код




################################################################
#Help-функция для сдвига значений с целью приведения значения буфера к требуемому формату
#Shiftby4Bits нужен потому, что индикатор режима выбора имеет длину всего 4 бита или полбайта, но хранить здесь можно только полные байты. 
p1_ShiftBy4Bits:
    li a2, MESSAGE_CODEWORD_ADDRESS #АДРЕС ВХОДНОГО БУФЕРА
    li s0, 0x170 
   
    p1_for_loop_4BitShift:

    lb a3, 0(a2)
    andi a3,a3,0xff
    lb a4, 1(a2)
    andi a4,a4,0xff
    slli a3, a3, 4
    srli s1, a4, 4 #получить верхние биты и добавить их к регистру выше, чтобы данные не были потеряны в процессе сдвига
    add a3, a3, s1
    sb a3, 0(a2)

    addi s0,s0,-1
    beqz s0, p1_BitShift_Done
    addi a2, a2, 1
    j p1_for_loop_4BitShift


p1_BitShift_Done:

    ret


#Идея: Биты терминатора не нужны, потому что: Только байтовый режим -> счетчик символов уже имеет множитель 8
#сдвиг влево уже заполнил последние 4 бита соответствующего места буфера четырьмя нулями  




    #Напоминание: в t0 сохраняется исходное количество символов. Но вам нужно добавить 2 или 3 байта в зависимости от версии
    # Версия <=9: добавить 2 байта к t0
    #версия >= 10 -> добавить 3 байта к t0




p1_PadBytes:
    #Получите максимальное количество символов (...) и вычтите из него количество
    #символов (сохраняется в t0), 
    #затем загрузите чередующиеся 236 и 17 (шаблон битов) в свободное пространство
    #(...)= смещение к адресу таблицы
    #s0 = версия qr
    la s2, error_correction_level
    lb s2, 0(s2)
     
    la s0, qr_version
    lb s0, 0(s0)
    
    addi s0,s0,-1
    slli s0, s0, 2
    add s0, s0, s2
    slli s0, s0, 1
    
    
 

    la s2, max_message_codeword
    add s0, s0, s2
    lh s1, 0(s0)
    li s11, 0xffff
    and s1,s11, s1

    sub s1, s1, t0
	#pad Byte Сумма, сохраненная в s1
    li s10, 9
    la s9, qr_version
    lb s9, 0(s9)
    ble s9,s10,p1_PadBytes.lower9
    j p1_PadBytes.up10
    
#количество байтов зависит от 1; <=9: 2 индикаторных байта, 10+:3 индикаторных байта
p1_PadBytes.lower9:
    addi t0,t0,2
    j p1_PadBytes.continue	
p1_PadBytes.up10:
    addi t0,t0,3
    j p1_PadBytes.continue
p1_PadBytes.continue:   
    li s2, MESSAGE_CODEWORD_ADDRESS
    add s2, s2, t0
    
    #addi s2, s2, 1
    
#s2 получил начальный адрес для байтов подложки
#s3 увеличивается с каждым шагом

mv s3, zero

p1_padding_for_loop:
    beq s1, s3 p1_padding_for_loop.end
    jal p1_padding_for_loop.236
    addi s3, s3, 1
    beq s1, s3 p1_padding_for_loop.end
    jal p1_padding_for_loop.17

    addi s3, s3, 1
    j p1_padding_for_loop

    p1_padding_for_loop.236:
    li s4, 236
    sb s4, 0(s2)
    addi s2,s2,1
    ret

    p1_padding_for_loop.17:
    li s4, 17
    sb s4, 0(s2)
    addi s2,s2,1
    ret

p1_padding_for_loop.end:

lw ra, (sp)
jalr zero, 0(ra)
