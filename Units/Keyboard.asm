Process_Keyboard:
   mov ah,01h
   int 16h
   jz _NoKey
      mov ah,00h
      int 16h

      cmp ah,0fh
      je _SwitchWindow

      cmp ah,2ch
      je _ChangeRandom

      cmp ah,19h
      je _PlayPlaylist

      cmp ah,1h
      je Esc_Key

      call [ProcessKeyWindow]
      jmp _NoKey

      _SwitchWindow:
        call [LineDrawFunction]
        movzx ax,[CurrentWindow]
        inc ax
        cmp ax,WINDOWS_AMOUNT
        jne _NoNewRow
          mov ax,0
        _NoNewRow:
        mov [CurrentWindow],al

        mov bx,WindowFunctions
        mov cx,DrawFunctions
        shl ax,1
        add bx,ax
        add cx,ax

        ;call RecolorWindow

        mov ax,[bx]
        mov [ProcessKeyWindow],ax
        mov bx,cx
        mov ax,[bx]
        mov [LineDrawFunction],ax
        call [LineDrawFunction]
        jmp _NoKey

    _ChangeRandom:
        call ChangeRandomState
        jmp _NoKey

    _PlayPlaylist:
        mov cl,0
        call Play_PlaylistFile
        jmp _NoKey

    Esc_Key:
        mov [EndProg],1

   _NoKey:
ret


DriveWindowKey:
      cmp ah,4bh
      je Left_Key_DW

      cmp ah,4dh
      je Right_Key_DW

      cmp ah,1ch
      je Enter_Key_DW
      jmp _NoKey_DW

      Left_Key_DW:
        call Draw_ChooseDrive
        mov al,[CurrentDrivePos]
        dec al
        cmp al,-1
        jne _No_Dec_Row_DW
            mov al,[DrivesAmount]
            dec al
        _No_Dec_Row_DW:

        mov [CurrentDrivePos],al
        call Draw_ChooseDrive
        jmp _NoKey_DW


      Right_Key_DW:
        call Draw_ChooseDrive
        mov al,[CurrentDrivePos]
        inc al
        cmp al,[DrivesAmount]
        jb _No_Inc_Row_DW
            mov al,0
        _No_Inc_Row_DW:

        mov [CurrentDrivePos],al
        call Draw_ChooseDrive
        jmp _NoKey_DW

       Enter_Key_DW:
        mov bx,DrivesList
        mov al,byte[CurrentDrivePos]

        add bl,al
        adc bh,0

        mov al,[bx]
        sub al,'@'

        mov dh,[CurrentDrive]
        mov [CurrentDrive],al
        push ds
        mov ah,32h
        mov dl,al
        int 21h
        pop ds
        cmp al,0h
        je NoDriveError
            push OpenDriveError
            call ShowError
            mov [CurrentDrive],dh
        NoDriveError:

        call Create_BaseDirPath
        call Open_Directory
        call Draw_ChooseLine
        jmp _NoKey_DW

      _NoKey_DW:
ret

LeftWindowKey:
      cmp ah,48h; Up
      je Up_Key_LW

      cmp ah,50h
      je Down_Key_LW

      cmp ah,1ch
      je Enter_Key_LW

      cmp ah,1eh
      je A_Key_LW

      jmp _NoKey_LW

    Up_Key_LW:
        mov ax,-1
        cmp [CurrentFile],0
        jne ProcessInside_LW
        call StepUp_LW
        jmp _NoKey_LW

    Down_Key_LW:
        mov ax,[FirstShowFile]
        add ax,[CurrentFile]
        inc ax
        cmp ax,[FilesAmount]
        jae _NoKey_LW
        mov ax,1
        cmp [CurrentFile],MAX_FILES_AMOUNT-1
        jne ProcessInside_LW
        call StepDown_LW
        jmp _NoKey_LW

    Enter_Key_LW:
        call Process_File
        jmp _NoKey_LW

    A_Key_LW:
        call Add_File
        jmp _NoKey_LW

    ProcessInside_LW:
        call Draw_ChooseLine
        add word[CurrentFile],ax
        call Draw_ChooseLine
    _NoKey_LW:
ret


StepUp_LW:
    cmp [FirstShowFile],0
    je .End
    dec word[FirstShowFile]
    mov [CurrentRow], WINDOW_START_LINE
    call Draw_ChooseLine
    call Output_Directory
    call Draw_ChooseLine
    .End:
ret

StepDown_LW:
    mov ax,[FilesAmount]
    sub ax,MAX_FILES_AMOUNT
    cmp [FirstShowFile],ax
    jg .End
    inc word[FirstShowFile]
    mov [CurrentRow], WINDOW_START_LINE
    call Draw_ChooseLine
    call Output_Directory
    call Draw_ChooseLine
    .End:
ret

RightWindowKey:
      cmp ah,48h; Up
      je Up_Key_RW

      cmp ah,50h
      je Down_Key_RW

      cmp ah,1ch
      je Enter_Key_RW

      cmp ah,13h
      je R_Key_RW

      jmp _NoKey_RW

    Up_Key_RW:
        mov ax,-1
        cmp [CurrentPlaylistFile],0
        jne ProcessInside_RW
        call StepUp_RW
        jmp _NoKey_RW

    Down_Key_RW:
        movzx ax,[FirstShowPlaylistFile]
        add al,[CurrentPlaylistFile]
        inc ax
        cmp al,[CurrentPlaylistAmount]
        jae _NoKey_RW
        mov ax,1
        cmp [CurrentPlaylistFile],MAX_FILES_AMOUNT-1
        jne ProcessInside_RW
        call StepDown_RW
        jmp _NoKey_RW

    Enter_Key_RW:
        mov cl,[FirstShowPlaylistFile]
        add cl,[CurrentPlaylistFile]
        call Play_PlaylistFile


        jmp _NoKey_RW

    R_Key_RW:
        call Remove_File
        jmp _NoKey_RW

    ProcessInside_RW:
        call Draw_PlaylistLine
        add byte[CurrentPlaylistFile],al
        call Draw_PlaylistLine
    _NoKey_RW:
ret


StepUp_RW:
    cmp [FirstShowPlaylistFile],0
    je .End
    dec byte[FirstShowPlaylistFile]
    call Draw_PlaylistLine
    call Output_Playlist
    call Draw_PlaylistLine
    .End:
ret

StepDown_RW:
    movzx ax,[CurrentPlaylistAmount]
    sub ax,MAX_FILES_AMOUNT
    cmp [FirstShowPlaylistFile],al
    jg .End
    inc byte[FirstShowPlaylistFile]
    call Draw_PlaylistLine
    call Output_Playlist
    call Draw_PlaylistLine
    .End:
ret
