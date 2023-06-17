#		.text
#		li t2, 2 		# загружаю константу
#start:		addi t1,zero, 1
#		li t2, 2
#		li t1, 3
#		mv t0,t2 		# присваиваю t2 в t0 
#		add t2, t0, t1 		# сложение
#	
#fibonacci: 	mv a0, t1		# присваиваю t1 в a0
#		add t1, t0, t1		# сложение
#		mv t0, a0		# присваиваю s0 в t0
#		addi t3, t3, 1		# сложение
#		bne t2, t3, fibonacci	# если t2 != t3, сделать переход на участок кода, помеченный fibonacci,
					# иначе выполнить следующую команду
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