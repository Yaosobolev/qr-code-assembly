UI:
    #��������� ra � stackpointer
    sw ra, (sp)
    #t0 ������������ ��� ���������� ��� ��������� ������� 
    #welcome message
    li a7, 4
    la a0, p1_UI_welcome_message
    ecall

    li a7, 8
    li a0,MESSAGE_CODEWORD_ADDRESS#��������� ���� ����� �� �������� ������
    addi a0, a0, 0x3 #################### ��� ������������ ����������� ���������� 3 ��������� ����� ������������ --> ���� 3
    li a1,512    #������������ ���������� �������� --> ����� ������: 40-L ����.�������� = 512
    ecall

    p1_Get_Error_Correction:
        #������� ����������� ������: ��������� �� �������
        li a7, 4
        la a0, p1_user_Message2
        ecall
        #������� ����������� ������: ������ Int
        li a7, 5
        la t0, error_correction_level
        ecall
        sb a0, 0(t0) 

        #���������� ������
        #t3 ������������ � �������� ���������� ��� ��������� ���������� ��������� ������
        li t3, 3
        bgt a0,t3,p1_Get_Error_Correction.invalidLevel
        bltz a0, p1_Get_Error_Correction.invalidLevel

    #���������� ������ � ������������ ������, ���� ���� ��� ����������
    j p1_Get_String_Length


    p1_Get_Error_Correction.invalidLevel:
        li a7, 4
        la a0, p1_user_Message2_invalidInput
        ecall 
        j p1_Get_Error_Correction




p1_Get_String_Length:
    #a1 ����� *string --> ����� ������string
    li a1, MESSAGE_CODEWORD_ADDRESS
    addi a1, a1, 0x3 #������ ���� ��������� �� 3 ����� �����, ��� MESSAGE_CODEWORD_ADDRESS
    #t0 ������������� � ������ ����������� �������
    add t0, zero, zero
    #ascii �������� ��� '\n'
    li t3, 10 

p1_loop_Char_Amount_count.start:
    add t1, t0, a1
    lb t1, 0(t1)
    beqz t1, p1_loop_Char_Amount_count.end
    beq t1, t3, p1_loop_Char_Amount_count.end

    addi t0, t0, 1
    j p1_loop_Char_Amount_count.start



p1_loop_Char_Amount_count.end:



#������ ��� ����� ���������� ������ �� ���������� �������� � ������ � ��������� ������ ��������� ������ level
#������� ��������� ������ ��-�������� ����������� � a0 --> �� ����������������� �����, ����� ����� ���� ��������  
#t3 = �������� ��������� ��� �������� ����, ����� ������� ��� ����������
mv t3, zero
beq a0, t3, p1_switch_statement_error_correction_level.L #L=0

li t3, 1
beq a0, t3, p1_switch_statement_error_correction_level.M

li t3, 2
beq a0, t3, p1_switch_statement_error_correction_level.Q

li t3, 3
beq a0, t3, p1_switch_statement_error_correction_level.H

#################
#�������� �� ��������� ��������� ������! ��������� � ������ ��������� �����!#
j UI
#################


#t0 = str.length(input)
#��������� ������
#t4 ������������ ����� ��� ����� ������
#t5 ������� ����� ������� max_message_codeword --> � qr_data.asm

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

#t3 ��������� ����� ������ (1-40)
    la t4, qr_version
    sb t3, 0(t4)





#������� ��� ������ �� 9 � ����� ����������, ������� ����� ��� ����� ���������
#�����������:
#� �������� t3 ��-�������� ����������� ���������� � ������
#

li t6, 9
ble t3, t6, p1_version_OneToNine
j p1_version_GreaterThanNine




#���� ����������� �� 3 ����� �����, ��� ������, ����� ���������� ����� ��� ���������� ���������� �������� � ���������� ������ ������
#��� ���������� ����� ��������� ��������������� ����� ������� � ����� �������� ���������, ��������� ��� ����������, ����� ��������� �� ������ ������ (0x10140000).

#�����������:
#t0 = ����� ��������
#t3 = ���������� � ������ (0-3)



