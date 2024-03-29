{- | CSE 130: All about fold.

     For this assignment, you may use the following library functions:

     length
     append (++)
     map
     foldl'
     foldr
     unzip
     zip
     reverse

  Use www.haskell.org/hoogle to learn more about the above.

  Do not change the skeleton code! The point of this assignment
  is to figure out how the functions can be written this way
  (using fold). You may only replace the `error "TBD:..."` terms.

-}

module Hw3 where

import Prelude hiding (replicate, sum)
import Data.List (foldl')

foldLeft :: (a -> b -> a) -> a -> [b] -> a
foldLeft = foldl'

--------------------------------------------------------------------------------
-- | sqSum [x1, ... , xn] should return (x1^2 + ... + xn^2)
--
-- >>> sqSum []
-- 0
--
-- >>> sqSum [1,2,3,4]
-- 30
--
-- >>> sqSum [(-1), (-2), (-3), (-4)]
-- 30

sqSum :: [Int] -> Int
sqSum xs = foldLeft f base xs
  where
   f a x = a + x * x
   base  = 0

--------------------------------------------------------------------------------
-- | `pipe [f1,...,fn] x` should return `f1(f2(...(fn x)))`
--
-- >>> pipe [] 3
-- 3
--
-- >>> pipe [(\x -> x+x), (\x -> x + 3)] 3
-- 12
--
-- >>> pipe [(\x -> x * 4), (\x -> x + x)] 3
-- 24

pipe :: [(a -> a)] -> (a -> a)
pipe fs   = foldLeft f base fs
  where
    --f a x = f x
    f a x = a . x
    base  = (\x -> x)

--------------------------------------------------------------------------------
-- | `sepConcat sep [s1,...,sn]` returns `s1 ++ sep ++ s2 ++ ... ++ sep ++ sn`
--
-- >>> sepConcat "---" []
-- ""
--
-- >>> sepConcat ", " ["foo", "bar", "baz"]
-- "foo, bar, baz"
--
-- >>> sepConcat "#" ["a","b","c","d","e"]
-- "a#b#c#d#e"

sepConcat :: String -> [String] -> String
sepConcat sep []     = ""
sepConcat sep (x:xs) = foldLeft f base l
  where
    f a x            = a ++ sep ++ x
    base             = x
    l                = xs

intString :: Int -> String
intString = show

--------------------------------------------------------------------------------
-- | `stringOfList pp [x1,...,xn]` uses the element-wise printer `pp` to
--   convert the element-list into a string:
--
-- >>> stringOfList intString [1, 2, 3, 4, 5, 6]
-- "[1, 2, 3, 4, 5, 6]"
--
-- >>> stringOfList (\x -> x) ["foo"]
-- "[foo]"
--
-- >>> stringOfList (stringOfList show) [[1, 2, 3], [4, 5], [6], []]
-- "[[1, 2, 3], [4, 5], [6], []]"

stringOfList :: (a -> String) -> [a] -> String
stringOfList f xs = "[" ++ sepConcat ", " (map f xs) ++ "]"


--------------------------------------------------------------------------------
-- | `clone x n` returns a `[x,x,...,x]` containing `n` copies of `x`
--
-- >>> clone 3 5
-- [3,3,3,3,3]
--
-- >>> clone "foo" 2
-- ["foo", "foo"]

clone :: a -> Int -> [a]
clone x 0 = []
clone x n = x:[] ++ (clone x (n-1))

type BigInt = [Int]

--------------------------------------------------------------------------------
-- | `padZero l1 l2` returns a pair (l1', l2') which are just the input lists,
--   padded with extra `0` on the left such that the lengths of `l1'` and `l2'`
--   are equal.
--
-- >>> padZero [9,9] [1,0,0,2]
-- [0,0,9,9] [1,0,0,2]
--
-- >>> padZero [1,0,0,2] [9,9]
-- [1,0,0,2] [0,0,9,9]

padZero :: BigInt -> BigInt -> (BigInt, BigInt)
padZero l1 l2 = if length l1 > length l2
    then (l1, clone 0 (length l1 - length l2) ++ l2)
    else (clone 0 (length l2 - length l1) ++ l1, l2)

--------------------------------------------------------------------------------
-- | `removeZero ds` strips out all leading `0` from the left-side of `ds`.
--
-- >>> removeZero [0,0,0,1,0,0,2]
-- [1,0,0,2]
--
-- >>> removeZero [9,9]
-- [9,9]
--
-- >>> removeZero [0,0,0,0]
-- []

removeZero :: BigInt -> BigInt

--removeZero (x:y:[]) = [x] ++ [y]
-- *Hw3 Hw3> removeZero [9,9,9,9]
-- [9,9]
removeZero (x:xs) = if x == 0
    then removeZero xs
    else [x] ++ xs
    
    
    {-}
    if x /= 0 && y /= 0
    then [x] ++ [y] ++ ds
    else 
        if x == 0 && y /= 0
        then [y] ++ ds
        else removeZero ([y] ++ ds) 

removeZero (_:[]) = []
removeZero [] = []
-}
--------------------------------------------------------------------------------
-- | `bigAdd n1 n2` returns the `BigInt` representing the sum of `n1` and `n2`.
--
-- >>> bigAdd [9, 9] [1, 0, 0, 2]
-- [1, 1, 0, 1]
--
-- >>> bigAdd [9, 9, 9, 9] [9, 9, 9]
-- [1, 0, 9, 9, 8]

