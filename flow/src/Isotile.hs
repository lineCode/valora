module Isotile
  ( Isotile(..)
  , IsoSide(..)
  , isoSideMask
  , isotiles
  , isotileGrid
  ) where

import Data.Fixed (mod')
import qualified Data.Vector as V

import Coords
import Geom

data Isotile = Isotile
  { a :: Point
  , b :: Point
  , c :: Point
  , period :: Double
  } deriving (Eq, Show)

data IsoSide
  = IsoLeft
  | IsoCenter
  | IsoRight

isoSideMask :: IsoSide -> Isotile -> Contour
isoSideMask side (Isotile a b c period) =
  let d = midpoint a c
      e = Point (x a) (y a + period / 2)
      f = Point (x c) (y c + period / 2)
      g = Point (x d) (y d + period)
  in case side of
       IsoLeft -> Contour $ V.fromList [a, b, d, e]
       IsoCenter -> Contour $ V.fromList [e, d, f, g]
       IsoRight -> Contour $ V.fromList [b, c, f, d]

shift :: Point -> Isotile -> Isotile
shift off (Isotile a b c p) = Isotile (a + off) (b + off) (c + off) p

isotiles :: Double -> [Isotile]
isotiles period = map (tile) [0 ..]
  where
    f x = abs ((x `mod'` period) - period / 2)
    tile i =
      Isotile
      { a =
          let x = i * period
          in Point x (f x)
      , b =
          let x = i * period + period / 2
          in Point x (f x)
      , c =
          let x = (i + 1) * period
          in Point x (f x)
      , period
      }

isotileGrid :: Double -> Double -> Double -> [Isotile]
isotileGrid period width height = concat $ map (take neededColumns) rows'
  where
    neededColumns = round $ height / period
    neededRows = round $ width / period
    rows = map (const $ isotiles period) [0 .. neededRows]
    shifter row =
      let y = fromIntegral row * period
      in if row `mod` 2 == 0
           then shift $ Point 0 y
           else shift $ Point (period / 2) y
    rows' = map (\(i, row) -> map (shifter i) row) $ zip [0 ..] rows