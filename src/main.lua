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
function pvTransform(px, py, pz, pvpMat)

  local vpRef = {}

  vpRef.x = pvpMat.a * px + pvpMat.pe * py
  vpRef.y = pvpMat.b * px + pvpMat.pf * py + pvpMat.j * pz
  vpRef.z = pvpMat.c * px + pvpMat.pg * py + pvpMat.k * pz + pvpMat.o

  return vpRef

end



