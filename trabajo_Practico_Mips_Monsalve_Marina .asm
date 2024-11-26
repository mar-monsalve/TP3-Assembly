.data
slist: 	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: 	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error: 	.asciiz "Error: "
return: .asciiz "\n"
catName: .asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName: .asciiz "\nIngrese el nombre de un objeto: "
success: .asciiz "La operación se realizo con exito\n\n"
greater_symbol: .asciiz ">"
invalid_option: .asciiz "\nOpción inválida. Inténtelo de nuevo.\n"
not_found_msj: .asciiz "Not Found. \n"

.text
main:
	la $t0, schedv # initialization scheduler vector
	la $t1, newcategory
	sw $t1, 0($t0)  # opción 1 nueva
	la $t1, nextcategory
	sw $t1, 4($t0)  # opción 2 siguiente
	la $t1, prevcategory
	sw $t1, 8($t0)  # opción 3 anterior
	la $t1, listcategories
	sw $t1, 12($t0)  # opcion 4 listar
	la $t1, delcategory
	sw $t1, 16($t0)  # opción 5 borrar
	la $t1, newobject
	sw $t1, 20($t0)  # opción 6 añadir
	la $t1, listobjects
	sw $t1, 24($t0)  # opción 7 listar objetos
	la $t1, delobject_all
	sw $t1, 28($t0)  # opción 8 borrar objeto

menu_loop:
	la $a0, menu # mostrar menú
	li $v0, 4
	syscall
	
	li $v0, 5 # ingresar opción
	syscall
	move $t2, $v0  # guardar opción

	beqz $t2, exit # validar opción
	blt $t2, 1, invalid_optionn
	bgt $t2, 8, invalid_optionn

	subi $t2, $t2, 1 # calcular dirección de subrutina y llamar
	sll $t2, $t2, 2
	la $t0, schedv
	add $t0, $t0, $t2
	lw $t1, 0($t0)
	jalr $t1

	j menu_loop

invalid_optionn:
	la $a0, invalid_option # opción inválida
	li $v0, 4
	syscall
	j menu_loop

exit:
	li $v0, 10 #salir
	syscall

newcategory:
	addiu $sp, $sp, -4 # decrementar el puntero en 4 bytes para reservar espacio
	sw $ra, 4($sp)	   # guardar $ra en el stack
	la $a0, catName    # input category name; $a0 primer argumento
	jal getblock
	move $a2, $v0 # $a2 = *char to category name; $a2 puntero al nombre de la categoría
	la $a0, cclist # $a0 = list
	li $a1, 0 # $a1 = NULL
	jal addnode #llamar a addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # update working list if was NULL
	
newcategory_end:
	li $v0, 0 # return success
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    	
nextcategory:
    	addiu $sp, $sp, -4 # disminuir $sp para reservar 4 bytes
    	sw $ra, 4($sp)
    	lw $t0, cclist # $t0 contiene dirección nodo inicial
    	beqz $t0, error_201 # si cclist vacía se llama a error_201

    	lw $t1, wclist # $t1 apunta a categoría actual
    	lw $t2, 12($t1) # dirección del nodo sigte
    	beq $t1, $t2, error_202 # si apunta a sí misma llama a error_202

    	sw $t2, wclist # apuntar al siguiente nodo
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	li $v0, 0
    	j nextcategory_end
    	
nextcategory_end:
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    
    	
error_201:
   	li $v0, 4          # Llamada para imprimir strings
	la $a0, error      # Mensaje de error
    	syscall

   	li $v0, 1          # Llamada para imprimir enteros
   	li $a0, 201        # Código de error
    	syscall

    	la $a0, return     # Mensaje de retorno
    	li $v0, 4          
    	syscall

    	j nextcategory_end 
    	
error_202:
   	li $v0, 4          # Llamada para imprimir strings
	la $a0, error      # Mensaje de error
    	syscall

   	li $v0, 1          # Llamada para imprimir enteros
   	li $a0, 202        # Código de error
    	syscall

    	la $a0, return     # Mensaje de retorno
    	li $v0, 4          
    	syscall

    	j nextcategory_end 
    	
