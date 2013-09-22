import Data.List (transpose, delete, minimumBy)
import Data.Maybe (isJust)


type BoardGrid = Maybe Char
type BoardRow = [BoardGrid]
type Board = [BoardRow]

type SolutionRow = (Int, Maybe Char)
type Solution = [SolutionRow]


showSolutionRow :: SolutionRow -> String
showSolutionRow (row, Nothing) = show (row + 1) ++ ": Whatever"
showSolutionRow (row, Just ch) = show (row + 1) ++ ": " ++ [ch]

showSolution :: Solution -> String
showSolution = unlines . map showSolutionRow

showBoardGrid :: BoardGrid -> String
showBoardGrid = maybe "." (: [])

showBoardRow :: BoardRow -> String
showBoardRow = concatMap showBoardGrid

showBoard :: Board -> String
showBoard = unlines . map showBoardRow

readBoardGrid :: Char -> BoardGrid
readBoardGrid '.' = Nothing
readBoardGrid ch = Just ch

readBoardRow :: String -> BoardRow
readBoardRow = map readBoardGrid

readBoard :: String -> Board
readBoard = map readBoardRow . lines

getBoardWidth :: Board -> Int
getBoardWidth (x:xs) = length x

getBoardHeight :: Board -> Int
getBoardHeight = length

getBoardRowCount :: Board -> Int
getBoardRowCount board = boardWidth + boardHeight
	where boardWidth = getBoardWidth board
	      boardHeight = getBoardHeight board

getBoardLine :: Int -> Board -> BoardRow
getBoardLine = flip (!!)

getBoardColumn :: Int -> Board -> BoardRow
getBoardColumn column = getBoardLine column . transpose

getBoardRow :: Int -> Board -> BoardRow
getBoardRow row board = if row < boardHeight then getBoardLine row board else getBoardColumn (row - boardHeight) board
	where boardHeight = getBoardHeight board

replaceItem :: a -> Int -> [a] -> [a]
replaceItem item index list = front ++ item : back
	where (front,_:back) = splitAt index list

clearBoardLine :: Int -> Board -> Board
clearBoardLine line board = replaceItem (replicate boardWidth Nothing) line board
	where boardWidth = getBoardWidth board

clearBoardColumn :: Int -> Board -> Board
clearBoardColumn column board = transpose $ clearBoardLine column $ transpose board

clearBoardRow :: Int -> Board -> Board
clearBoardRow row board = if row < boardHeight then clearBoardLine row board else clearBoardColumn (row - boardHeight) board
	where boardHeight = getBoardHeight board

allTheSame :: Eq a => [a] -> Bool
allTheSame [] = True
allTheSame [x] = True
allTheSame (x:y:xs) = if x /= y then False else allTheSame (y : xs)

coverColor :: BoardRow -> Maybe (Maybe Char)
coverColor line = if allTheSame filteredLine then color else Nothing
	where filteredLine = filter isJust line
	      color = if null filteredLine then Just Nothing else Just $ head filteredLine

getCoverRows :: Board -> [Int] -> [SolutionRow]
getCoverRows board rows = map extractSolutionRow $ filter (isJust . snd) $ zip rows colors
	where boardRows = map (`getBoardRow` board) rows
	      colors = map coverColor boardRows
	      extractSolutionRow (row, Just color) = (row, color)

getClearedBoard :: SolutionRow -> Board -> Board
getClearedBoard (row, _) = clearBoardRow row

getRowsLeft :: SolutionRow -> [Int] -> [Int]
getRowsLeft (row, _) = delete row

solveBoardIter :: Board -> [Int] -> Solution -> [Solution] -> [Solution]
solveBoardIter _ [] curSolution solutions = curSolution : solutions
solveBoardIter board rows curSolution solutions = if null solutionRows then solutions else concatMap solveOne solutionRows
	where solutionRows = getCoverRows board rows
	      solveOne solutionRow = solveBoardIter (getClearedBoard solutionRow board) (getRowsLeft solutionRow rows) (solutionRow : curSolution) solutions

solveBoard :: Board -> [Solution]
solveBoard board = solveBoardIter board [0 .. rowCount - 1] [] []
	where rowCount = getBoardRowCount board

colorChangeCounter :: (Int, Maybe Char) -> SolutionRow -> (Int, Maybe Char)
colorChangeCounter (count, Nothing) (_, newColor) = (count, newColor)
colorChangeCounter (count, oldColor) (_, Nothing) = (count, oldColor)
colorChangeCounter (count, Just oldColor) (_, Just newColor) = if oldColor == newColor then (count, Just newColor) else (count + 1, Just newColor)

getColorChangeCount :: Solution -> Int
getColorChangeCount = fst . foldl colorChangeCounter (0, Nothing)

compareSolution :: Solution -> Solution -> Ordering
compareSolution left right = compare (getColorChangeCount left) (getColorChangeCount right)

getBestSolution :: [Solution] -> Solution
getBestSolution = minimumBy compareSolution


printRowColor :: BoardRow -> IO ()
printRowColor row = do
	putStr $ showBoardRow row
	putStr " -> "
	print $ coverColor row

main = do
	text <- readFile "Board.txt"
	let board = readBoard text
	putStrLn $ showBoard board
	let solutions = solveBoard board
	let bestSolution = getBestSolution solutions
	putStrLn $ showSolution bestSolution
	putStr "Color Change Count: "
	print $ getColorChangeCount bestSolution