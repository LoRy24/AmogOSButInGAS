_code_start:																						# Inizio del codice (file GAS)

							.section 			.text
							.code32																	# Notifica la modalità a 32 bits

							.global				_kernel_entry										# Rendi la label "_kernel_entry" globale
							.extern				k_main												# Importa la funzione principale del kernel

_kernel_entry:
							mov					$DATA_SEG, %ax										# Sposta il segmento di dati in AX
							mov					%ax, %ds											# Sposta il segmento di dati salvato in AX in ds
							mov					%ax, %es											# ... in es
							mov					%ax, %fs											# ... in fs
							mov					%ax, %gs											# ... in gs
							mov					%ax, %ss											# ... in ss
							mov					$0x00200000, %ebp									# Imposta il base pointer a 0x00200000 (EBP)
							mov					%ebp, %esp											# Fai lo stessoo anche per lo stack poointer (ESP)

							in					$0x92, %al											# Leggi il valore del bus all'indirizzo 0x92 e caricalo in AL
							or					$0x02, %al											# Esegui l'operazione OR con valore 0x2 sul registro AL
							out					%al, $0x92											# Rimanda al bus il nuovo valore, abilitando la A20 Line

							call				k_main												# Chiama la funzione principale del kernel
							jmp					.													# Salta all'infinito

							.equ				CODE_SEG, 0x08										# Segmento di codice
							.equ				DATA_SEG, 0x10										# Segmento dei dati

align:
							.fill 				(512 - (. - _code_start)), 1, 0						# Allinea il kernel.S