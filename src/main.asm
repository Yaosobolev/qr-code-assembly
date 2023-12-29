
                                                                                                                                                                                                                                                                                
#заголовок данных, в котором хранятся все
.include "qr_data.asm"

.text
#получите пользовательский ввод (сообщение и уровень исправления ошибок)
jal ra, UI

#генерировать коды коррекции ошибок и приводить данные в правильный формат
jal ra, p2_start

#найдите лучший маскирующий шаблон и выведите окончательный qr-код
jal ra, draw

#выход из программы
li a7, 10
ecall	

#функции для каждой части
.include "qr_generate-error-correction.asm"
.include "qr_draw.asm"
.include "qr_user-input.asm"

