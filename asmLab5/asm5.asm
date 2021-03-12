.686
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
includelib kernel32.lib

.data

  string  db 255 dup(0)
  input_id  dd 0
  output_id dd 0
  slength dd 0  

.const	
  intr db 'Input a string:', 13, 10	
  intr_len dd $ - intr

  res db 13, 10, 'Result:', 13, 10
  res_len dd $ - res
						
  STD_INPUT_HANDLE  equ -10		; константы, указывающие на устройства ввода-вывода	
  STD_OUTPUT_HANDLE equ -11			

.code
program:
  ; Получаем идентификатор устройства ввода
      push  STD_INPUT_HANDLE			
      call  GetStdHandle		
      mov   input_id, eax				
	  
 ; Получаем идентификатор устройства вывода
      push  STD_OUTPUT_HANDLE
      call  GetStdHandle 
      mov   output_id, eax

  ; Выводим приглашение
      push  0					; Зарезервированный параметр
      push  0					; Указатель на переменную для записи количества выведенных символов			
      push  intr_len				; Количество выводимых символов
      push  offset intr			; Адрес выводимой строки
      push  output_id			; Идентификатор устройства вывода
      call  WriteConsole		

  ; Вводим строку
      push  0					; Зарезервированный параметр
      push  offset slength		; Адрес переменной с количеством введённых символов
      push  255					; Макс. количество вводимых символов
      push  offset string		; Адрес для записи введённой строки
      push  input_id			; Идентификатор устройства ввода
      call  ReadConsole			

  ; Обработка строки
	  mov al, '*'	
	  cld
	  lea edi, string
	  mov ecx, slength
	  
	  repne scasb
	  jne not_found

	  mov edx, 0      ; количество позиций, на которое требуется сдвинуть подстроку

	  cycl1: 
	  mov esi, edi
	  repne scasb
	  inc edx
	  sub edi, esi
	  push ecx
	  mov ecx, edi

	  mov edi, esi
	  sub edi, edx

	  cycl2: 
	  movsb
	  loop cycl2
	  pop ecx

	  add edi, edx
	  cmp ecx, 0
	  jg cycl1
	
	  sub slength, edx
	  
	  not_found:  

  ; Выводим строку
	  push  0
      push  0
      push  res_len
      push  offset res
      push  output_id
      call  WriteConsole

      push  0
      push  0
      push  slength
      push  offset string
      push  output_id
      call  WriteConsole

      push  0
      call  ExitProcess
end program