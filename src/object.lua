local object = {}

-- Let‘s start simple : a cube
-- list of the 8 vertices
-- object.vertices = {
--                     {0, 0, 0},
--                     {0, 0, 10},
--                     {10, 0, 10},
--                     {10, 0, 0},
--                     {10, 10, 0},
--                     {10, 10, 10},
--                     {0, 10, 10},
--                     {0, 10, 0}
--                   }
object.vertices = {
  {0, 0, 0},
  {10, 0, 0},
  {10, 10, 0},
  {0, 10, 0},
  {0, 0, 10},
  {10, 0, 10},
  {10, 10, 10},
  {0, 10, 10}
}
-- list of the 6 faces
-- each face is defined by 4 vertices
-- each table contains the vertices index
-- in the vertices table for a given face
-- object.faces = {
--                   {1, 2, 3, 4},
--                   {2, 3, 6, 7},
--                   {3, 4, 5, 6},
--                   {1, 4, 5, 8},
--                   {1, 2, 7, 8},
--                   {5, 6, 7, 8}}
object.faces = {
  {1, 2, 3, 4},
  {2, 6, 7, 3},
  {5, 1, 4, 8},
  {5, 6, 2, 1},
  {8, 4, 3, 7},
  {6, 5, 8, 7}
}

return object
