#cs ---------------------------------------------------------------------------

 Copyright (c) 2009 Jim Mitchener <jcm@packetpan.org>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ce ---------------------------------------------------------------------------

#include <GUIConstantsEx.au3>

; Width of FarmVille flash app
global const $FV_WIDTH = 760
; Height of FarmVille flash app
global const $FV_HEIGHT = 594

; X gap between FireFox and FarmVille
global const $FV_BORDER_X = 50
; Y gap between FireFox and FarmVille
global const $FV_BORDER_Y = 257

; Color we are looking for to harvest
global const $FV_HARVEST_SEARCH_COLOR = 0x95e303

; Color of the "Accept" button from in-game popups
global const $FV_ACCEPT_COLOR = 0x94bc41

; Color of the Facebook popup "Skip" button
global const $FV_FACEBOOK_SKIP_COLOR = 0xf0f0f0

; FarmVille window title
global const $FV_TITLE = "FarmVille on Facebook - Mozilla Firefox"

; Size of your field
global const $FV_FIELD_SIZE = 14

global $stop_harvest = False

global $harvest_pos = 0
global $plow_pos = 0
global $market_pos = 0
global $soybean_pos = 0
global $delete_pos = 0

HotKeySet("{Pause}", "FVStopHarvest")
HotKeySet("{F5}", "FVSetHarvestPos")
HotKeySet("{F6}", "FVSetMarketPos")
HotKeySet("{F7}", "FVSetSoybeanPos")

FVGuiInit()

Func FVGuiInit()
    GuiCreate("FarmVille Bot", 600, 400)

    $tree_button = GuiCtrlCreateButton("Harvest Trees", 10, 10)
    $field_button = GUICtrlCreateButton("Harvest/Plow Field", 10, 40)
    $exp_button = GUICtrlCreateButton("Farm Exp", 10, 70)

    GuiSetState(@SW_SHOW)

    While 1
        $msg = GuiGetMsg()

        Select
            Case $msg = $tree_button
                FVStartHarvest()
            Case $msg = $field_button
                If $harvest_pos == 0 Then
                    FVError("You must first hover over the bottom-right crop and hit F5.")
                Else
                    FVHarvestField($harvest_pos)
                EndIf
            Case $msg = $exp_button
                FVHarvestExp()
            Case $msg = $GUI_EVENT_CLOSE
                ExitLoop
                FVExit()
        EndSelect
    WEnd
EndFunc

Func FVStartHarvest()
    $search_area = FVGetSearchArea()
    global $stop_harvest = False

    While Not $stop_harvest
        $harvest_pos = PixelSearch($search_area[0], $search_area[1], $search_area[2], $search_area[3], $FV_HARVEST_SEARCH_COLOR, 0)

        If Not @error Then
            FVHarvestTree($harvest_pos)
        EndIf
    WEnd

    FVError("Sorry, I couldn't find any more trees to harvest.")
EndFunc

Func FVHarvestTree($tree_pos)
    MouseClick("left", $tree_pos[0], $tree_pos[1])

    Sleep(500)

    $harvestX = $tree_pos[0] + 4
    $harvestY = $tree_pos[1] + 50

    MouseClick("left", $harvestX, $harvestY)
EndFunc

Func FVHarvestExp()
    global $stop_harvest = False

    While Not $stop_harvest
        MouseClick("left", $plow_pos[0], $plow_pos[1])
        MouseClick("left", $harvest_pos[0], $harvest_pos[1])

        MouseClick("left", $market_pos[0], $market_pos[1])

        Sleep(750)

        MouseClick("left", $soybean_pos[0], $soybean_pos[1])
        MouseClick("left", $harvest_pos[0], $harvest_pos[1])

        Sleep(900)

        MouseClick("left", $delete_pos[0], $delete_pos[1])
        MouseClick("left", $harvest_pos[0], $harvest_pos[1])

        Sleep(500)

        FVAccept()
    WEnd
EndFunc

Func FVGetSearchArea()
    local $fv_size[4]


    $win_size = WinGetClientSize($FV_TITLE)
    $win_pos = WinGetPos($FV_TITLE)

    $fv_size[0] = $win_pos[0] + $FV_BORDER_X
    $fv_size[1] = $win_pos[1] + $FV_BORDER_Y
    $fv_size[2] = $win_pos[0] + $win_size[0] - $FV_BORDER_X
    $fv_size[3] = $fv_size[1] + $FV_HEIGHT

#cs
    MouseMove($fv_size[0], $fv_size[1])
    Sleep(500)
    MouseMove($fv_size[2], $fv_size[1])
    Sleep(500)
    MouseMove($fv_size[2], $fv_size[3])
    Sleep(500)
    MouseMove($fv_size[0], $fv_size[3])
#ce

    return $fv_size
EndFunc

Func FVSetHarvestPos()
    global $harvest_pos = MouseGetPos()
EndFunc

Func FVSetMarketPos()
    global $market_pos = MouseGetPos()

    ; Get plow and delete position via their offset from market

    global $plow_pos = $market_pos
    $plow_pos[1] -= 58

    global $delete_pos = $plow_pos
    $delete_pos[0] += 45
EndFunc

Func FVSetSoybeanPos()
    global $soybean_pos = MouseGetPos()
EndFunc

Func FVHarvestField($start_pos)
    local $harvest_pos = $start_pos

    global $stop_harvest = False

    For $i = 1 To $FV_FIELD_SIZE Step 1
        For $j = 1 To $FV_FIELD_SIZE Step 1
            FVHarvest($harvest_pos)

            $harvest_pos[0] -= 25
            $harvest_pos[1] -= 12

            If $stop_harvest Then
                ExitLoop
            EndIf
        Next

        If $stop_harvest Then
            ExitLoop
        EndIf

        $harvest_pos[0] = $start_pos[0] + (25 * $i)
        $harvest_pos[1] = $start_pos[1] - (12 * $i)
    Next
EndFunc

Func FVAccept()
    $search_area = FVGetSearchArea()

    $accept_pos = PixelSearch($search_area[0], $search_area[1], $search_area[2], $search_area[3], $FV_ACCEPT_COLOR, 0)

    If Not @error Then
        MouseClick("left", $accept_pos[0], $accept_pos[1])
    EndIf

    ; Now we check for the Facebook popups

    ; Check right half to stop collision with FarmVille graphic
    $skip_left = $search_area[0] + ($search_area[2] - $search_area[0])/2

    $skip_pos = PixelSearch($skip_left, $search_area[1], $search_area[2], $search_area[3], $FV_FACEBOOK_SKIP_COLOR, 0)

    If Not @error Then
        MouseClick("left", $skip_pos[0], $skip_pos[1])
    EndIf
EndFunc

Func FVHarvest($harvest_pos)
    MouseClick("left", $harvest_pos[0], $harvest_pos[1])
EndFunc

Func FVError($msg)
    MsgBox(0, "FarmVille Bot Error", $msg)
EndFunc

Func FVStopHarvest()
    global $stop_harvest = True
EndFunc

Func FVExit()
    Exit
EndFunc
