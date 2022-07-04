# Javascript for theme
tags$head(
  tags$script(
    'Shiny.addCustomMessageHandler("ui-tweak", function(message) {
                var os = message.os;
                var skin = message.skin;
                if (os === "Markdown") {
                  $("html").addClass("md");
                  $("html").removeClass("ios");
                  $("html").removeClass("aurora");
                  $(".tab-link-highlight").show();
                } else if (os === "iOS") {
                  $("html").addClass("ios");
                  $("html").removeClass("md");
                  $("html").removeClass("aurora");
                  $(".tab-link-highlight").hide();
                } else if (os === "Aurora") {
                  $("html").addClass("aurora");
                  $("html").removeClass("md");
                  $("html").removeClass("ios");
                  $(".tab-link-highlight").hide();
                }
                
                // Default dark theme
                $("html").addClass("theme-dark");
              });
            '
    # Removed following from script:
    # if (skin === "dark") {
    #   $("html").addClass("theme-dark");
    # } else {
    #   $("html").removeClass("theme-dark");
    # }
    # Now just defaults to dark theme
  )
)