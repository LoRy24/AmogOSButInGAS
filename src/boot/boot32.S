							.org				0													# Specifica l'offset del file, impostandolo a 0

							.section			.data
							.code32																	# Notifica il codice a 32 bits
							
							.section			.text
							.code32																	# Notifica il codice a 32 bits
							
							.global				_start32											# Rendi globale la label "_start32"

_start32:
							mov					$0x01, %eax											# Settore dal quale iniziare la lettura (0 = boot sec.)
							mov					$0x64, %ecx											# Leggi 100 settori
							mov					$0x0100000, %edi									# Indirizzo del buffer (1M nella memoria)
							call				ata_lba_read

							jmp					$CODE_SEG,$0x0100000								# Salta all'indirizzo della funzioone principale del kernel

ata_lba_read:
							mov					%eax, %ebx											# Salva l'LBA per un uso futuro

.step1:																								# Invia gli 8 bits dell'LBA più alti al controller dell'Hard Disk.
							shr					$0x18, %eax											# Shifta verso destra il registro EAX di 24 bits
							or					$0xE0, %eax											# Seleziona il drive principale
							mov					$0x1F6, %dx											# Prepara la scrittura degli 8 bits, passando a DX l'indirizzo del bus
							out					%al, %dx 											# Scrivi attraverso il bus gli 8 bits. Con questa istruzione si completa lo step

.step2:																								# Invia il numero di settori da leggere
							mov					%ecx, %eax											# Sposta in EAX i settori da leggere
							mov					$0x1F2, %dx											# Passa l'indirizzo del bus a DX
							out					%al, %dx											# Invia i dati al bus

.step3:																								# Invia ulteriori bits dell'LBA
							mov					%ebx, %eax											# Ripristina il valore di EAX messo da parte
							mov					$0x1F3, %dx											# Passa l'indirizzo del bus a DX 
							out					%al, %dx											# Invia i dati al bus				

.step4:																								# Invia ulteriori bits dell'LBA
							mov					%ebx, %eax											# Ripristina nuovamente il valore di EAX messo da parte
							shr					$0x08, %eax											# Shifta il registro EAX di 8 bits verso destra
							mov					$0x1F4, %dx											# Passa l'indirizzo del bus a DX 
							out					%al, %dx											# Invia i dati al bus
							
.step5:																								# Invia i 16 bits alti dell'LBA
							mov					%ebx, %eax											# Ripristina il valore di EAX messo da parte
							shr					$0x10, %eax											# Shifta il registro EAX di 16 bits verso destra
							mov					$0x1F5, %dx											# Passa l'indirizzo del bus a DX 
							out					%al, %dx											# Invia i dati al bus

.step6:
							mov					$0x1F7, %dx											# Passa l'indirizzo del bus a DX 
							mov					$0x20, %al											# Passa ad AL il valore che indica di ritentare la lettura
							out					%al, %dx											# Invia i dati al bus

.next_sector:																						# Leggi tutti i settori nella memoria
							push				%ecx												# Salva ECX per dopo

.try_again:																							# Controlla se sia necessaria la lettura
							mov					$0x1F7, %dx											# Passa la porta del bus di lettura in DX
							in					%dx, %al											# Leggi dal bus e sposta il valore in AL
							test				$0x08, %al											# Controlla se i bits sono stati impostati correttamente secondo la bitmask 0x08
							jz					.try_again											# Nel caso in cui non siano stati impostati correttamente, ritenta

.tstep1:																							# Si rende necessario leggere 256 parole alla volta
							mov					$0x100, %ecx										# Specifica la quantità di parole da leggere (256)
							mov					$0x1F0, %dx											# Imposta la porta del bus
							rep					insw												# Leggi una parola e salvala nel buffer situato ad ES:OFFSET
							pop					%ecx												# Ripristina il numero di settori da leggere
							loop				.next_sector										# Esegui in loop per 100 volte (in questo caso)
.end:
							ret																		# Ritorna il controllo al caller
