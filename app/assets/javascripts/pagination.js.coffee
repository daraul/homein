jQuery ->
    if $('#infiniteScrolling').size() > 0
        $("#content.container").on 'scroll', ->
            more_posts_url = $('.pagination a.next_page').attr('href')
            
            if more_posts_url && $("#content.container").scrollTop() > ($("#listings.container").height() - $("#content.container").height())
                $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
                $.getScript more_posts_url
            return
        return