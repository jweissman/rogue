module Event exposing (Event(..), describe, awaken, pickupCoin, attack, killEnemy, defend, enemyEngaged, death, ascend, descend, crystalTaken, hallsEscaped, isEnemyKill, isPlayerDeath, pickupItem)

import Creature
import Item exposing (Item)
import Language exposing (Language)

-- TYPES

type Event
  = Awaken
  | PickupCoin
  | EnemyEngaged Creature.Model
  | AttackEnemy Creature.Model Int
  | KillEnemy Creature.Model
  | DefendEnemy Creature.Model Int
  | Death String
  | Descend Int
  | Ascend Int
  | CrystalTaken
  | HallsEscaped
  | PickupItem Item

-- ctors
awaken =
  Awaken

pickupCoin =
  PickupCoin

enemyEngaged enemy =
  EnemyEngaged enemy

attack target damage =
  AttackEnemy target damage

killEnemy target =
  KillEnemy target

defend target damage =
  DefendEnemy target damage

death cause =
  Death cause

descend level =
  Descend level

ascend level =
  Ascend level

crystalTaken =
  CrystalTaken

hallsEscaped =
  HallsEscaped

pickupItem item =
  PickupItem item

-- helpers
isEnemyKill event =
  case event of
    KillEnemy _ -> True
    _ -> False

isPlayerDeath event =
  case event of
    Death _ -> True
    _ -> False

describe : Language -> Language -> Event -> String
describe vocab lang event =
  case event of
    Awaken ->
      "You awaken in the Timeless Halls of Mandos..."

    PickupCoin ->
      "You find a glittering golden coin."

    EnemyEngaged enemy ->
      "You see that the " ++ (Creature.describe enemy) ++ " engages you!"

    AttackEnemy enemy dmg ->
      "You attack " ++ (Creature.describe enemy) ++ " for " ++ (toString dmg) ++ " damage."

    KillEnemy enemy ->
      "You slay " ++ (Creature.describe enemy) ++ "!"

    DefendEnemy enemy dmg ->
      "You are attacked by " ++ (Creature.describe enemy) ++ " for " ++ (toString dmg) ++ " damage."

    Death cause ->
      "You were slain by " ++ cause

    Ascend lvl ->
      "You ascend to level " ++ (toString lvl)

    Descend lvl ->
      "You descend to level " ++ (toString lvl)

    CrystalTaken ->
      "You take the long-sought Crystal of Time!"

    HallsEscaped ->
      "The doors swing open and you emerge into daylight...!"

    PickupItem item ->
      "You pick up the " ++ (Item.describe vocab lang item)
