; M5011.g: APPLY ROTATION COMPENSATION

; Default workOffset to the current workplace number if not specified
; with the W parameter.
var workOffset = { (exists(param.W) && param.W != null) ? param.W : move.workplaceNumber }


; WCS Numbers and Offsets are confusing. Work Offset indicates the offset
; from the first work co-ordinate system, so is 0-indexed. WCS number indicates
; the number of the work co-ordinate system, so is 1-indexed.
var wcsNumber = { var.workOffset + 1 }

if { var.workOffset < 0 || var.workOffset >= limits.workplaces }
    abort { "Work Offset (W..) must be between 0 and " ^ limits.workplaces-1 ^ "!" }

var hasRotation = { global.mosWPDeg[var.workOffset] != global.mosDfltWPDeg }

if { var.hasRotation }

    M291 P{"Workpiece in WCS " ^ var.wcsNumber ^ " is rotated by " ^ global.mosWPDeg[var.workOffset] ^ " degrees. Apply compensation?"} R{"MillenniumOS: Workpiece Rotation Compensation"} S4 K{"Yes","No"} F0
    if { input != 0 }
        echo { "MillenniumOS: Rotation compensation not applied."}
        ; Cancel any existing rotation applied
        G69
        M99

    ; Rotate the workpiece around the origin.
    ; Use corner position if available (for corner probes), otherwise use center position, otherwise use (0,0)
    var rotationCenterX = { global.mosWPCnrPos[var.workOffset] != null ? global.mosWPCnrPos[var.workOffset][0] : (global.mosWPCtrPos[var.workOffset] != null ? global.mosWPCtrPos[var.workOffset][0] : 0) }
    var rotationCenterY = { global.mosWPCnrPos[var.workOffset] != null ? global.mosWPCnrPos[var.workOffset][1] : (global.mosWPCtrPos[var.workOffset] != null ? global.mosWPCtrPos[var.workOffset][1] : 0) }
    
    G68 X{var.rotationCenterX} Y{var.rotationCenterY} R{global.mosWPDeg[var.workOffset]}

    ; Determine the rotation center type for the message
    var rotationCenterType = { global.mosWPCnrPos[var.workOffset] != null ? "corner" : (global.mosWPCtrPos[var.workOffset] != null ? "center" : "origin") }
    echo { "MillenniumOS: Rotation compensation of " ^ global.mosWPDeg[var.workOffset] ^ " degrees applied around " ^ var.rotationCenterType ^ "." }
else
    ; Cancel any existing rotation applied
    G69