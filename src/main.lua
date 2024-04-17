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


function drawObject(pRho, pTheta, pPhi, pDistance)

  local transfMat = viewpointParam(pRho, pTheta, pPhi)

  local screenPoints = {}
  local refPoints = {}

  for i, vertice in ipairs(obj.vertices) do
    point = {}
    point.x = vertice[1]
    point.y = vertice[2]
    point.z = vertice[3]
    transformedPoint = pvTransform(point, transfMat)
    table.insert(refPoints, transformedPoint)
    table.insert(screenPoints, screenProj(transformedPoint, pDistance))
  end

  table.insert(screenPoints, screenPoints[1])

  for idx = 1, #screenPoints-1 do
    love.graphics.line(
                       screenPoints[idx].x + SCREEN_W/2,
                       screenPoints[idx].y + SCREEN_H/2,
                       screenPoints[idx+1].x + SCREEN_W/2,
                       screenPoints[idx+1].y + SCREEN_H/2 
                      )
  end  

end


function love.load()

  love.window.setMode(SCREEN_W, SCREEN_H)
  love.window.setTitle('3D basics demo')

end


function love.update(dt)

  a1 = a1 + 0.1
  a2 = a2 + 1

end


function love.draw()

  drawObject(r, a1, a2, d)

end


function love.keypressed(key)

  if key == 'escape' then
    love.event.quit()
  end

end
