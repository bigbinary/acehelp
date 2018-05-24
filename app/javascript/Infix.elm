module Infix exposing (..)

-- Create a Tuple using =>


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>
