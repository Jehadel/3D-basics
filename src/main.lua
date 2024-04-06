-- gets the 3D object data 
local obj = require(object)

-- create a function to return the transformation
-- matrix to compute the object coordinates
-- in the viewpoint ref 
function viewpointParam(rho, theta, phi)

  local sintheta = math.sin(math.rad(theta))
  local costheta = math.cos(math.rad(theta))
  local sinphi = math.sin(math.rad(phi))
  local cosphi = math.cos(math.rad(phi))

  local vpMat = {} 
  vpMat.a = -sintheta
  vpMat.b = -costheta*cosphi
  vpMat.c = -costheta*sinphi
  vpMat.e = costheta 
  vpMat.f = -sintheta*cosphi
  vpMat.g = -sintheta*sinphi
  vpMat.j = sinphi 
  vpMat.k = -cosphi
  vpMat.o = rho

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

  vpCoords.x = pvpMat.a * pCoords.x + pvpMat.pe * pCoords.y
  vpCoords.y = pvpMat.b * pCoords.x + pvpMat.pf * pCoords.y + pvpMat.j * pCoords.z
  vpCoords.z = pvpMat.c * pCoords.x + pvpMat.pg * pCoords.y + pvpMat.k * pCoords.z + pvpMat.o

  return vpCoords

end


-- returns x, y coordinates on the screen 
-- after projection on screen from the viewpoint ref
function screenProj(pCoord, pDistance)

  screenCoords = {}
  screenCoords.x = pDistance * pCoords.x / pCoords.z -- + constante horizontale ajustement ?
  screenCoords.y = pDistance * pCoords.y / pCoords.z -- + constate verticale  ajustenemnt ? 

  return screenCoords

end


function drawObject()



end
