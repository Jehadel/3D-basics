run:
	love src/

love:
	mkdir -p dist
	cd src && zip -r ../dist/3D-demo.love .

js: love
	love.js -c --title="3D demo - wireframe animation" ./dist/3D-demo.love ./dist/js
