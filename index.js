'use strict';

require('./index.html');
require('./src/Stylesheets');

const Elm = require('./src/Main');
const app = Elm.Main.embed(document.getElementById('main'));

app.ports.initializeMap.subscribe((pos) => {
    console.info('Map: Initialize');

    const mapDiv = document.getElementById('map');
    if (mapDiv) {
        const myLatLng = new google.maps.LatLng(pos);
        const mapOptions = {
            zoom: pos.zoom,
            center: myLatLng,
        };
        const gmap = new google.maps.Map(mapDiv, mapOptions);

        // Listen for map move events from Elm
        app.ports.moveMap.subscribe((newPos) => {
            console.debug('Map: New coordinates received:', newPos);
            const myLatLng = new googlemaps.LatLng(newPos);
            gmap.setCenter(myLatLng);
            gmap.setZoom(newPos.zoom)
        });

        // Listen for map move events from JS
        // TODO: Listen for zoom events too
        gmap.addListener('drag', () => {
            console.debug('Map: drag');
            app.ports.mapMoved.send({
                lat: gmap.getCenter().lat(),
                lng: gmap.getCenter().lng(),
                zoom: gmap.getZoom(),
            });
        });
    } else {
        console.error("Map: Cannot find map div");
    }
});
