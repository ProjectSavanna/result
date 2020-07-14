local
  signature DATATYPE =
    sig
      datatype 'a t = Value of 'a | Raise of exn | Timeout of Time.time
    end
in
  signature RESULT =
    sig
      include MONAD DATATYPE

      val evaluate : Time.time -> ('a -> 'b) -> 'a -> 'b t

      exception Result
      val valOf : 'a t -> 'a

      val toString : ('a -> string) -> 'a t -> string
    end
end
