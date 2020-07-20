signature RESULT =
  sig
    datatype 'a result = Value of 'a | Raise of exn | Timeout of Time.time

    include MONAD where type 'a t = 'a result

    val evaluate : Time.time -> ('a -> 'b) -> 'a -> 'b t

    exception Result
    val valOf : 'a t -> 'a

    val toString : ('a -> string) -> 'a t -> string
  end
