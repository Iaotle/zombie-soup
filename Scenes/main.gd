extends Node2D
# 140, 150 window 1
# 505, 150 window 2

# enemies should appear randomly off-screen, then walk towards window 1 or 2. then enemies have a demand for a certain ingredient.

var ingredient: Array[String] = [
]

# enemies switch from calm sprite to angry sprite when they have not been fed. player has to shotgun them