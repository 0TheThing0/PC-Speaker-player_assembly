Load_FilePart:
        ;In: cx - amount of data in chuncks
        push ds dx bx
        mov ax,3f00h
        xor dx,dx
        mov bx,[File_handler]
        mov ds,[sMusicBuffer]
        sub dword[es:DataSize],BLOCK_SIZE_IN_BYTES
        int 21h

        cmp ax,cx
        je .Next
                mov dword[es:DataSize],0
        .Next:
        push cs
        pop ds
        mov [ReadBytesAmount],ax
        mov [LoadData],0
        pop bx dx ds
ret

Open_File:
        ;Openning music file for read
        mov ax,3d00h
        int 21h
        ;ax - file handler
        mov [es:File_handler],ax
ret

Close_File:
        ;Close music file
        mov ax,3e00h
        mov bx,[File_handler]
        int 21h
ret

Allocate_Memory:
push bx
        ;4ah - Shrink a Memory Block, es - segment of an allocated memory block
        ;bx - size of block in paragraphs(16-byte chunks)
        mov ah,4ah
        ;1000h*16=65536 - size of programm to save stack
        mov bx,1000h
        ;!!! Just to be sure that cs=es (but it should be)
        push cs
        pop es
        int 21h
        ;in ax - error code, bx - largest block avaible

        ;48h - allocate memory block, bx - avaible size in chunks
        mov ah,48h
        mov bx,BLOCK_SIZE_IN_CHUNKS
        int 21h
        jnc .End
            push AllocateMemoryError
            call ShowError
            mov ax,4c00h
            int 21h

        ;ax - error code or segment addres, bx - avaible size in chunks
        .End:
        mov [sMusicBuffer],ax
pop bx
ret

Restore_Memory:
        push es
        mov ah,49h
        mov es,[sMusicBuffer]
        int 21h

        mov ah,49h
        mov es,[PlaylistBuffer]
        int 21h
        pop es
ret


Allocate_PlaylistMemory:
push bx
        ;48h - allocate memory block, bx - avaible size in chunks
        mov ah,48h
        mov bx,ALLOCATE_PLAYLIST_MEMORY
        int 21h
        jnc .End
            push AllocateMemoryError
            call ShowError
            mov ax,4c00h
            int 21h
        .End:
        ;ax - error code or segment addres, bx - avaible size in chunks
        mov [PlaylistBuffer],ax
pop bx
ret