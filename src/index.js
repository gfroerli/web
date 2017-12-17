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

    // Selected sensor element
    const selectedSensor = {
        el: null,
        sensor: null,
    };

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
    elmApp.ports.moveMap.subscribe(newPos => {
        console.debug('Map: New coordinates received:', newPos);
        map.setCenter([newPos.lng, newPos.lat]);
        map.setZoom(newPos.zoom)
    });

    // When new sensors are loaded, display them
    elmApp.ports.sensorsLoaded.subscribe(sensors => {
        console.debug('Map:', sensors.length, 'new sensors have been loaded.');

        // Zoom to bounding box
        const latitudes = sensors.map(s => s.pos.lat);
        const longitudes = sensors.map(s => s.pos.lng);
        const latMinMax = [Math.min(...latitudes), Math.max(...latitudes)];
        const lngMinMax = [Math.min(...longitudes), Math.max(...longitudes)];
        const latDelta = latMinMax[1] - latMinMax[0];
        const lngDelta = lngMinMax[1] - lngMinMax[0];
        map.fitBounds([[
            lngMinMax[0] - lngDelta * 0.2,
            latMinMax[0] - latDelta * 0.2,
        ], [
            lngMinMax[1] + lngDelta * 0.2,
            latMinMax[1] + latDelta * 0.2,
        ]]);

        // Add marker for every sensor
        sensors.forEach(sensor => {
            // Create marker element
            const el = document.createElement('div');
            el.className = 'marker';
            let text;
            if (sensor.lastMeasurement) {
                const tempString = sensor.lastMeasurement.temperature;
                const tempFloat = parseFloat(tempString);
                if (!!tempFloat) {
                    text = document.createTextNode(Math.round(tempFloat));
                } else {
                    text = document.createTextNode('?');
                }
            } else {
                text = document.createTextNode('?');
            }
            el.appendChild(text);

            // Add marker to map
            const marker = new mapboxgl.Marker(el)
                .setLngLat([sensor.pos.lng, sensor.pos.lat])
                .addTo(map);

            // Add event listener
            el.addEventListener('click', (ev) => {
                console.log('selected', selectedSensor);
                console.log('el', el);
                const selectedClass = 'selected';
                elmApp.ports.sensorClicked.send(sensor);
                if (selectedSensor.el !== null) {
                    selectedSensor.el.classList.remove(selectedClass);
                }
                el.classList.add(selectedClass);
                selectedSensor.el = el;
                selectedSensor.sensor = sensor;
            });
        });
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

    // Notify Elm that the map has been initialized
    elmApp.ports.mapInitialized.send(null);
});

window.foo = elmApp;
