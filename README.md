# Introduction

This is a simple solver for the iOS game [Strata](https://itunes.apple.com/cn/app/strata/id641702337?mt=8). The game is really beautiful and well-designed. Hope anyone reading this can buy this game to support those developers.

The whole solver is written in Haskell.

# Compilation

    ghc StrataSolver.hs

# Usage

To use it, modify the `Board.txt` file. Any non-dot character represent a color grid, dot represents a empty grid. 

Run the program, it will produce a solution.

# Solution

## Solution Locations

For 3x3 puzzles, there are 6 locations to layer the ribbons:

    1 > X X X
    2 > X X X
    3 > X X X
        ^ ^ ^
        4 5 6

For 4x4 puzzles, there are 8 locations to layer the ribbons:

    1 > X X X X
    2 > X X X X
    3 > X X X X
    4 > X X X X
        ^ ^ ^ ^
        5 6 7 8

That's easy to figure out those for other puzzles.

## Solution Colors

* Whatever: This means whichever ribbon you layer here is not important.
* Other characters: This is the corresponding color you fill in the `Board.txt`.

## Solution Explanation

The program produce a solution like this:

	7: Whatever
	4: P
	6: G
	2: G
	1: G
	8: P
	5: P
	3: P

The format here is `Location: Color`. So the solution above means (I use 'P' for purple, 'G' for green): 

    7: Whatever     => Step 1. Layer any ribbon on location 7.
    4: P            => Step 2. Layer a purple ribbon on location 4.
    6: G            => Step 3. Layer a green ribbon on location 6.
    2: G            => Step 4. Layer a green ribbon on location 2.
    1: G            => Step 5. Layer a green ribbon on location 1.
    8: P            => Step 6. Layer a purple ribbon on location 8.
    5: P            => Step 7. Layer a purple ribbon on location 5.
    3: P            => Step 8. Layer a purple ribbon on location 3.

    Puzzle solved.

## Color Change Count

Notice at the very end of the text the program produced, there is one line:

    Color Change Count: 2

Generally, there are many solutions for one puzzle. The program chooses one of the *best* solutions for you. Which is the best solution is evaluated based on how many colors you should change throughout the solving process. The output is one of the solutions that has the minimum "Color Change Count".