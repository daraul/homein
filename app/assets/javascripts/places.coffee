# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Add a method to the string prototype to capitalize the first letter of a String
# SO surprised javascript doesn't already have this 
String.prototype.capitalizeFirstLetter = () -> 
    this.charAt(0).toUpperCase() + this.slice(1)

$(document).on 'page:change', () ->
    ApplicationID = '3J0AVN6KSY'
    
    SearchOnlyApiKey = 'fde549a36ac77931bd57966851982602'
    
    client = algoliasearch(ApplicationID, SearchOnlyApiKey)
    
    index = client.initIndex('homein_places_' + window.environment)
    window.environment = undefined
    
    facetsStats = window.facetsStats
    window.facetsStats = undefined 
    
    $("#searchbar").keyup ->
        value = [ this.value ]
        
        encodeURL("query", value)
        
        delay (->
            search(getQuery(), getFacetFilters(), getNumericFilters(), (content) ->
                renderList(content)
            )
        ), 500
        return
    
    setTimeout(() ->
        $("#alert, #notice").html("");
    , 10000)
    
    checkVisited = () ->
        if document.cookie.indexOf("visited") >= 0 
            return 
        else 
            today = new Date()
            document.cookie = "visited:" + today 
    
    search = (query, facetFilters, numericFilters, callback) ->
        index.search(
            query, 
            {
                "numericFilters": numericFilters
                "facetFilters": facetFilters
            },
            (err, content) ->
                if err 
                    alert err 
                    return err 
                
                if content.hits.length == 0 
                    $("#alert").html("No hits found!")
                
                if callback
                    callback(content.hits)
        )
    
    getQuery = () ->
        query = ""
        
        queryRegex = /(?:&|#)query=((?:\w+)(?:%20\w*)?)(?=&)?/g 
        
        queryMatch = queryRegex.exec(location.hash)
        
        if queryMatch
            query = queryMatch[1]
        
        return query 
    
    delay = do ->
        timer = 0
        (callback, ms) ->
            clearTimeout timer
            timer = setTimeout(callback, ms)
            return
    
    getFacetFilters = () ->
        facetFilters = []
        
        facetFiltersRegex = /(?:&|#)(for)=(sale|rent)(?=&)?/g
        
        facetFiltersMatch = facetFiltersRegex.exec(location.hash)
        
        while facetFiltersMatch != null 
            facetFilters.push facetFiltersMatch[1] + ":" + facetFiltersMatch[2]
            facetFiltersMatch = facetFiltersRegex.exec(location.hash)
            
        return facetFilters
    
    getNumericFilters = () ->
        numericFilters = []
            
        numericFiltersRegex = /(?:&|#)(bathrooms|rooms|price)=((?:\d+)(?:-\d+)?)(?=&)?/g
        
        numericFiltersMatch = numericFiltersRegex.exec(location.hash)
        
        while numericFiltersMatch != null 
            if /-/.test(numericFiltersMatch[2])
                numericFilters.push numericFiltersMatch[1] + ":" + numericFiltersMatch[2].replace("-", " to ")
            else 
                numericFilters.push numericFiltersMatch[1] + "=" + numericFiltersMatch[2]
            
            numericFiltersMatch = numericFiltersRegex.exec(location.hash)
            
        return numericFilters
    
    getContent = (result) ->
        content = 
            "<h1><a href=\"/places/#{result.id}/\">#{result.address}</a></h1>
            <p>#{result.description.replace(/\n/, "<br />")}</p>
            <p>Rooms: #{result.rooms} Bathrooms: #{result.bathrooms}</p>
            <p>Price: $#{result.price}"
            
        if result.for == "Rent"
            content += " per month"
        
        content += "</p>"
        
        if result.pictures 
            content += "<span id=\"place_pictures\">"
            for picture in result.pictures 
                content += "<a href=\"#{picture}\" class=\"place_picture_link\" target=\"_blank\"><img class=\"place_picture\" src=\"#{picture}\" /></a>"
            content += "</span>"
        
        if typeof currentuser != 'undefined' && currentuser == result.user_id
            content += 
                "<a href=\"/places/#{result.id}/edit\" class=\"place-management-link\"><i class=\"fa fa-pencil\" title=\"Edit place\"></i></a>
                <a data-confirm=\"Are you sure you want to delete this place?\" rel=\"nofollow\" data-method=\"delete\" href=\"/places/#{result.id}\" class=\"place-management-link\"><i class=\"fa fa-trash-o\" title=\"Delete place\"></i></a>"
        
        content += 
            "<p>Contact: <a href=\"mailto:#{result.contact}\" title=\"Serious enquiries, please!\">#{result.contact}</a></p>"
        
        return content 
    
    placeMarker = (center, map, draggable, content, callback) ->
        marker = new google.maps.Marker 
            position: center 
            map: map 
            draggable: draggable
            
        if content 
            marker.content = content 
            
        return marker 
        
        if callback 
            callback(marker)
    
    setLatLng = (position) ->
        $("form .field #place_latitude").val(position.lat())
        $("form .field #place_longitude").val(position.lng())
    
    reverseGeocode = (position, callback) ->
        geocoder = new google.maps.Geocoder()
        
        $("form .field #place_address").attr("disabled", "disabled")
        
        geocoder.geocode( { 'latLng' : position }, (results, status) ->
            $("form .field #place_address").removeAttr("disabled")
            $("form .field #place_address").val(results[0].formatted_address)
            
            if callback
                callback(results)
        )
        
    getPosition = (callback) ->
        if navigator.geolocation 
            navigator.geolocation.getCurrentPosition((result) ->
                position = new google.maps.LatLng(result.coords.latitude, result.coords.longitude)
                
                callback(position)
            , () ->
                callback(false) 
            )
    encodeURL = (facet, values) ->
        valueString = values.join('-')
        valueString = encodeURIComponent(valueString)
        
        regex = RegExp("(&|#)(#{facet})(?:=(?:(?:\\w+(?:(?:%20)|-)?)+)?)?(&|$)", "g")
        
        if regex.test(location.hash)
            location.hash = location.hash.replace(regex, "$1$2=#{valueString}$3")
        else 
            if /^#?$/.test(location.hash)
                location.hash += "#{facet}=#{valueString}"
            else 
                location.hash += "&#{facet}=#{valueString}"
    
    getFacetSliderOrientation = () ->
        if window.innerWidth > window.innerHeight 
            return "vertical"
        else
            return "horizontal"
    
    renderFacets = (query, facetFilters, numericFilters, orientation) ->
        values = 
            "price": 
                "min": facetsStats.price.min
                "max": facetsStats.price.max
            "bathrooms":
                "min": facetsStats.bathrooms.min
                "max": facetsStats.bathrooms.max
            "rooms":
                "min": facetsStats.rooms.min
                "max": facetsStats.rooms.max
        
        $("#searchbar").val(getQuery())
        
        place_for_index = 0 
        
        while place_for_index < facetFilters.length 
            place_for = facetFilters[place_for_index].split(":")[1]
            
            for option in $("#facets.container #place_for option")
                if option.value == place_for
                    option.selected = true 
                
            place_for_index++
        
        for numericFilter in numericFilters
            if numericFilter.split(/:|=/)[1].split(" to ")[1] != undefined 
                values[numericFilter.split(/:|=/)[0]] = 
                    "min": parseInt(numericFilter.split(/:|=/)[1].split(" to ")[0])
                    "max": parseInt(numericFilter.split(/:|=/)[1].split(" to ")[1])
            else 
                values[numericFilter.split(/:|=/)[0]] = 
                    "min": facetsStats[numericFilter.split(/:|=/)[0]].min
                    "max": parseInt(numericFilter.split(/:|=/)[1].split(" to ")[0])
        
        for inputBox in $("#facets.container .facet span input[type=number].minimum")
            inputBox.value = values[inputBox.dataset["facet"]]["min"]
            
        for inputBox in $("#facets.container .facet span input[type=number].maximum")
            inputBox.value = values[inputBox.dataset["facet"]]["max"]
        
        $("#facets.container #sliders.container input").change () ->
            facet = this.dataset['facet']
            
            values = [this.parentElement.parentElement.children[0].firstElementChild.value, this.parentElement.parentElement.children[2].firstElementChild.value]
            
            encodeURL(facet, values)
            
            $("#facets.container #sliders.container #" + facet + " .slider").slider( "option", "values", values );
            
            delay (->
                search(getQuery(), getFacetFilters(), getNumericFilters(), (content) ->
                    renderList(content)
                )
            ), 500
            return 
        
        $("#facets.container #place_for").change () ->
            facet = "for"
            values = [ this.value ]
            
            encodeURL(facet, values)
            
            search(getQuery(), getFacetFilters(), getNumericFilters(), (content) ->
                renderList(content)
            )
        
        $("#facets.container .slider.container .slider").slider
            range: true,
            create: () ->
                $(this).slider( "option", "orientation", orientation )
                $(this).slider( "option", "min", $(this).data("min") )
                $(this).slider( "option", "max", $(this).data("max") )
                $(this).slider( "option", "values", [ values[$(this).data("facet")]['min'], values[$(this).data("facet")].max ] )
            stop: (event, ui) ->
                facet = ui.handle.parentElement.dataset.facet 
                
                $("##{facet} .minimum").val(ui.values[0])
                $("##{facet} .maximum").val(ui.values[1])
                
                values = [
                    ui.values[0]
                    ui.values[1]
                ]
                
                encodeURL(facet, values)
                
                search(getQuery(), getFacetFilters(), getNumericFilters(), (content) ->
                    renderList(content)
                )
            slide: (event, ui) ->
                facet = ui.handle.parentElement.dataset.facet 
                
                $("##{facet} .minimum").val(ui.values[0])
                $("##{facet} .maximum").val(ui.values[1])
                
                values = [
                    ui.values[0]
                    ui.values[1]
                ]
                
                encodeURL(facet, values)
    
    renderList = (list) ->
        content = ""
        
        for listing in list 
            content += 
                "<div class=\"listing\">" + 
                "<h1><a href=\"/places/#{listing.objectID}\">#{listing.address}</a></h1>" + 
                "<p>#{listing.description}</p>" + 
                "<p>Price: $#{parseFloat(listing.price).toLocaleString()}, For: #{listing.for}</p>" +
                "<p>Rooms: #{listing.rooms}, Bathrooms: #{listing.bathrooms}</p>" +
                "</div>"
                
        $("#content.container").html(content)
    
    initializeMap = (mapContainer, position) ->
        map = new google.maps.Map(mapContainer, {
            center: position
            zoom: 14
        });
        
        return map 
    
    placeMarker = (map, position, draggable) ->
        marker = new google.maps.Marker 
            position: position
            map: map
            draggable: draggable
        
        return marker 
    
    setLatLng = (position) ->
        $("#latitude_field #place_latitude").val(position.lat())
        $("#longitude_field #place_longitude").val(position.lng())
    
    reverseGeocode = (position, callback) ->
        geocoder = new google.maps.Geocoder()
        
        $("form .field #place_address").attr("disabled", "disabled")
        
        geocoder.geocode( { 'latLng' : position }, (results, status) ->
            if callback
                callback(results)
        )
    
    if /^\/(places)?\/?$/.test(location.pathname)
        renderFacets(getQuery(), getFacetFilters(), getNumericFilters(), getFacetSliderOrientation())
        
        window.addEventListener 'resize', ->
            $(".slider.container .slider").slider("option", "orientation", getFacetSliderOrientation())
    else if /^\/places\/\d+(\/|(\/edit\/?))?$/.test(location.pathname)
        mapContainer = $("#map")[0]
        
        position = new google.maps.LatLng(parseFloat(mapContainer.dataset['latitude']), parseFloat(mapContainer.dataset['longitude']))
        
        map = initializeMap(mapContainer, position)
        
        if /^\/places\/\d+\/edit\/?$/.test(location.pathname)
            marker = placeMarker(map, position, true)
            
            marker.addListener('dragend', () ->
                setLatLng(marker.position)
                
                $(".field #place_address").attr("disabled", "disabled")
                
                reverseGeocode(marker.position, (results) ->
                    if results.length > 0 
                        $(".field #place_address").val(results[0].formatted_address)
                    else 
                        $("#alert").html("There's nothing there! Try again?")
                    
                    $(".field #place_address").removeAttr("disabled")
                )
            )
        else 
            marker = placeMarker(map, position, false)
    else if /^\/places\/new\/?$/.test(location.pathname)
        mapContainer = $("#map")[0]
        
        getPosition((position) ->
            if position 
                position = position 
            else 
                position = new google.maps.LatLng(40.7058316, -74.2581884)
                
                $("#notice").html("You didn't provide your location. Defaulting to New York, New York!")
            
            map = initializeMap(mapContainer, position)
            
            marker = placeMarker(map, position, true)
            
            marker.addListener('dragend', () ->
                setLatLng(marker.position)
                
                $(".field #place_address").attr("disabled", "disabled")
                
                reverseGeocode(marker.position, (results) ->
                    if results.length > 0 
                        $(".field #place_address").val(results[0].formatted_address)
                    else 
                        $("#alert").html("There's nothing there! Try again?")
                    
                    $(".field #place_address").removeAttr("disabled")
                )
            )
        )
    else if /^\/you\/?$/.test(location.pathname)
        places = window.places 
        window.places = undefined
    
    checkVisited()