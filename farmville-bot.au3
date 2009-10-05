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
global const $FV_BORDER_X = 213
; Y gap between FireFox and FarmVille
global const $FV_BORDER_Y = 257

; Color we are looking for to harvest
global const $FV_HARVEST_SEARCH_COLOR = 0x95e303

; FarmVille window title
global const $FV_TITLE = "FarmVille on Facebook - Mozilla Firefox"

; Size of your field
global const $FV_FIELD_SIZE = 14

global $harvest_pos = 0

; Kills the bot if you hit Pause
HotKeySet("{PAUSE}", "FVExit")
HotKeySet("{F6}", "FVGetHarvestPos")

FVGuiInit()

Func FVGuiInit()
    GuiCreate("FarmVille Bot", 600, 400)
    $harvest_button = GuiCtrlCreateButton("Harvest Tree", 10, 10)
    $exp_button = GUICtrlCreateButton("Harvest Experience", 10, 50)

    GuiSetState(@SW_SHOW)

    While 1
        $msg = GuiGetMsg()

        Select
            Case $msg = $harvest_button
                FVStartHarvest()
            Case $msg = $exp_button
                If $harvest_pos == 0 Then
                    MsgBox(0, "FarmVille Bot Error", "You must first hover over the bottom-right crop and hit F6.")
                Else
                    FVHarvestField($harvest_pos)
                EndIf
        EndSelect
    WEnd
EndFunc

Func FVStartHarvest()
    $search_area = FVGetSearchArea()

    While Not @error
        $harvest_pos = PixelSearch($search_area[0], $search_area[1], $search_area[2], $search_area[3], $FV_HARVEST_SEARCH_COLOR, 0)

        If Not @error Then
            FVHarvestTree($harvest_pos)
        EndIf
    WEnd

    MsgBox(0, "FarmVille Bot Error", "No more trees to harvest")
EndFunc

Func FVHarvestTree($tree_pos)
    MouseClick("left", $tree_pos[0], $tree_pos[1])

    Sleep(500)

    $harvestX = $tree_pos[0] + 4
    $harvestY = $tree_pos[1] + 50

    MouseClick("left", $harvestX, $harvestY)
EndFunc

Func FVGetSearchArea()
    local $fv_size[4]

    $win_pos = WinGetPos($FV_TITLE)

    $fv_size[0] = $win_pos[0] + $FV_BORDER_X
    $fv_size[1] = $win_pos[1] + $FV_BORDER_Y
    $fv_size[2] = $fv_size[0] + $FV_WIDTH
    $fv_size[3] = $fv_size[1] + $FV_HEIGHT

    return $fv_size
EndFunc

Func FVGetHarvestPos()
    global $harvest_pos = MouseGetPos()
EndFunc

Func FVHarvestField($start_pos)
    local $harvest_pos = $start_pos

    For $i = 1 To $FV_FIELD_SIZE Step 1
        For $j = 1 To $FV_FIELD_SIZE Step 1
            FVHarvest($harvest_pos)

            $harvest_pos[0] -= 25
            $harvest_pos[1] -= 12
        Next

        $harvest_pos[0] = $start_pos[0] + (25 * $i)
        $harvest_pos[1] = $start_pos[1] - (12 * $i)
    Next
EndFunc

Func FVHarvest($harvest_pos)
    MouseMove($harvest_pos[0], $harvest_pos[1])

    Sleep(350)
EndFunc

Func FVExit()
    Exit
EndFunc
