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
						
  STD_INPUT_HANDLE  equ -10		; ���������, ����������� �� ���������� �����-������	
  STD_OUTPUT_HANDLE equ -11			

.code
program:
  ; �������� ������������� ���������� �����
      push  STD_INPUT_HANDLE			
      call  GetStdHandle		
      mov   input_id, eax				
	  
 ; �������� ������������� ���������� ������
      push  STD_OUTPUT_HANDLE
      call  GetStdHandle 
      mov   output_id, eax

  ; ������� �����������
      push  0					; ����������������� ��������
      push  0					; ��������� �� ���������� ��� ������ ���������� ���������� ��������			
      push  intr_len				; ���������� ��������� ��������
      push  offset intr			; ����� ��������� ������
      push  output_id			; ������������� ���������� ������
      call  WriteConsole		

  ; ������ ������
      push  0					; ����������������� ��������
      push  offset slength		; ����� ���������� � ����������� �������� ��������
      push  255					; ����. ���������� �������� ��������
      push  offset string		; ����� ��� ������ �������� ������
      push  input_id			; ������������� ���������� �����
      call  ReadConsole			

  ; ��������� ������
	  mov al, '*'	
	  cld
	  lea edi, string
	  mov ecx, slength
	  
	  repne scasb
	  jne not_found

	  mov edx, 0      ; ���������� �������, �� ������� ��������� �������� ���������

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

  ; ������� ������
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