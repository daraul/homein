# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Add a method to the string prototype to capitalize the first letter of a String
# SO surprised javascript doesn't already have this 
String.prototype.capitalizeFirstLetter = () -> 
    this.charAt(0).toUpperCase() + this.slice(1)

$(document).on 'page:change', () ->
    $("#places_search").submit () ->
        $("#notice").html("Searching...")
        
        $('#listings.container').html("")
        
        $.get($("#places_search").attr("action"), $("#places_search").serialize(), null, "script")
        
        return false 