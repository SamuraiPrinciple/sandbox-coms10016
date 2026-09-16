-- Try it: ghci Hello.hs, then main, or double 21
import Test.QuickCheck

double :: Int -> Int
double x = x + x

-- In VS Code, click Evaluate... above a >>> or prop> line to run it here
-- >>> double 21

-- prop> \x -> double x == 2 * x

-- QuickCheck tries this with 100 random numbers
prop_double :: Int -> Bool
prop_double x = double x == 2 * x

main :: IO ()
main = do
    putStrLn "Hello, World!"
    quickCheck prop_double
