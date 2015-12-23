$(document).on 'page:change', () ->
    if $('#map.container').size() > 0
        mapContainer = $("#map-canvas")[0]
        
        reverseGeocode = (position, callback) ->
            geocoder = new google.maps.Geocoder()
            
            $("#place_address").attr("disabled", "disabled")
            
            geocoder.geocode( { 'latLng' : position }, (results, status) ->
                $("#place_address").removeAttr("disabled")
                $("#place_address").val(results[0].formatted_address)
                
                if callback
                    callback(results)
            )
        
        position = new google.maps.LatLng(mapContainer.dataset['latitude'], mapContainer.dataset['longitude'])
        
        map = new google.maps.Map(mapContainer, {
            center: position
            zoom: 14
        });
            
        marker = new google.maps.Marker 
            position: map.getCenter() 
            map: map 
            draggable: Boolean(mapContainer.dataset['markerDraggable'])
        
        if marker.draggable 
            marker.addListener('dragend', () ->
                position = marker.position
                
                $("#place_latitude").val(position.lat())
                $("#place_longitude").val(position.lng())
                
                $("#main.container.edit #listing.container form.edit_place .field #place_address").attr("disabled", "disabled")
                
                reverseGeocode(marker.position, (results) ->
                    if results.length > 0 
                        $("#main.container.edit #listing.container form.edit_place .field #place_address").val(results[0].formatted_address)
                    else 
                        $("#alert").html("There's nothing there! Try again?")
                    
                    $("#main.container.edit #listing.container form.edit_place .field #place_address").removeAttr("disabled")
                )
            )