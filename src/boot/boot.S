							.org				0													# Specifica l'offset del file, impostandolo a 0

							.section			.data
							.code16																	# Notifica il codice a 16 bits

							#																		#
							# General Descriptor Table.												#
							#																		#
							# Questa tabella (con tutti i vari dati) serve nello step per il 		#
							# passaggio alla modalità a 32 bits. Descriverà con dei valori di 		#
							# default il code selector e il data selector.							#
							#																		#

							.global				DATA_SEG											# Rendi globale il DATA_SEG
							.global				CODE_SEG											# ... il CODE_SEG

gdt_start:
gdt_null:
							.quad 				0x0000000000000000									# Definisci una entry nulla per la GDT

gdt_code:
							.word				0xffff												# Limite segmento
							.word				0x0													# Base della GDT
							.byte				0x0													# Base 16-23
							.byte				0x9a												# Byte di accesso
							.byte				0b11001111											# Flags 4 bits, alto e basso
							.byte				0													# Dati base finali

gdt_data:
							.word				0xffff												# Limite segmento
							.word				0x0													# Base della GDT
							.byte				0x0													# Base 16-23
							.byte				0x92												# Byte di accesso
							.byte				0b11001111											# Flags 4 bits, alto e basso
							.byte				0													# Dati base finali

gdt_end:

gdt_descriptor:
							.word 				gdt_end - gdt_start - 1								# Dimensione della tabella
							.long 				gdt_start											# Offset della tabella

segments:
							.equ				CODE_SEG, gdt_code - gdt_start						# Segmento di codice
							.equ				DATA_SEG, gdt_data - gdt_start						# Segmento dei dati

							.section			.text
							.code16																	# Notifica il codice a 16 bits

							.global				_start												# Rendi la label _start globale per essere utilizzata come entry

_start:	
							jmp					.step1												# Esegui uno short jump per evitare problemi con il BIOS Parameter Block
							nop																		# Scrivi un NOP nel file .BIN

							.fill				33, 1, 0											# Riempi 33 spazi con degli 0, in modo da lasciare lo spazio al B.P.B

.step1:	
							jmp					$0,$.step2											# Salta alla funzione start_step_2 con segmento 0x7c0

.step2:	
							cli																		# Pulisci gli interrupts
							mov					$0x00, %ax											# Si utilizza AX per impostare i valori nei vari registri di segmentazione
							mov					%ax, %ds											# Imposta il data segment al valore di AX
							mov					%ax, %es											# Imposta l'extra segment ...
							mov					$0x00, %ax											# Cambia il valore di AX a 0
							mov					%ax, %ss											# Imposta lo stack segment a 0
							mov					$0x7c00, %sp										# Imposta lo stack pointer a 0x7c00 (valore assoluto)
							sti																		# Abilita gli interrupts

.load_protected_mode:

							cli																		# Sospendi gli interrupts

							lgdt				gdt_descriptor										# Carica la global descriptor table
							mov					%cr0, %eax											# Muovi il valore nel registro CR0 in EAX
							or					$0x1, %eax											# Esegui l'operazione OR sul bit più basso di EAX
							mov					%eax, %cr0											# Aggiorna CR0 abilitando la protected mode

							jmp					$CODE_SEG,$_start32									# Salta alla parte in 32 bits del boot loader
