#		.text
#		li t2, 2 		# �������� ���������
#start:		addi t1,zero, 1
#		li t2, 2
#		li t1, 3
#		mv t0,t2 		# ���������� t2 � t0 
#		add t2, t0, t1 		# ��������
#	
#fibonacci: 	mv a0, t1		# ���������� t1 � a0
#		add t1, t0, t1		# ��������
#		mv t0, a0		# ���������� s0 � t0
#		addi t3, t3, 1		# ��������
#		bne t2, t3, fibonacci	# ���� t2 != t3, ������� ������� �� ������� ����, ���������� fibonacci,
					# ����� ��������� ��������� �������
		.text
proc:		li x1, 585
		li x1, 135
                mv     eax,[val1]
        	mv     ecx,[val2]
    		@@: jecxz   @F                      ; return val1 if val2 = 0
        	xor     edx,edx
        	div     ecx                     ; eax = val1 / val2; edx = val1 % val2 (replace this instruction by 'idiv' and previous one by 'cdq' to treat val1 and val2 as signed)
        	mv     eax,ecx                 ; eax = val2
        	mv     ecx,edx                 ; ecx = edx = val1 % val2
        	j     @B
    @@: ret
endp