prevcategory:
	addiu $sp, $sp, -4      # reservar espacio en el stack
        sw $ra, 4($sp)          # guardar $ra

  	lw $t0, cclist          # cargar la lista de categorías
  	lw $t1, wclist          # categoría actual en $t1
 	lw $t2, 0($t1)          # nodo anterior en $t2

 	beqz $t0, error_201   # si lista principal es NULL
 	beq $t1, $t2, error_202 # si la lista tiene un solo nodo

  	sw $t2, wclist          # actualizar wclist al nodo anterior
  	lw $a0, 8($t2)          # obtener nombre de categoría
  	li $v0, 4
  	syscall                 # imprimir nombre
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra               
    	
delcategory:
	addiu $sp, $sp, -4 # reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_401

    	lw $t1, 4($t0)   # lista objetos 
    	beqz $t1, delcat_empty

    	move $a0, $t1
    	jal delobject_all  # llama a borrar a todos    	
    	
delcat_empty:
    lw $a0, wclist
    lw $a1, cclist
    lw $t5, 12($a0)      # cargar el siguiente nodo en $t5
    beq $t5, $a0, del_last_cat # si el siguiente nodo es el actual, ir a del_last_cat

    sw $t5, wclist       # actualizar wclist al siguiente nodo
    beq $a0, $a1, update_cclist # si a0 es igual a a1, actualizar cclist
    j del_node_cat       

update_cclist:
    sw $t5, cclist       # actualizar cclist
    j del_node_cat      

    	
del_last_cat:
    	sw $zero, cclist
	sw $zero, wclist
	
del_node_cat:	
	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    	
error_401:
	li $v0, 4
	la $a0, error
    	syscall
    	
    	li $v0, 1
	li $a0, 401
       	syscall
       	
	li $v0, 4
    	la $a0, return
    	syscall
    	
    	li $v0, 401
    	jr $ra
    
listcategories:
	lw $t0, cclist
    	beqz $t0, list_error_301
    	lw $t2, wclist
    	move $t1, $t0
    	
listcategories_end:
    	jr $ra

list_loop:
    	bne $t1, $t2, list_loop2
list_loop2:
    	lw $a0, 8($t1)
    	li $v0, 4
    	syscall
    	lw $t1, 12($t1)
    	bne $t1, $t0, list_loop
print_symbol:
    	la $a0, greater_symbol
    	syscall

list_error_301:
    li $v0, 4
    la $a0, error
    syscall
    
    li $v0, 1
    li $a0, 301
    syscall
    
    la $a0, return
    li $v0, 4
    syscall
    
    j listcategories_end

newobject:
	addiu $sp, $sp, -4      # reserva espacio en el stack
	sw $ra, 4($sp)          # guarda el valor de retorno

	lw $t0, cclist          # cargar la lista actual
	beqz $t0, error_501     # si la lista está vacía llamar error 501

	la $a0, objName
	jal getblock          
	move $a2, $v0           # guardar dirección del bloque

	lw $t0, wclist          # obtener dirección de la lista de trabajo
	addi $a0, $t0, 4        # calcular dirección del siguiente objeto
	lw $t5, ($a0)           # verificar si el puntero es NULL
	bnez $t5, otherobject      # si no es NULL, saltar a manejar otro objeto

	li $a1, 1              
	jal addnode             # llamar a subrutina para agregar nodo
	j newobject_end
	
otherobject:
    	lw $t4, ($t5)
    	lw $t5, 4($t4)
    	addiu $a1, $t5, 1
    	jal addnode

newobject_end:
    	li $v0, 0
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    	
	
error_501:
	li $v0, 4
	la $a0, error
    	syscall
    	
    	li $v0, 1
	li $a0, 501
    	
    	syscall
	li $v0, 4
    	la $a0, return
    	syscall
    	li $v0, 501
    	jr $ra
	
listobjects:
	lw $t0, wclist
    	beqz $t0, error_601

    	lw $t1, 4($t0)
   	beqz $t1, error_602
    	move $t2, $t1

