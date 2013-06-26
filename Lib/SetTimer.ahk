/*
    AutoHotkey: Asynchronous Timer API (SetTimer)
    Copyright © 2013 Donald Atkinson (a.k.a. FuzzicalLogic)
    ----------------------------------------------------------------------------
    
    Provides a convenience API Class and Function for reducing the code required
    to utilize Asynchronous Timers. This makes AsyncTimer stdlib compliant and 
    allows two distinct methods for include:
    
        - Call SetTimer()
        - include <settimer.ahk>
        
    SetTimer: A completely abstracted way to create disposable timers. Parameters
    are as follows:
    
        - callback (string)  - The function to callback. This may also be a global
             or static identifier/expression to an object's method.
        - time     (integer) - The lifetime (ms) of the Timer.
        - interval (integer) - The frequency (ms) of the Timer messages.
        - message  (integer) - The Windows Message ID.
        
    AsyncTimer Class:
    A convenience API for creating and managing disposable and reusable timers.
    This also automates several tasks for you, including getting the hwnd of the
    current script and retrieving the hwnd of the timer.
    
        Methods:
        - Start()
        - Pause()
        - Resume()
        - Stop(keep := false)
    ----------------------------------------------------------------------------
*/

SetTimer(pCallback := 0, pTime, pInterval := 0, pMessage := 0) {
    timer = new AsyncTimer()
    
    if (message)
        timer.Message(message)
    return timer.Start()
}

/*
    Methods:
      Start
      Pause
      Resume
      Stop
*/
class AsyncTimer extends AsyncTimerPrivate {
    static DEFAULT_MSG
    
    static hwnd := 0
    static path := A_ScriptDir "\Lib\"
    msg := AsyncTimer.DEFAULT_MSG
    callback := ""
    
    disposable := false
    
    __New(pCallback := 0, pTime := 0, pInterval := 0) {
        if (!AsyncTimer.hwnd)
            AsyncTimer.hwnd := getHWND()
            
        if (!pCallback) {
            this.callback := pCallback
        }
        else {
        ; Error Handling here...
        }
    }
        
    Start() {
        OnMessage(this.msg, this.callback)
        base.Run()
    ; Chain the function
        return this
    }
    
    Pause() {
        PostMessage(base.MSG_PAUSE_ID, 0, 0, , % "ahk_id " this.window)
    ; Chain the function
        return this
    }
    
    Resume() {
        PostMessage(base.MSG_RESUME_ID, 0, 0, , % "ahk_id " this.window)
    ; Chain the function
        return this
    }
    
    Stop(dispose := 1) {
        PostMessage(base.MSG_STOP_ID, 0, 0, , % "ahk_id " this.window)
        
    ; Now, we decide whether to keep it in the TIMERS array
        if (!keep) {
            if keep is integer {
                keep := this.keepAlive
            }
        }
        
        if (!keep)
        
    ; Chain the function
        return this
    }
    
    Debug(value := 0) {
    ; Interrupt the Message
        this.debug := ! this.debug
        
        if (this.debug && this.running) {
            OnMessage(this.msg, "AsyncTimerDebug")
        }
        else (this.running && !(this.debug)) {
            OnMessage(this.msg, this.callback)
        }
        
    ; Chain the function
        return this
    }
    
}
class AsyncTimerPrivate {
    static MSG_STOP_ID   := 0x0400
    static MSG_PAUSE_ID  := 0x0401
    static MSG_RESUME_ID := 0x0402
    
    static TIMERS := []
    
    getHWND() {
    ; Just in case
        old := A_DetectHiddenWindows
		DetectHiddenWindows, on
        AsyncTimer.hwnd := WinExist("Ahk_PID " DllCall("GetCurrentProcessId"))
    ; Just in case - Preserve the old setting
        DetectHiddenWindows, %old%
    }
    
    Run() {
    ; Build the Parameters string
        params := "/hwnd " . getHWND() . " /msg " . this.msg
        if (this.id)
            params := params . " /id " . this.id
        if (this.lifetime)
            params := params . " /time " . this.lifetime
        if (this.interval)
            params := params . " /interval " . this.interval
        if (this.debug)
            params := params . " /debug"
    ; Run the Script/Executable
        Run, % AsyncTimer.path asynctimer.exe " " params
    }
}

; TODO: Implement debug
;       Requires (a) connecting to hwnd
;       Requires (b) creating static array
AsyncTimerOnMessageProxy(wParam, lParam, msg, hwnd) {
    t := AsyncTimer.get(wParam)
; Gets the hwnd of the Timer so that Pause/Resume/Stop work correctly
    if (! t.hwnd)
        t.hwnd := hwnd
; Call the Resolver

    fxn()
}

AsyncTimerDebug(wParam, lParam, msg, hwnd) {
    
}

ResolveFunction(name) {
; Begin the Callback Expression Resolution Array
    resolve := []
;    scan := t.callback
    scan := name
    While scan {
        pos := InStr(scan, ".") 
        if (pos) {
            expression := SubStr(scan, 1, pos - 1)
            scan := SubStr(scan, pos + 1)
        }
        else {
            expression = %scan%
            scan := 0
        }
        resolve[%A_Index%] = expression
    }
; Call the Function
    Loop % Array.MaxIndex() {
        e := resolve[%A_Index%]
        fxn := %e%
    }
    return fxn
}
