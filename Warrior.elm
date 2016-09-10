module Warrior exposing (Model, init, step, takeDamage, enrich, collectsItem, drink, wield, wearArmor, wearHelm, wearRing, computeDamageAgainst, resistance, cardView, augmentVision, sheatheWeapon, takeOffArmor, takeOffHelm, takeOffRing)

import Configuration
import Util
import Direction exposing (Direction(..))
import Point exposing (Point, slide)
import Weapon exposing (Weapon)
import Armor exposing (Armor)
import Helm exposing (Helm)
import Ring exposing (Ring)
import Item exposing (Item, ItemKind(..))
import Action exposing (Action)
import Liquid exposing (Liquid(..))
import Palette

import Graphics
import Svg


import Dict exposing (Dict)

-- MODEL

type alias Model =
  { hp : Int
  , maxHp : Int
  , direction : Direction
  , position : Point
  , gold : Int
  , strength : Int
  , steps : Int
  , weapon : Maybe Weapon
  , armor : Maybe Armor
  , ring : Maybe Ring
  , helm : Maybe Helm
  , inventory : List Item
  , timesGearChanged : Int
  , visionRadius : Int
  }

-- INIT

init : Point -> Model
init point =
  let hp = Configuration.startingHitPoints in
  { hp = hp
  , maxHp = hp
  , direction = North
  , position = point
  , gold = 0
  , strength = Configuration.startingStrength
  , steps = 0
  , weapon = Nothing
  , armor = Nothing
  , ring = Nothing
  , helm = Nothing
  , inventory = []
  , timesGearChanged = 0
  , visionRadius = Configuration.visionRadius
  }

power : Model -> Int
power model =
  case model.weapon of
    Nothing ->
      model.strength
    Just weapon ->
      model.strength + (Weapon.averageDamage weapon)

resistance : Model -> Int
resistance model =
  case model.armor of
    Nothing ->
      model.strength
    Just armor ->
      model.strength + (Armor.absorption armor)

-- helpers
step : Direction -> Model -> Model
step direction model =
  let model' = { model | position = model.position |> slide direction
                       , steps = model.steps + 1
                       }
  in
    if model.steps % 10 == 0 then
      model' |> heal 1
    else
      model'

computeDamageAgainst : Int -> Model -> Int
computeDamageAgainst defense model =
  let
    damage = case model.weapon of
      Just weapon ->
        model.strength + Weapon.damage model.steps model.timesGearChanged weapon
      Nothing ->
        model.strength
  in
    max 1 (damage - defense)

takeDamage : Int -> Model -> Model
takeDamage amount model =
  { model | hp = model.hp - amount }

enrich : Int -> Model -> Model
enrich amount model =
  { model | gold = model.gold + amount }

heal : Int -> Model -> Model
heal amount model =
  { model | hp = min model.maxHp (model.hp + amount) }

augmentVision : Int -> Model -> Model
augmentVision amount model =
  { model | visionRadius = model.visionRadius + amount }

drink : Liquid -> Model -> Model
drink liquid model =
  case liquid of
    Liquid.Water ->
      model
      |> heal 5

    Liquid.Blessed liquid' ->
      model
      |> heal 10
      |> drink liquid'

    Potion effect ->
      case effect of
        Liquid.GainLife ->
          model
          |> gainHp 2

gainHp : Int -> Model -> Model
gainHp n model =
  let hp' = model.maxHp + n in
  { model | hp = hp'
          , maxHp = hp'
        }

addToInventory item model =
  let
    model' =
      { model | inventory = model.inventory ++ [item] }
  in
    model'

wield : Weapon -> Model -> Model
wield weapon model =
  case model.weapon of
    Just weapon' ->
      let oldWeapon = Item.init (0,0) (Item.weapon weapon') (1000000 + model.timesGearChanged) in
      { model | weapon = Just weapon
              --, inventory = model.inventory ++ []
              , timesGearChanged = model.timesGearChanged + 1
      }
      |> addToInventory oldWeapon

    Nothing ->
      { model | weapon = Just weapon }


sheatheWeapon : Model -> Model
sheatheWeapon model =
  case model.weapon of
    Nothing ->
      model

    Just weapon ->
      let oldWeapon = Item.init (0,0) (Item.weapon weapon) (1000000 + model.timesGearChanged) in
      { model | weapon = Nothing
              , timesGearChanged = model.timesGearChanged + 1
            }
      |> addToInventory oldWeapon

wearArmor : Armor -> Model -> Model
wearArmor armor model =
  case model.armor of
    Just armor' ->
      let oldArmor = Item.init (0,0) (Item.armor armor') (1000000 + model.timesGearChanged) in
      { model | armor = Just armor
              , timesGearChanged = model.timesGearChanged + 1
      }
      |> addToInventory oldArmor

    Nothing ->
      { model | armor = Just armor }



takeOffArmor : Model -> Model
takeOffArmor model =
  case model.armor of
    Nothing ->
      model

    Just armor ->
      let oldArmor = Item.init (0,0) (Item.armor armor) (1000000 + model.timesGearChanged) in
      { model | armor = Nothing
              , timesGearChanged = model.timesGearChanged + 1
            }
            |> addToInventory oldArmor

wearHelm : Helm -> Model -> Model
wearHelm helm model =
  case model.helm of
    Just helm' ->
      let oldHelm = Item.init (0,0) (Item.helm helm') (1000000 + model.timesGearChanged) in
      { model | helm = Just helm
              , timesGearChanged = model.timesGearChanged + 1
      }
      |> addToInventory oldHelm

    Nothing ->
      { model | helm = Just helm }

takeOffHelm : Model -> Model
takeOffHelm model =
  case model.helm of
    Nothing ->
      model

    Just helm ->
      let oldHelm = Item.init (0,0) (Item.helm helm) (1000000 + model.timesGearChanged) in
      { model | helm = Nothing
              , timesGearChanged = model.timesGearChanged + 1
            }
            |> addToInventory oldHelm


wearRing : Ring -> Model -> Model
wearRing ring model =
  case model.ring of
    Just ring' ->
      let 
        oldRing =
          Item.init (0,0) (Item.ring ring') (1000000 + model.timesGearChanged) 
      in
        { model | ring = Just ring
                , timesGearChanged = model.timesGearChanged + 1
        }
        |> addToInventory oldRing
      
    Nothing ->
      { model | ring = Just ring }


takeOffRing : Model -> Model
takeOffRing model =
  case model.ring of
    Nothing ->
      model

    Just ring ->
      let oldRing = Item.init (0,0) (Item.ring ring) (1000000 + model.timesGearChanged) in
      { model | ring = Nothing
              , timesGearChanged = model.timesGearChanged + 1
            }
            |> addToInventory oldRing

collectsItem : Item -> Model -> Model
collectsItem item model =
  let
    model' =
      model |> addToInventory item
  in
    case item.kind of
      Arm weapon ->
        case model.weapon of
          Nothing ->
            model |> wield weapon
          Just weapon' ->
            model'

      Shield armor ->
        case model.armor of
          Nothing ->
            model |> wearArmor armor
          Just armor' ->
            model'

      _ ->
        model'

-- VIEW
cardView : Point -> Maybe Action -> Model -> List (Svg.Svg a)
cardView (x,y) action model =
  let
    strength =
      toString (power model)

    resist =
      toString (resistance model)

  in
    [ Graphics.render "STATS" (x, y) Palette.primaryLighter
    , Graphics.render ("  STRENGTH: " ++ strength) (x, y+2) Palette.active
    , Graphics.render ("RESISTANCE: " ++ resist) (x, y+3) Palette.active
    ]
