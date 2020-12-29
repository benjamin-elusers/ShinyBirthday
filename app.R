library(shiny)
library(shinydashboard)
library(shinyjs)
library(gganimate)
library(ggplot2)
library(prettyunits)
library(dplyr)
library(readr)
library(ggthemes)
library(gifski)
library(png)
library(shinyBS)
source('R/theme_black.R')
source('R/birthday_song.r')

birthday=data.frame(age=1:30,years=1:30,current=1*((1:30==30)))
pal=c("0"="#cccccc","1"="#ff460f","2"="#f5bd3d","3"="#ffccd7","4"="#44a7f2","5"="#ffffff")
msg='After detailed analysis,\nwe conclude that your age\nis growing in a very reliable way'
waiting.msg="...Please wait while loading your surprise..."

get_audio_tag <- function(filename,auto=NULL,ctl=NULL,rep=NULL, setvol="setHalfVolume()") {
    au = tags$audio(src = filename, type = "audio/wave",  controls = ctl, autoplay=ctl, )
    if(!is.null(rep)){ au = tagAppendAttributes(au,loop=rep) }
    if(!is.null(setvol)){  au =tagAppendAttributes(au,onloadeddata=setvol) }
    return(au)
}

get_audio_birthday = function(){
    get_audio_tag(filename=get.birthday.song(),rep=T,ctl=T,auto=T,setvol="setMaxVolume()")
}


get.birthday.plot = function(B=birthday){
    require(ggplot2)
    require(ggthemes)
    p = ggplot(B,aes(x=age,y=years,fill=factor(current))) + 
        theme_black(base_size = 18) + theme(legend.position='none') +
        xlab('Age') + ylab('Years') + 
        geom_linerange(aes(ymin=years,ymax=years+1.5),size=2,color='#44a7f2')+
        geom_point(shape=21,size=2.5,aes(x=age,y=years+1.6),fill='#f5bd3d',color='#f5bd3d') + 
        geom_point(shape=24,size=1.8,aes(x=age,y=years+1.75),fill='#f5bd3d',color='#f5bd3d') + 
        geom_bar(stat='identity') + 
        annotate(geom='text',x=30,y=40, label=sprintf("Spearman rank correlation\n R=1.0 (p=0.0e0)"),size=4, color="#ffffff",hjust='inward',vjust='inward')
    return(p)
}

get.birthday.anim = function(animated=T,...){
    require(gganimate) 
    require(gifski)
    #require(magick)
    #require(av)
    
    anim =  get.birthday.plot() + 
        scale_fill_manual(values = pal,aesthetics = c('color','fill')) +
        transition_states(age,wrap=T) + 
        ease_aes()
    if(!animated){ return(anim) }
    animate(plot = anim, ... )
            
}

uibody = dashboardBody(
    fluidRow(
        box(width = 3, 
            background = 'blue', 
            solidHeader = F, status='primary',
            title = 'Click me if you dare!',
            bsButton(inputId="playsound", label = "",size='large',style='primary',icon = icon('play-circle'))
        )
    ),
    tags$head(tags$style(".shiny-notification {position: fixed; top: 0%; right: 40%; min-width: 20%;")),
    fluidRow(
        box( width = 8, 
            background = 'black', collapsed = F, collapsible = T,
            solidHeader = T, status='primary',title = 'Growth rate',
            textOutput('waiting'),
            uiOutput('song'),
            imageOutput(outputId = "birthdayAnim", height=600,width=1000)
        )
    )
)

uidashpage <- dashboardPage(
    header = dashboardHeader(title = 'Happy BD!'),
    sidebar = dashboardSidebar(collapsed = T),
    body = uibody,
    skin = "black"
)

server <- function(input, output,session){

    # Make the audio player with embedded birthday song (as base64 dataURI)
    observeEvent(input$playsound,{ output$song <- renderUI({ get_audio_birthday() }) })

    
    observeEvent(input$playsound,{
        
        # Make static birthday barplot
        output$birthdayPlot <- renderPlot({ 
            get.birthday.plot() +
                scale_fill_manual(values = pal,aesthetics = c('color','fill')) +
                annotate(geom='text',x=2,y=38, label=sprintf("%s",msg),hjust='inward',vjust='inward',size=10, color="#ffffff")
        })

        # Render aniimated birthday barplot with responsive size and progress bar
        output$birthdayAnim <- renderImage({
            NFRAMES = 100
            NANIMATED = NFRAMES + 25
            
            progress <- shiny::Progress$new(max = NANIMATED)
            progress$set(message = "Rendering", value = 0)
            on.exit(progress$close())
            
            outfile <- tempfile(fileext='.gif')
            
            WID <- session$clientData$output_birthdayAnim_width
            HEI <- session$clientData$output_birthdayAnim_height
            
            updateShinyProgress <- function(detail) { progress$inc(1, detail = detail) }
            
            p=get.birthday.anim(animated = F) + annotate(geom='text',x=2,y=38, label=sprintf("%s",msg),hjust='inward',vjust='inward',size=10, color="#ffffff")

            anim_save(filename = "outfile.gif", 
                      animation =  animate(p, duration = 5, nframes=100, end_pause = 25,
                                           width=WID,height=HEI, 
                                           renderer = gifski_renderer(loop=T), device='png',
                                           update_progress = updateShinyProgress)
            )

            list(src = "outfile.gif",
                 contentType = 'image/gif', 
                 width = WID,
                 height = HEI,
                 alt = "This is alternate text"
            )}, deleteFile = TRUE)
        })
}


                    
# Run the application 
shinyApp(ui = uidashpage, server = server)
