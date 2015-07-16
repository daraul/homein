# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Add a method to the string prototype to capitalize the first letter of a String
# SO surprised javascript doesn't already have this 
String.prototype.capitalizeFirstLetter = () -> 
    this.charAt(0).toUpperCase() + this.slice(1)

$(document).ready ->
    ApplicationID = '3J0AVN6KSY'
    
    SearchOnlyApiKey = 'fde549a36ac77931bd57966851982602'
    
    client = algoliasearch(ApplicationID, SearchOnlyApiKey)
    
    index = client.initIndex('homein_places_' + window.environment)
    
    # DOM initialization
    places_container = $("#places-container")
    searchbar = $("#searchbar")
    facets_container = $("#facets-container")
    
    window.currentfacets = {}
    window.currentquery = ""
    window.currentcontent = ""
    window.maxmins = {}
    
    window.setMaxMins = () ->
        if location.pathname == "/"
            index.search("", 
            {
                facets: "*"
            },
            (err, content) ->
                if err 
                    console.error(err)
                else
                    maxmins = {} 
                    
                    for facet of content.facets_stats
                        maxmins[facet] = [ content.facets_stats[facet].min, content.facets_stats[facet].max ]
                        
                    window.maxmins = maxmins
                    
                    decodeURLParams()
                    
                    search(window.currentquery, prepareFacets(window.currentfacets))
                )
        else if location.pathname.split("/")[2] == "new"
        else 
            decodeURLParams()
    
    renderPlaces = (places) ->
        places_container.empty()
        
        places_html = "" 
        
        for place in places 
            places_html += 
                "<a href='/places/" + place.id + "'><h3>" + place.address + "</a>" +
                "<p>" + place.description + "</p>" + 
                "<p>Price: $" + place.price + "</p>"
                
        places_container.html(places_html)
    
    prepareFacets = (facets, url) ->
        if url 
            queryFacets = ""
            for facet of facets 
                queryFacets += "&" + facet + "=" + facets[facet][0] + "-" + facets[facet][1]
        else 
            queryFacets = []
            for facet of facets 
                queryFacets.push facet + ">=" + facets[facet][0]
                queryFacets.push facet + "<=" + facets[facet][1]
        
        queryFacets
        
    setURLParams = (query, facets) ->
        urlParams = "#"
        urlParams += "q=" + encodeURIComponent(searchbar.val())
        urlParams += prepareFacets(facets, true)
        
        location.replace urlParams
        
    decodeURLParams = () ->
        if location.pathname == "/"
            urlParams = decodeURIComponent(location.hash)
            
            if urlParams.split("&")[0].split("=")[1]
                query = urlParams.split("&")[0].split("=")[1]
            else 
                query = ""
            
            if urlParams.split("&").splice(1)[0]
                facets = {} 
                for facet of window.maxmins 
                    facets[facet] = [ window.maxmins[facet][0], window.maxmins[facet][1] ]
                    
                for facet in urlParams.split("&").splice(1)
                    facets[facet.split("=")[0]] = [ facet.split("=")[1].split("-")[0], facet.split("=")[1].split("-")[1] ] 
            else 
                facets = {} 
                
                for facet of window.maxmins 
                    facets[facet] = [ window.maxmins[facet][0], window.maxmins[facet][1] ]
            
            window.currentfacets = facets
            
            window.currentquery = query 
            searchbar.val(query)
        else 
            currentPlace = location.pathname.split("/")[2]
            
            numericFilter = "id=" + currentPlace
            
            search("", numericFilter)
        
    renderFacets = (facets) ->
        facets_html = ""
        
        for facet of facets
            if facet == 'price'
                facets_html += 
                    "<p id='" + facet + "'>" + facet.capitalizeFirstLetter() + ": $" + window.currentfacets[facet][0] + " - $" + window.currentfacets[facet][1] + "</p>
                    <div data-facet='" + facet + "'
                    data-max='" + window.currentfacets[facet][1] + "'
                    data-min='" + window.currentfacets[facet][0] + "'
                    ></div>"
            else
                facets_html += 
                    "<p id='" + facet + "'>" + facet.capitalizeFirstLetter() + ": " + window.currentfacets[facet][0] + " - " + window.currentfacets[facet][1] + "</p>
                    <div data-facet='" + facet + "'
                    data-max='" + window.currentfacets[facet][1] + "'
                    data-min='" + window.currentfacets[facet][0] + "'
                    ></div>"
                
        facets_container.html(facets_html)
        
        $("#facets-container div").slider 
            range: true
            create: () ->
                $(this).slider( "option", "min", window.maxmins[$(this).data("facet")][0] )
                $(this).slider( "option", "max", window.maxmins[$(this).data("facet")][1] )
                $(this).slider( "option", "values", [ window.currentfacets[$(this).data("facet")][0], window.currentfacets[$(this).data("facet")][1] ] )
            stop: (event, ui) ->
                label = $(ui.handle.parentNode.previousElementSibling)
                if label[0].id == 'price'
                    label.html(label[0].id.capitalizeFirstLetter() + ": $" + ui.values[0] + " - $" + ui.values[1])
                else 
                    label.html(label[0].id.capitalizeFirstLetter() + ": " + ui.values[0] + " - " + ui.values[1])
                    
                window.currentfacets[label[0].id] = [ui.values[0], ui.values[1]]
                
                setURLParams(window.currentquery, window.currentfacets)
                search(window.currentquery, prepareFacets(window.currentfacets))
            slide: (event, ui) ->
                label = $(ui.handle.parentNode.previousElementSibling)
                if label[0].id == 'price'
                    label.html(label[0].id.capitalizeFirstLetter() + ": $" + ui.values[0] + " - $" + ui.values[1])
                else 
                    label.html(label[0].id.capitalizeFirstLetter() + ": " + ui.values[0] + " - " + ui.values[1])
    
    search = (query, facetfilters) ->
        index.search(query, 
        {
            facets: "*"
            numericFilters: facetfilters 
        },
        (err, content) ->
            if err 
                console.error(err)
            else
                window.currentcontent = content 
                
                renderPlaces(content.hits)
                renderFacets(window.currentfacets)
                
                initializeMap(true)
            )
    
    initializeMap = (openInfoWindow) ->
        if location.pathname == "/"
            center = new google.maps.LatLng(6.802066748199674, -58.16407062167349) # Broad and lying street, GT 
            
            infoWindowsContent = []
            infoWindowsOptions = []
            infoWindows = []
            
            mapOptions = 
                zoom: 2  # I want to be able to see everything. I'll figure out how to auto zoom to see all markers later 
                center: center
            
            map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions) 
            
            places = window.currentcontent.hits 
            markers = []
            
            for place of places 
                thislatlng = new google.maps.LatLng(places[place].latitude, places[place].longitude) # I'll need this later 
                
                # Create the markers 
                markers[place] = new google.maps.Marker
                    position: thislatlng
                    map: map
                    title: places[place].address
                    draggable: false
                    
                markers[place]["id"] = place 
                    
                # Set the info window content 
                infoWindowsContent[place] = "<a href='places/" + places[place].id + "'><h2>" + places[place].address + "</h2></a><br />" + 
                    "<p>" + places[place].description.replace(/\n/g, "<br />") + "</p><br />" +
                    "<hr />" + 
                    "<strong>Rooms:</strong> " + places[place].rooms + " | <strong>Bathrooms:</strong>" + places[place].bathrooms + "<br />" + 
                    "<strong>Price:</strong> " + places[place].price + "<br />" 
                    "<strong>Contact:</strong> " + places[place].user_id + "<br />"
                
                # Create the info windows 
                infoWindow = new google.maps.InfoWindow
                    content: infoWindowsContent[place]
                    position: markers[place].position
                
                google.maps.event.addListener markers[place], 'click', ->
                    infoWindow.setContent(infoWindowsContent[this.id])
                    infoWindow.open map, this
            
            markerClusterer = new MarkerClusterer(map, markers)
        else if location.pathname.split("/")[3] == "edit"
        else if location.pathname.split("/")[2] == "new"
        else 
            place = window.currentcontent.hits[0]
            
            thislatlng = new google.maps.LatLng(place.latitude, place.longitude)
            
            mapOptions = 
                zoom: 17 
                center: thislatlng
                
            map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)
            
            marker = new google.maps.Marker 
                position: thislatlng
                map: map 
                title: place.address 
                draggable: false 
                
            infoWindowContent = "<a href='places/" + place.id + "'><h2>" + place.address + "</h2></a><br />" + 
                    "<p>" + place.description.replace(/\n/g, "<br />") + "</p><br />" +
                    "<hr />" + 
                    "<strong>Rooms:</strong> " + place.rooms + " | <strong>Bathrooms:</strong>" + place.bathrooms + "<br />" + 
                    "<strong>Price:</strong> " + place.price + "<br />" +
                    "<strong>Contact:</strong> " + place.user_id + "<br />"
                    
            infoWindow = new google.maps.InfoWindow 
                content: infoWindowContent
                position: thislatlng 
                
            infoWindow.open map, marker 
            
            google.maps.event.addListener marker, 'click', ->
                    infoWindow.open map, marker
    
    setMaxMins()
    
    searchbar.keyup ->
        window.currentquery = searchbar.val()
        setURLParams(window.currentquery, window.currentfacets)
        search(window.currentquery, prepareFacets(window.currentfacets))