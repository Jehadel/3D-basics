-- gets the 3D object data
local obj = require('object')

local r = 100
local a1 = 0
local a2 = 0 
local d = 1000

local SCREEN_W = 800
local SCREEN_H = 600


-- create a function to return the transformation
-- matrix to compute the object coordinates
-- in the viewpoint ref
function viewpointParam(pRho, pTheta, pPhi)

  local sintheta = math.sin(math.rad(pTheta))
  local costheta = math.cos(math.rad(pTheta))
  local sinphi = math.sin(math.rad(pPhi))
  local cosphi = math.cos(math.rad(pPhi))

  local vpMat = {}
  vpMat.a = -sintheta
  vpMat.b = -costheta*cosphi
  vpMat.c = -costheta*sinphi
  vpMat.e = costheta
  vpMat.f = -sintheta*cosphi
  vpMat.g = -sintheta*sinphi
  vpMat.j = sinphi
  vpMat.k = -cosphi
  vpMat.o = pRho

  return vpMat

end


-- transform the x,y,z coordinates in the world ref
-- to the coordinates in the viewpoint ref
-- the matrix indexing is :
-- | a b c d |
-- | e f g h |
-- | i j k … |
--
function pvTransform(pCoords, pvpMat)

  local vpCoords = {}

  vpCoords.x = pvpMat.a * pCoords.x + pvpMat.e * pCoords.y
  vpCoords.y = pvpMat.b * pCoords.x + pvpMat.f * pCoords.y + pvpMat.j * pCoords.z
  vpCoords.z = pvpMat.c * pCoords.x + pvpMat.g * pCoords.y + pvpMat.k * pCoords.z + pvpMat.o

  return vpCoords

end


-- returns x, y coordinates on the screen
-- after projection on screen from the viewpoint ref
function screenProj(pCoords, pDistance)

  screenCoords = {}
  screenCoords.x = pDistance * pCoords.x / pCoords.z -- + constante horizontale ajustement ?
  screenCoords.y = pDistance * pCoords.y / pCoords.z -- + constate verticale  ajustenemnt ?

  return screenCoords

end


-- to compare edges we have to sort vertices : 
-- edge (2, 1) is the same that edge (1, 2)
function sortEdges(v1, v2)

  local e = {}
  e.v = {math.min(v1, v2), math.max(v1, v2)} 
  e.key = tostring(e.v[1])..','..tostring(e.v[2]) -- has in Lua we can’t compare tables, we build a unique key for edges (key = ordered vertices)
  return e

end


function uniqueEdges(faces)

  local uEdges = {}

  for _, face in ipairs(faces) do
    for i = 1, #face do
      local v1 = face[i]
      local v2 = face[i % #face + 1] -- next vertex (when last one is reached, next is the first)  
      local sortedV = sortEdges(v1, v2)
      if not uEdges[sortedV.key] then
        uEdges[sortedV.key] = {sortedV.v[1], sortedV.v[2]}
      end
    end
  end 

  return uEdges

end


function drawObject(pRho, pTheta, pPhi, pDistance)

  -- determine which faces are visible (compute normal for each face) 


  -- extract from faces "unique" edges that will be drawn (edges can’t appear twice in the list) 
 
  local edgesToDraw = uniqueEdges(obj.faces)
 
  local transfMat = viewpointParam(pRho, pTheta, pPhi)

  -- iterate through unique edges list and 
  -- compute projection of corresponding vertices on screen

  for _, edge in pairs(edgesToDraw) do

    p1 = {}
    p1.x = obj.vertices[edge[1]][1]
    p1.y = obj.vertices[edge[1]][2]
    p1.z = obj.vertices[edge[1]][3]
    transformedPoint1 = pvTransform(p1, transfMat)
    screenPoint1 = screenProj(transformedPoint1, pDistance)

    p2 = {}
    p2.x = obj.vertices[edge[2]][1]
    p2.y = obj.vertices[edge[2]][2]
    p2.z = obj.vertices[edge[2]][3]
    transformedPoint2 = pvTransform(p2, transfMat)
    screenPoint2 = screenProj(transformedPoint2, pDistance)

    love.graphics.line(
      screenPoint1.x + SCREEN_W/2,
      screenPoint1.y + SCREEN_H/2,
      screenPoint2.x + SCREEN_W/2,
      screenPoint2.y + SCREEN_H/2
      )
  end

end


function love.load()

  love.window.setMode(SCREEN_W, SCREEN_H)
  love.window.setTitle('3D basics demo')

end


function love.update(dt)

  a1 = a1 + 5 * dt
  a2 = a2 + 50 * dt

end


function love.draw()

  drawObject(r, a1, a2, d)

end


function love.keypressed(key)

  if key == 'escape' then
    love.event.quit()
  end

end