delobject_all:
	addiu $sp, $sp, -4           
    	sw $ra, 4($sp)               

    	lw $t0, wclist               # $t0 apunta a la categoría seleccionada
    	beqz $t1, error_602          # si lista está vacía, llamar errror_602

error_601:
	li $v0, 4
	la $a0, error
    	syscall
    	
    	li $a0, 601
    	li $v0, 1
    	syscall
    	
    	li $v0, 4
    	la $a0, return
    	syscall
    	
    	li $v0, 601
    	jr $ra
    	
error_602:  
	li $v0, 4
	la $a0, error
     	syscall
     	
    	li $a0, 602
    	li $v0, 1
    	syscall
    	
    	li $v0, 4
    	la $a0, return
       	syscall
       	
    	li $v0, 602
    	jr $ra
delobject:
    	addiu $sp, $sp, -4 #reserva word en stack
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_701
	
	
    	la $a0, idObj
    	li $v0, 4
    	syscall
     
    	li $v0, 5
    	syscall
    								
    	move $t1, $v0  # ID buscado
    	lw $t2, 4($t0) # Primer objeto
    	
    	#lw $t3, 4($t2) #ID del primer objeto
    	#blt $t1, $t3, not_found
    	
    	lw $t4, 0($t2) # ultimo objeto
    	lw $t3, 4($t4) #ID ultimo objeto
    	#bgt $t1, $t3, not_found
    	li $t5, 0
  
    	move $a1, $t2

       
delobj_loop:
    	lw $t3, 4($t2)
    	beq $t1, $t3, delobj_found
    	lw $t2, 12($t2)
    	bgt $t5, $t3, not_found
    	addiu $t5, $t5, 1
    	bne $t2, $zero, delobj_loop

delobject_end:		
    	lw $t0, wclist # cargar en $t0 la dirección del nodo actual
    	sw $zero, 4($t0)
    	li $v0, 0 

    	lw $ra, 4($sp)   # recuperar ra desde el stack.
    	addiu $sp, $sp, 4
    	jr $ra 

not_found:
	la $a0, not_found_msj
    	li $v0, 4
    	syscall
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

delobj_found:
    	lw $t4, 4($t0)
    	beq $t2, $t4, updateObjectList
    	
delobj_found_2:   
    	move $a0, $t2
    	jal delnode
    	lw $ra, 4($sp) # recupera el valor $ra desde $sp
    	addiu $sp, $sp, 4 # restablece la pila
   	jr $ra
    
updateObjectList:
    	lw  $t5, 12($t2)    
    	addiu $t4, $t0, 4   
    	seq $t6, $t5, $t2  # si el valor en $t5 es igual al valor en $t2 establece $t6 en 1; si no en 0.
    	bnez $t6, updateObjectList2 # si $t6 no es cero salta a updateObjectList2
    	sw  $t5, 0($t4)	
    	j   delobj_found_2
    
updateObjectList2:
    	sw  $zero, 0($t4)	# actualizar a 0
    	j   delobj_found_2   
    
error_701:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 701
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
   	li $v0, 701
    	jr $ra
    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list
addnode_to_end:
	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# update prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
addnode_empty_list:
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
addnode_exit:
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0
node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0) # $t0 nodo sgte; $t1 nodo anterior
	sw $t0, 12($t1) # almacenar nodo sgte en $t1
	lw $t1, 0($a1) # get address to first node
again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit
delnode_point_self:
	sw $zero, ($a1) # only one node; sobreescribir con 0
	#sw $zero, cclist
	#sw $zero, wclist
delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: msg to ask
# v0: block address allocated with string
getblock:
	addi $sp, $sp, -4
	sw $ra, 4($sp) # guardar valor $ra en el stack
	li $v0, 4 # pasa dirección como argumento
	syscall	
	jal smalloc
	move $a0, $v0
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp) # restaurar el valor de $ra
	addi $sp, $sp, 4 # devolver sp 
	jr $ra
	 
smalloc:
	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk:
	li $a0, 16 # node size fixed 4 words
	li $v0, 9  
	syscall # return node address in v0
	jr $ra
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address unused list
	jr $ra

