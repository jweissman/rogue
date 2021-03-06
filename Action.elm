module Action exposing (Action(..), describe, question, defaultForItem, canPerform, drop, enchant, use, default, hurl, describeWithDefault)

import Language exposing (Language)
import Item exposing (Item, ItemKind(..))

type Action = Drop
            | Throw
            | Hurl Item
            | Identify
            | Wield
            | Wear
            | Drink
            | Look
            | Read
            | Enchant
            | Use Item Action
            | Default
            | Sheathe
            | TakeOff

drop =
  Drop

throw =
  Throw

hurl it =
  Hurl it

default =
  Default

enchant =
  Enchant

use item action =
  Use item action

defaultForItem : Bool -> Item -> Action
defaultForItem equipped {kind} =
  case kind of
    Arm _ ->
      if equipped then Sheathe else Wield

    Shield _ ->
      if equipped then TakeOff else Wear

    Jewelry _ ->
      if equipped then TakeOff else Wear

    Headgear _ ->
      if equipped then TakeOff else Wear

    Bottle _ ->
      Drink

    Scroll _ ->
      Read

    QuestItem _ ->
      Look

    Throwing _ ->
      Throw

canPerform : Bool -> Item -> Action -> Bool
canPerform equipped item action =
  let {kind} = item in
  case action of
    Default ->
      -- todo check if equipped? (e.g., cursed items?)
      canPerform equipped item (defaultForItem False item)

    Wield ->
      case kind of
        Arm _ -> True
        _ -> False

    Wear ->
      case kind of
        Shield _ -> True
        Jewelry _ -> True
        Headgear _ -> True
        _ -> False

    Read ->
      case kind of
        Scroll _ -> True
        _ -> False

    Drink ->
      case kind of
        Bottle _ -> True
        _ -> False

    Drop ->
      case kind of
        QuestItem _ -> False
        _ -> not equipped

    Enchant ->
      case kind of
        Arm _ -> True
        Shield _ -> True
        Jewelry _ -> True
        Headgear _ -> True
        _ -> False

    Use item' action' ->
      canPerform equipped item action'

    Throw ->
      case kind of
        Throwing _ ->
          True

        _ ->
          False

    _ -> False

describe : Action -> String
describe action =
  case action of
    Drop ->
      "Remove"

    Throw ->
      "Hurl"

    Identify ->
      "Identify"

    Wield ->
      "Equip"

    Wear ->
      "Equip"

    Drink ->
      "Drink"

    Look ->
      "Inspect"

    Read ->
      "Read"

    Enchant ->
      "Enchant"

    Sheathe ->
      "Sheathe"

    TakeOff ->
      "Take off"

    Hurl item ->
      "Throw " ++ (Item.name item) ++ "..."

    Use item action' ->
      describe action'
      --"Use " ++ (Item.name item) ++ " to " ++ describe action' ++ "..."

    Default ->
      "[Default]"

describeWithDefault : Item -> Bool -> Action -> String
describeWithDefault item equipped action =
  case action of
    Default ->
      describe (defaultForItem equipped item)
    _ -> describe action

question : Language -> Language -> Action -> String
question vocab language action =
  case action of
    Drop ->
      "What would you like to get rid of?"

    Throw ->
      "What would you like to throw?"

    Identify ->
      "What mysterious object would you like to identify?"

    Wield ->
      "Which weapon would you like to wield?"

    Wear ->
      "What would you like to wear?"

    Drink ->
      "What would you like to drink?"

    Look ->
      "Where would you like to look?"

    Read ->
      "What would you like to read?"

    Enchant ->
      "What would you like to enchant?"

    Sheathe ->
      "What would you like to sheathe?"

    TakeOff ->
      "What would you like to take off?"

    Use item action' ->
      "What would you like to " ++ (describe action') ++ " with " ++ (Item.describe vocab language item) ++ "?"

    Hurl item ->
      "What would you like to throw the " ++ (Item.describe vocab language item) ++ " at?"

    Default ->
      "What would you like to do?"
