$ ->

	$.fn.animationComplete = (callback) ->
    if Modernizr.cssanimations
      animationEnd = "animationend webkitAnimationEnd"
      $(@).one animationEnd, callback if $.isFunction(callback)      
    else
      setTimeout callback, 0
      $(@)

  $.fn.transitionComplete = (callback) ->
    if Modernizr.csstransitions
      transitionEnd = "transitionend webkitTransitionEnd oTransitionEnd"
      $(@).one transitionEnd, callback if $.isFunction(callback)
    else
      setTimeout callback, 0
      $(@)
    
  $.fn.animateCSS = (animation, callback) ->
    animation or (animation = "none")
    $(@).addClass("animated " + animation).animationComplete ->
      $(@).removeClass "animated " + animation
      callback() if callback
    $(@)
  
  $.fn.transitionCSS = (transition, callback) ->
    transition or (transition = "none")
    $(@).addClass("transitioned " + transition).transitionComplete ->
      $(@).removeClass "transitioned " + transition
      callback() if callback
    $(@)  

  # From jquery mobile
  # stripped all relevant functions

  $.getScreenHeight = ->
    # Native innerHeight returns more accurate value for this across platforms,
    # jQuery version is here as a normalized fallback for platforms like Symbian
    window.innerHeight || $( window ).height();

  $.getMaxScrollForTransition = ->
    $.getScreenHeight() * 3
  

  $.pageTransition = (name, reverse, toScroll, $to, $from) ->
    sequential = false
    deferred = new $.Deferred()
    reverseClass = (if reverse then " reverse" else "")
    activePageClass = "active "
    maxTransitionWidth = false
    # active = $.mobile.urlHistory.getActive()
    # toScroll = active.lastScroll or $.mobile.defaultHomeScroll
    screenHeight = $.getScreenHeight()
    maxTransitionOverride = maxTransitionWidth isnt false and $(window).width() > maxTransitionWidth
    none = maxTransitionOverride or not name or name is "none" or Math.max($(window).scrollTop(), toScroll) > $.getMaxScrollForTransition()
    toPreClass = " page-pre-in"
    $viewport = $('.mobile-viewport')

    toggleViewportClass = (out) ->
      if out
        $viewport.removeClass "mobile-viewport-transitioning viewport-#{name}"
      else 
        $viewport.addClass "mobile-viewport-transitioning viewport-#{name}"

    focusPage = (page) ->
      autofocus = page.find("[autofocus]")
      pageTitle = page.find(".title:eq(0)")
      if autofocus.length
        autofocus.focus()
        return
      if pageTitle.length
        pageTitle.focus()
      else
        page.focus()

    scrollPage = ->          
      # By using scrollTo instead of silentScroll, we can keep things better in order
      # Just to be precautios, disab-le scrollstart listening like silentScroll would
      # $.event.special.scrollstart.enabled = false
      unless scrollTo then window.scrollTo(0, toScroll)
      
      # reenable scrollstart listening like sile=ntScroll would
      # setTimeout (->
        # $.event.special.scrollstart.enabled = true
      # ), 150

    cleanFrom = ->
      $from.removeClass(activePageClass + " out in reverse " + name).height ""

    startOut = ->
      # if it's not sequential, call the doneOut transition to start the TO page animating in simultaneously
      unless sequential
        doneOut()
      else
        $from.animationComplete doneOut
      
      # Set the from page's height and start it transitioning out
      # Note: setting an explicit height helps eliminate tiling in the transitions
      $from.height(screenHeight + $(window).scrollTop()).addClass name + " out" + reverseClass

    doneOut = ->
      cleanFrom() if $from and sequential
      startIn()

    startIn = ->

      # Prevent flickering in phonegap container: see comments at #4024 regarding iOS
      $to.css "z-index", -10
      $to.addClass activePageClass + toPreClass
      
      # Send focus to page as it is now display: block
      focusPage $to
      
      # Set to page height
      $to.height screenHeight + toScroll
      # scrollPage()
      
      # Restores visibility of the new page: added together with $to.css( "z-index", -10 );
      $to.css "z-index", ""
      $to.animationComplete doneIn unless none
      $to.removeClass(toPreClass).addClass name + " in" + reverseClass
      doneIn() if none

    doneIn = ->
      cleanFrom() if $from unless sequential
      $to.removeClass("out in reverse " + name).height ""
      toggleViewportClass true
      $to.addClass activePageClass

      # In some browsers (iOS5), 3D transitions block the ability to scroll to the desired location during transition
      # This ensures we jump to that spot after the fact, if we aren't there already.
      scrollPage()  if $(window).scrollTop() isnt toScroll
      deferred.resolve name, reverse, toScroll, $to, $from, true

    if $from and not none
      startOut()
    else        
      doneOut()
    deferred.promise()
	
	$("input:submit").click ->
		$('form').submit()
		$(@).val "Sending..."
		$("input:submit").attr "disabled", true

	$('.prop-list a').click ->
		$('#prop-input').val $(@).parent('li').index()
		$.pageTransition('slide', false, 0, $('#form-page-2'), $('#form-page-1')).then ->
  		$(".chzn-select").chosen()


