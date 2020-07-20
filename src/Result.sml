structure Result :> RESULT =
  struct

    datatype 'a result = Value of 'a | Raise of exn | Timeout of Time.time

    type 'a t = 'a result


    (* Inspired by https://github.com/msullivan/sml-util/blob/master/libs/timeout.sml *)
    local
      fun finally f final =
        f () before ignore (final ())
          handle e => (final (); raise e)

      val timer = SMLofNJ.IntervalTimer.setIntTimer

      fun cleanup () = ignore (
        timer NONE;
        Signals.setHandler (Signals.sigALRM, Signals.IGNORE)
      )
    in
      fun evaluate timeout f x =
        let
          val ret = ref (Timeout timeout)
          fun eval k = (
            Signals.setHandler (Signals.sigALRM, Signals.HANDLER (fn _ => k));
            timer (SOME timeout);
            ret := (Value (f x) handle e => Raise e)
          )
          val () = finally (fn () => SMLofNJ.Cont.callcc eval) cleanup
        in
          !ret
        end
    end

    val map = fn f => fn
      Value x   => Value (f x)
    | Raise e   => Raise e
    | Timeout t => Timeout t

    val return = Value

    local
      val mapPartial = fn f => fn
        Value x   => f x
      | Raise e   => Raise e
      | Timeout t => Timeout t
      infix 1 >>=
      val op >>= = fn (x,f) => mapPartial f x
    in
      val compose = fn (f,g) => mapPartial g o f
      val bind = op >>=
      val seq = fn (x,y) => x >>= Fn.const y
      val join = fn x => x >>= Fn.id
    end

    exception Result
    val valOf = fn
      Value x => x
    | _ => raise Result

    val toString = fn f => fn
      Value x   => f x
    | Raise e   => "uncaught exception " ^ General.exnName e ^ " [" ^ General.exnMessage e ^ "]"
    | Timeout t => "timed out after " ^ Time.fmt 1 t ^ "s"

  end
