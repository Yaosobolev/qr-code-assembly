
                                                                                                                                                                                                                                                                                
#��������� ������, � ������� �������� ���
.include "qr_data.asm"

.text
#�������� ���������������� ���� (��������� � ������� ����������� ������)
jal ra, UI

#������������ ���� ��������� ������ � ��������� ������ � ���������� ������
jal ra, p2_start

#������� ������ ����������� ������ � �������� ������������� qr-���
jal ra, draw

#����� �� ���������
li a7, 10
ecall	

#������� ��� ������ �����
.include "qr_generate-error-correction.asm"
.include "qr_draw.asm"
.include "qr_user-input.asm"

