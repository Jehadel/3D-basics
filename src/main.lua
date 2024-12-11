-- gets the 3D object data
local obj = require('object')

local r = 100
local a1 = 0
local a2 = 0 
local d = 1000

local hide = false

local SCREEN_W = 800
local SCREEN_H = 600

-- to perform backfaces culling
-- we will need some operations on 3D vectors

function vec_dotProduct(v1, v2)

  return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z

end


function vec_crossProduct(v1, v2)
   return {
    x = v1.y * v2.z - v1.z * v2.y,
    y = v1.z * v2.x - v1.x * v2.z,
    z = v1.x * v2.y - v1.y * v2.x
  }

end


function vec_substraction(v1, v2)

  return { 
    x = v1.x - v2.x,
    y = v1.y - v2.y,
    z = v1.z - v2.z
  }

end


function face_normal(pFace, pTransformedVertices)


  local vs1 = vec_substraction(pTransformedVertices[pFace[2]], pTransformedVertices[pFace[1]])
  local vs2 = vec_substraction(pTransformedVertices[pFace[3]], pTransformedVertices[pFace[1]])

  return vec_crossProduct(vs1, vs2)

end


function is_visible(pFace, pTransformedVertices, pCameraPosition)

  local viewVec = vec_substraction(pCameraPosition, pTransformedVertices[pFace[1]])
  return vec_dotProduct(face_normal(pFace, pTransformedVertices), viewVec) > 0

end


function visibleFaces(pFaces, pTransformedVertices, pCameraPosition) 

  vFaces = {}
  for _, face in ipairs(pFaces) do
    if is_visible(face, pTransformedVertices, pCameraPosition) then
      table.insert(vFaces, face)
    end
  end

  return vFaces

end


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
  --  -- 2d argument is camera position, not relevant here

  -- extract from faces "unique" edges that will be drawn (edges can’t appear twice in the list) 
 
 
  local transfMat = viewpointParam(pRho, pTheta, pPhi)

  if hide then -- 
    -- hide == true : we need to project each face
    -- and then compute which one is hidden
    
    -- create/compute transformed vertices
    transformedVertices = {}
    for i, vertex in ipairs(obj.vertices) do
      p = {}
      p.x = vertex[1]
      p.y = vertex[2]
      p.z = vertex[3]
      transformedVertices[i] = pvTransform(p, transfMat)
    end
    
    -- evaluate which face is visible
    local facesToDraw = visibleFaces(obj.faces, transformedVertices, {x=0, y=0, z=-1})

    -- draw unique edges from visible faces

    for _, face in ipairs(facesToDraw) do

      screenpoint = {}
      for _, vertex in ipairs(face) do
        table.insert(screenpoint, screenProj(transformedVertices[vertex], pDistance))
      end

      for i=1, #screenpoint do
        love.graphics.line(
          screenpoint[i].x + SCREEN_W/2,
          screenpoint[i].y + SCREEN_H/2,
          screenpoint[i % #face + 1].x + SCREEN_W/2,
          screenpoint[i % #face + 1].y + SCREEN_H/2
        )

      end
    end






  else

  -- hide == false : don’t need to compute which faces are hidden
  -- iterate through unique edges list and 
  -- compute projection of corresponding vertices on screen

    local edgesToDraw = uniqueEdges(obj.faces)

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

  love.graphics.print('Press <h> key to hide/show back faces of the object', 10, 10)

  drawObject(r, a1, a2, d)

end


function love.keypressed(key)

  if key == 'escape' then
    love.event.quit()
  end

  if key == 'h' then
    hide = not hide
  end

end