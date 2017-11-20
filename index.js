'use strict';

require('./index.html');
require('./src/Stylesheets');

const Elm = require('./src/Main');
const app = Elm.Main.embed(document.getElementById('main'));

app.ports.initializeMap.subscribe((pos) => {
    console.info('Map: Initialize');

    // TODO:
    // mapboxgl.supported() -> browser support

    // Credentials
    mapboxgl.accessToken = 'pk.eyJ1IjoiY29yZWR1bXBjaCIsImEiOiJjamE4bXFhMGcwODd5MnFwY2poa3Rnd2U5In0.O5jacsI2pxe3fIAxQdu0Yg';

    // Initialize map
    const map = new mapboxgl.Map({
        container: 'map',
        style: 'mapbox://styles/mapbox/outdoors-v10?optimize=true',
        center: [pos.longitude, pos.latitude],
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
    app.ports.moveMap.subscribe((newPos) => {
        console.debug('Map: New coordinates received:', newPos);
        map.setCenter([newPos.longitude, newPos.latitude]);
        map.setZoom(newPos.zoom)
    });

    // Subscribe to JS events
    map.on('moveend', (ev) => {
        app.ports.mapMoved.send({
            latitude: map.getCenter().lat,
            longitude: map.getCenter().lng,
            zoom: map.getZoom(),
        });
    });
    map.on('zoom', (ev) => {
        app.ports.mapMoved.send({
            latitude: map.getCenter().lat,
            longitude: map.getCenter().lng,
            zoom: map.getZoom(),
        });
    });
});
