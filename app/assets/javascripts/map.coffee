$(document).on 'page:change', () ->
    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]
        
        position = new google.maps.LatLng(mapContainer.dataset['latitude'], mapContainer.dataset['longitude'])
        
        map = new google.maps.Map(mapContainer, {
            center: position
            zoom: 14
        });
            
        marker = new google.maps.Marker 
            position: map.getCenter() 
            map: map 
            draggable: Boolean(mapContainer.dataset['markerDraggable'])