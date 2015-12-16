# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Add a method to the string prototype to capitalize the first letter of a String
# SO surprised javascript doesn't already have this 
String.prototype.capitalizeFirstLetter = () -> 
    this.charAt(0).toUpperCase() + this.slice(1)

$(document).on 'page:change', () ->
    $.xhrPool = []

    $.xhrPool.abortAll = ->
        $(this).each (idx, jqXHR) ->
            jqXHR.abort()
        $.xhrPool.length = 0
    
    $.ajaxSetup
        beforeSend: (jqXHR) ->
            $.xhrPool.abortAll()
            
            $.xhrPool.push jqXHR
        complete: (jqXHR) ->
            index = $.xhrPool.indexOf(jqXHR)
            
            if index > -1
                $.xhrPool.splice index, 1
    
    $("#places_search").submit () ->
        $.ajax({
            url: $("#places_search").attr("action")
            data: $("#places_search").serialize()
            dataType: "script"
            beforeSend: (jqXHR) ->
                $.xhrPool.abortAll()
            
                $.xhrPool.push jqXHR
                
                $('#listings.container, #infiniteScrolling').html("")
        })
        
        return false
        
    if $('#infiniteScrolling').size() > 0
        $("#content.container").on 'scroll', ->
            more_posts_url = $('.pagination a.next_page').attr('href')
            
            if more_posts_url && $("#content.container").scrollTop() > ($("#listings.container").height() - $("#content.container").height())
                $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
                $.getScript more_posts_url
            return
        return