# Shiny >= 1.4 : code in "R/" directory adjacent to the app will be loaded automatically
# source("R/birthday_plot.r") 
# source("R/birthday_song.r")
NAME="Meta"
ANIMATION_LOADED=F
ENCODED=F

rendering.msg="...Please wait while loading your surprise..."
encoding.msg ="...Finalizing encoding..."

server <- function(input, output,session){
  
  # Make the audio player with embedded birthday song (as base64 dataURI)
  observeEvent(input$playsound,{ output$song <- renderUI({ get_audio_birthday() }) })
  
  # Show birthday wishes message with multicolor and blinking
  observeEvent(input$playsound,{
    output$wishes <- renderUI({ 
      span(id='colormsg',sprintf("Happy Birthday %s!",NAME),class='multicolor blink_me')
    })
  })
  
  # Uncollapse the box which will hold the birthday plot 
  #observeEvent(input$playsound,{ updateCollapse(session, "growth", open = "growth") }) # USING shinyBS
  observeEvent(input$playsound,{ js$collapse("growth");  })
  
  # Render birthday animation / plot static birthday  plot
  observeEvent(input$playsound,{

    # Make static birthday barplot
    output$birthdayPlot <- renderPlot({ 
      get_birthday_plot() +
        scale_fill_manual(values = pal,aesthetics = c('color','fill')) +
        annotate(geom='text',x=2,y=38, label=sprintf("%s",msg),hjust='inward',vjust='inward',size=10, color="#ffffff")
    })
    
    # Render animated birthday barplot with responsive size and progress bar
    output$birthdayAnim <- renderImage({
      
      
      NFRAMES = 100
      NPAUSE  = 25
      NANIMATED = NFRAMES - NPAUSE
      FPS=10
      ANIMATION_LOADED=F
      ENCODED=F

      progress <- shiny::Progress$new(max = NANIMATED)
      progress$set(message = "Rendering", value = 0)
      on.exit(progress$close())
      updateShinyProgress <- function(detail) { progress$inc(1, detail = detail) }
      
      # Get the static birthday plot
      show_modal_spinner(spin = "cube-grid", color = "firebrick", text = rendering.msg)
      p = get_birthday_anim(animated = F) + 
          annotate(geom='text',x=2,y=38, label=sprintf("%s",msg),hjust='inward',vjust='inward',size=10, color="#ffffff")
      # Retrieve dimensions of the output area
      WID <- session$clientData$output_birthdayAnim_width
      HEI <- session$clientData$output_birthdayAnim_height
      # Animate the bars of the birthday plot as frames
      anim = animate(p, duration = 5, nframes=NFRAMES, end_pause = NPAUSE,
                     width=WID,height=HEI, 
                     renderer = gifski_renderer(loop=T), device='png',
                     update_progress = updateShinyProgress)
      ANIMATION_LOADED=T
      remove_modal_spinner()

      # Encoding the animation to a .gif
      outfile <- tempfile(fileext='.gif')
      anim_save(outfile, animation =  anim )
      ENCODED=T
      list(src = outfile,
           contentType = 'image/gif', 
           width = WID,
           height = HEI,
           alt = "This is alternate text"
      )}, deleteFile = TRUE)
  })
}

## Run the application 
#shinyApp(ui = ui, server = server)