bigAdd :: BigInt -> BigInt -> BigInt
bigAdd l1 l2     = removeZero res
  where
    (l1', l2')   = padZero l1 l2
    res          = foldLeft f base args
    f a x        = (\a1 x1 -> case(a1) of
        [] -> (expr2 x1)          -- base or no carry
        a1:xs ->(expr x1 a1) ++ xs
        ) a x      -- case with carry needs to pop carry
        where
            addT x          = fst(x) + snd(x)
            addR x y        = fst(x) + snd(x) + y
            normC_N_R x1    = (div (addT x1) 10)
            normC_W_R x1 a1 = (div (addR x1 a1) 10)
            normD_N_R x1    = (mod (addT x1) 10)
            normD_W_R x1 a1 = (mod (addR x1 a1) 10)
            --expr x1 a1 = (normC_W_R x1 a1):[0] 
            --expr2 x1 = (normC_N_R x1):[0] 
            --expr x1 a1 = (normC_W_R x1 a1):[normD_W_R x1 a1] 
            --expr2 x1 = (normC_N_R x1):[normD_N_R x1] 
            expr x1 a1 = [normC_W_R x1 a1,normD_W_R x1 a1] 
            expr2 x1 = [normC_N_R x1, normD_N_R x1] 
        --WORKING CODE
        --(\a1 (q,w) -> case(a1) of
        --[] -> (div (q+w) 10):[(mod (q+w) 10)]              -- base or no carry
        --a1:xs -> (div (q+w+a1) 10):[(mod (q+w+a1) 10)] ++ xs ) a x      -- case with carry needs to pop carryw
        --where
            --addT x = fst(x1) + snd(x1)
    
-- head is carry
        --a ++ (map addT x)
        --where
            --addT x = fst(x) + snd(x)
            --addLT (x1:x2:xs) = fst(x1) + snd(x1) + fst(x2)
            --cleanTuple x = (div x 10, mod x 10)
            --carry x = 
        --(a ++ (map (\(q,w) -> (q + w)) x))
        --if ((\(q1,w1) -> (q1 + w1)) x) > 10
        --then (a ++ (map (\(q,w) ->mod (q + w) 10) x))
        --else (a ++ (map (\(q,w) -> (q + w)) x))
        --(a ++ (map (\(q,w) -> (q + w)) x))
        --zip (a ++ (map (\(q,w) -> (q + w)) x))
--maybe a basic if then else?
        --map (\h -> if fst(h) > 0 then else) ((a ++ (map (\(q,w) -> div (q + w) 10) x)), (a ++ (map (\(q,w) ->mod (q + w ) 10) x)))
--map (\a -> if a >= 10 then a `mod` 10 else a) (a ++ (map (\(q,w) -> (q + w)) x))
    base         = [0]
    args         = reverse (zip l1' l2')

--------------------------------------------------------------------------------
-- | `mulByDigit i n` returns the result of multiplying
--   the digit `i` (between 0..9) with `BigInt` `n`.
--
-- >>> mulByDigit 9 [9,9,9,9]
-- [8,9,9,9,1]

mulByDigit :: Int -> BigInt -> BigInt
mulByDigit i n = foldr bigAdd [] (clone n i)

--------------------------------------------------------------------------------
-- | `bigMul n1 n2` returns the `BigInt` representing the product of `n1` and `n2`.
--
-- >>> bigMul [9,9,9,9] [9,9,9,9]
-- [9,9,9,8,0,0,0,1]
--
-- >>> bigMul [9,9,9,9,9] [9,9,9,9,9]
-- [9,9,9,9,8,0,0,0,0,1]

bigMul :: BigInt -> BigInt -> BigInt
bigMul l1 l2 = res
  where
    (_,res) = foldLeft f base args
    f a x    = (\tuple x1 -> ((fst(tuple)+1) , (bigAdd (expr tuple x1) (snd(tuple))))) a x
        where
        --placevalue x = 10^fst(x)
        --mult x = mulByDigit (placevalue snd(x)) l1
        --sumterm x = bigAdd (mult x) snd(x)
        expr x y = mulByDigit (y*(10^fst(x))) l1



    base     = (0,[0])
    args     = l2
    {-}
    res = foldLeft f base args
    f a x    = (\ls x1 -> case(x1) of
        [] -> []
        q:x1 -> bigAdd (mulByDigit q l1) ls
        ) a x
    base     = [0]
    -}
        --(0,[0])
--this holds from result tuple of (_, res)
--does not work by because due to right zero from 10^k_i from right
    
