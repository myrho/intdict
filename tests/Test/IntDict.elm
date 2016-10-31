module Test.IntDict exposing (tests)

{-| Copied and modified from `Dict`s test suite. -}

import Basics exposing (..)
import IntDict
import List
import Maybe exposing (..)

import ElmTest exposing (..)

numbers : IntDict.IntDict String
numbers = IntDict.fromList [ (2, "2"), (3, "3") ]

moreNumbers : IntDict.IntDict String
moreNumbers = IntDict.fromList [ (2, "2"), (5, "3"), (7, "7"), (45, "45") ]

tests : Test
tests =
  let buildTests = suite "build Tests"
        [ test "empty" <| assertEqual (IntDict.fromList []) (IntDict.empty)
        , test "singleton" <| assertEqual (IntDict.fromList [(1,"v")]) (IntDict.singleton 1 "v")
        , test "insert" <| assertEqual (IntDict.fromList [(1,"v")]) (IntDict.insert 1 "v" IntDict.empty)
        , test "insert replace" <| assertEqual (IntDict.fromList [(1,"vv")]) (IntDict.insert 1 "vv" (IntDict.singleton 1 "v"))
        , test "update" <| assertEqual (IntDict.fromList [(1,"vv")]) (IntDict.update 1 (\v->Just "vv") (IntDict.singleton 1 "v"))
        , test "update Nothing" <| assertEqual IntDict.empty (IntDict.update 1 (\v->Nothing) (IntDict.singleton 1 "v"))
        , test "remove" <| assertEqual IntDict.empty (IntDict.remove 1 (IntDict.singleton 1 "v"))
        , test "remove not found" <| assertEqual (IntDict.singleton 1 "v") (IntDict.remove 342 (IntDict.singleton 1 "v"))
        ]
      queryTests = suite "query Tests"
        [ test "isEmpty - empty is empty" <| assertEqual True (IntDict.isEmpty IntDict.empty)
        , test "isEmpty - non-empty dict is not empty" <| assertEqual False (IntDict.isEmpty numbers)
        , test "size 1" <| assertEqual 0 (IntDict.size IntDict.empty)
        , test "size 2" <| assertEqual 2 (IntDict.size numbers)
        , test "size 3" <| assertEqual 5 (IntDict.size (numbers `IntDict.union` moreNumbers))
        , test "member 1" <| assertEqual True (IntDict.member 2 numbers)
        , test "member 2" <| assertEqual False (IntDict.member 5234 numbers)
        , test "get 1" <| assertEqual (Just "2") (IntDict.get 2 numbers)
        , test "get 2" <| assertEqual Nothing (IntDict.get 5234 numbers)
        , test "findMin" <| assertEqual (Just (2, "2")) (IntDict.findMin numbers)
        , test "findMax" <| assertEqual (Just (3, "3")) (IntDict.findMax numbers)
        ]
      combineTests = suite "combine Tests"
        [ test "union" <| assertEqual numbers (IntDict.union (IntDict.singleton 3 "3") (IntDict.singleton 2 "2"))
        , test "union collison" <| assertEqual (IntDict.singleton 2 "2") (IntDict.union (IntDict.singleton 2 "2") (IntDict.singleton 2 "3"))
        , test "intersect" <| assertEqual (IntDict.singleton 2 "2") (IntDict.intersect numbers (IntDict.singleton 2 "2"))
        , test "diff" <| assertEqual (IntDict.singleton 3 "3") (IntDict.diff numbers (IntDict.singleton 2 "2"))
        ]
      transformTests = suite "transform Tests"
        [ test "filter" <| assertEqual (IntDict.singleton 2 "2") (IntDict.filter (\k v -> k == 2) numbers)
        , test "partition" <| assertEqual (IntDict.singleton 2 "2", IntDict.singleton 3 "3") (IntDict.partition (\k v -> k == 2) numbers)
        ]
      mergeTests =
        let
          insertBoth key leftVal rightVal dict =
            IntDict.insert key (leftVal ++ rightVal) dict
          s1 =
            IntDict.empty |> IntDict.insert 1 [ 1 ]
          s2 =
            IntDict.empty |> IntDict.insert 2 [ 2 ]
          s23 =
            IntDict.empty |> IntDict.insert 2 [ 3 ]
          b1 =
            (List.range 1 10) |> List.map (\i -> (i, [i])) |> IntDict.fromList
          b2 =
            (List.range 5 15) |> List.map (\i -> (i, [i])) |> IntDict.fromList
          bExpected =
            [(1,[1]),(2,[2]),(3,[3]),(4,[4]),(5,[5,5]),(6,[6,6]),(7,[7,7]),(8,[8,8]),(9,[9,9]),(10,[10,10]),(11,[11]),(12,[12]),(13,[13]),(14,[14]),(15,[15])]
        in
          suite "merge Tests"
            [ test "merge empties" <| assertEqual (IntDict.empty)
              (IntDict.merge IntDict.insert insertBoth IntDict.insert IntDict.empty IntDict.empty IntDict.empty)
            , test "merge singletons in order" <| assertEqual [(1, [1]), (2, [2])]
              ((IntDict.merge IntDict.insert insertBoth IntDict.insert s1 s2 IntDict.empty) |> IntDict.toList)
            , test "merge singletons out of order" <| assertEqual [(1, [1]), (2, [2])]
              ((IntDict.merge IntDict.insert insertBoth IntDict.insert s2 s1 IntDict.empty) |> IntDict.toList)
            , test "merge with duplicate key" <| assertEqual [(2, [2, 3])]
              ((IntDict.merge IntDict.insert insertBoth IntDict.insert s2 s23 IntDict.empty) |> IntDict.toList)
            , test "partially overlapping" <| assertEqual bExpected
              ((IntDict.merge IntDict.insert insertBoth IntDict.insert b1 b2 IntDict.empty) |> IntDict.toList)
            ]
      regressionTests = suite "regressions Tests"
        [ suite "issue #1" <|
            let
              a =
                IntDict.fromList [(4,20),(6,11)]
              b =
                IntDict.fromList [(1,0),(2,7),(3,9),(4,22),(6,14)]
            in
              [ test "a union b" <|
                  assertEqual
                    (IntDict.union a b)
                    (IntDict.fromList [(1,0),(2,7),(3,9),(4,20),(6,11)])
              , test "b union a" <|
                  assertEqual
                    (IntDict.union b a)
                    (IntDict.fromList [(1,0),(2,7),(3,9),(4,22),(6,14)])
              ]
        ]
  in
    suite "IntDict Tests"
    [ buildTests
    , queryTests
    , combineTests
    , transformTests
    , mergeTests
    , regressionTests
    ]
