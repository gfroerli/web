'use strict';

require('./index.html');

const Elm = require('./Main.elm');
const elmDiv = document.getElementById('main');
const elmFlags = {
    apiToken: process.env.API_TOKEN,
};
const elmApp = Elm.Main.embed(elmDiv, elmFlags);

elmApp.ports.initializeMap.subscribe((pos) => {
    console.info('Map: Initialize');

    // TODO:
    // mapboxgl.supported() -> browser support

    // Credentials
    mapboxgl.accessToken = 'pk.eyJ1IjoiY29yZWR1bXBjaCIsImEiOiJjamE4bXFhMGcwODd5MnFwY2poa3Rnd2U5In0.O5jacsI2pxe3fIAxQdu0Yg';

    // Initialize map
    const map = new mapboxgl.Map({
        container: 'map',
        style: 'mapbox://styles/mapbox/outdoors-v10?optimize=true',
        center: [pos.lng, pos.lat],
        zoom: pos.zoom,
        pitchWithRotate: false,
    });

    // Initialize navigation control
    const nav = new mapboxgl.NavigationControl();
    map.addControl(nav, 'top-left');

    // Initialize geolocate control
    const geo = new mapboxgl.GeolocateControl({
        positionOptions: {
            enableHighAccuracy: true,
        },
        trackUserLocation: true,
    });
    map.addControl(geo, 'top-right');

    // Listen for map move events from Elm
    elmApp.ports.moveMap.subscribe((newPos) => {
        console.debug('Map: New coordinates received:', newPos);
        map.setCenter([newPos.lng, newPos.lat]);
        map.setZoom(newPos.zoom)
    });

    // Subscribe to JS events
    map.on('moveend', (ev) => {
        elmApp.ports.mapMoved.send({
            lat: map.getCenter().lat,
            lng: map.getCenter().lng,
            zoom: map.getZoom(),
        });
    });
    map.on('zoom', (ev) => {
        elmApp.ports.mapMoved.send({
            lat: map.getCenter().lat,
            lng: map.getCenter().lng,
            zoom: map.getZoom(),
        });
    });
});