p1_version_OneToNine:
#������� �������� ������ ���� ������ 8 ��� --> ��������� ����, ����� ����������� � t0
    li a2, MESSAGE_CODEWORD_ADDRESS
    li s0, 0x4 #��������� ������ ������ --> ������ �������� ����� -> ������ 0100 ��� '4''
    sb s0, 0x1(a2)
    sb t0, 0x2(a2)
    #����� �� 4 ���� 3 ����
    #������ ����������� �� 3 ����� ������
    #���������� �������� ��������������� ����� ���
    #�������� ����� ��������������� ����� �������� Count
    #--> 12 ������� �����, ������� �� ����� ������� ����������
    jal p1_ShiftBy4Bits
    jal p1_ShiftBy4Bits
    jal p1_ShiftBy4Bits

    j p1_PadBytes #��������� ���� ����������� ������ ��� �� ��������� � qr-���

p1_version_GreaterThanNine:	
    #� ������ ByteMode ��������� ���������� �������� ��� ������ � 10 �� 26 ����� ���������� ��� ������ 27-40
    #������� �������� ������ ����� ����� 16 ���
    #--> ��������� � ���� ��������� �� ������, ���������� �� ����������� ������ ������
    li a2, MESSAGE_CODEWORD_ADDRESS
    li s0, 0x4 #��� � � ������� �������, ������ ���������� ����� ByteMode
    sb s0, 0(a2)
    sb t0, 0x2(a2)
    srli s11, t0,8
    sb s11, 0x1(a2)
    #����� �� 4 ����, ����� ����� ��������� ��������������� � ������ ����������, � �� � 4 ������� �����
    jal p1_ShiftBy4Bits

    j p1_PadBytes #��������� ���� ����������� ������ ��� �� ��������� � qr-���




################################################################
#Help-������� ��� ������ �������� � ����� ���������� �������� ������ � ���������� �������
#Shiftby4Bits ����� ������, ��� ��������� ������ ������ ����� ����� ����� 4 ���� ��� ��������, �� ������� ����� ����� ������ ������ �����. 
p1_ShiftBy4Bits:
    li a2, MESSAGE_CODEWORD_ADDRESS #����� �������� ������
    li s0, 0x170 
   
    p1_for_loop_4BitShift:

    lb a3, 0(a2)
    andi a3,a3,0xff
    lb a4, 1(a2)
    andi a4,a4,0xff
    slli a3, a3, 4
    srli s1, a4, 4 #�������� ������� ���� � �������� �� � �������� ����, ����� ������ �� ���� �������� � �������� ������
    add a3, a3, s1
    sb a3, 0(a2)

    addi s0,s0,-1
    beqz s0, p1_BitShift_Done
    addi a2, a2, 1
    j p1_for_loop_4BitShift


p1_BitShift_Done:

    ret


#����: ���� ����������� �� �����, ������ ���: ������ �������� ����� -> ������� �������� ��� ����� ��������� 8
#����� ����� ��� �������� ��������� 4 ���� ���������������� ����� ������ �������� ������  




    #�����������: � t0 ����������� �������� ���������� ��������. �� ��� ����� �������� 2 ��� 3 ����� � ����������� �� ������
    # ������ <=9: �������� 2 ����� � t0
    #������ >= 10 -> �������� 3 ����� � t0




p1_PadBytes:
    #�������� ������������ ���������� �������� (...) � ������� �� ���� ����������
    #�������� (����������� � t0), 
    #����� ��������� ������������ 236 � 17 (������ �����) � ��������� ������������
    #(...)= �������� � ������ �������
    #s0 = ������ qr
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
	#pad Byte �����, ����������� � s1
    li s10, 9
    la s9, qr_version
    lb s9, 0(s9)
    ble s9,s10,p1_PadBytes.lower9
    j p1_PadBytes.up10
    
#���������� ������ ������� �� 1; <=9: 2 ������������ �����, 10+:3 ������������ �����
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
    
#s2 ������� ��������� ����� ��� ������ ��������
#s3 ������������� � ������ �����

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
