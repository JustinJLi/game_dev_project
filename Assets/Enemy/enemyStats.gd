extends Node

#Basic stats to track enemies and score in a level
var total_enemies: int = 0
var enemies_cleared: int = 0
var enemies_killed_score: int = 0

#Reset function
func reset():
	total_enemies = 0
	enemies_cleared = 0
	enemies_killed_score = 0
