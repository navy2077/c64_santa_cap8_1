;==============================================================================
; Constants

PlayerFrame             = 1
PlayerHorizontalSpeed   = 2
PlayerVerticalSpeed     = 1
PlayerXMinHigh          = 0     ; 0*256 + 24 = 24  minX
PlayerXMinLow           = 24
PlayerXMaxHigh          = 1     ; 1*256 + 64 = 320 maxX
PlayerXMaxLow           = 64
PlayerYMin              = 180
PlayerYMax              = 229 

;===============================================================================
; Variables

playerSprite    byte 0
playerXHigh     byte 0
playerXLow      byte 175
playerY         byte 229
playerXChar     byte 0
playerXOffset   byte 0
playerYChar     byte 0
playerYOffset   byte 0

;===============================================================================
; Macros/Subroutines

gamePlayerInit
        
        LIBSPRITE_ENABLE_AV             playerSprite, True
        LIBSPRITE_SETFRAME_AV           playerSprite, PlayerFrame
        LIBSPRITE_SETCOLOR_AV           playerSprite, LightGray
        LIBSPRITE_MULTICOLORENABLE_AV   playerSprite, True
        
        rts

;===============================================================================

gamePlayerUpdate      

        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateFiring

        rts

;==============================================================================

gamePlayerUpdateFiring

        ; do fire after the ship has been clamped to position
        ; so that the bullet lines up
        LIBINPUT_GETFIREPRESSED
        bne gPUFNofire
     
        GAMEBULLETS_FIRE_AAAVV playerXChar, playerXOffset, playerYChar, White, True
gPUFNofire

        rts

;===============================================================================

gamePlayerUpdatePosition

        LIBINPUT_GETHELD GameportLeftMask
        bne gPUPRight
        LIBMATH_SUB16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gPUPRight
        LIBINPUT_GETHELD GameportRightMask
        bne gPUPUp
        LIBMATH_ADD16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gPUPUp
        LIBINPUT_GETHELD GameportUpMask
        bne gPUPDown
        LIBMATH_SUB8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY
gPUPDown
        LIBINPUT_GETHELD GameportDownMask
        bne gPUPEndmove
        LIBMATH_ADD8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY        
gPUPEndmove
        
        ; clamp the player x position
        LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxHigh, PLayerXMaxLow
        LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinHigh, PLayerXMinLow
        
        ; clamp the player y position
        LIBMATH_MIN8BIT_AV playerY, PlayerYMax
        LIBMATH_MAX8BIT_AV playerY, PlayerYMin

        ; set the sprite position
        LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, PlayerXLow, PlayerY

        ; update the player char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerXHigh, playerXLow, 12, playerY, 40, playerXChar, playerXOffset, playerYChar, playerYOffset

        rts


