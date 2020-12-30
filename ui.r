library(shiny)
options(shiny.autoload.r = T)
library(shinydashboard)
library(shinyjs)
library(shinyBS)
library(shinybusy)
library(dplyr)
library(readr)
rendering.msg="...Please wait while loading your surprise..."
encoding.msg ="...Finalizing encoding..."
# Shiny >= 1.4 : code in "R/" directory adjacent to the app will be loaded automatically
# source("R/birthday_plot.r") 
# source("R/birthday_song.r")
# source("R/theme_black.r")

jscode <- "
shinyjs.collapse = function(boxid) { $('#' + boxid).closest('.box').find('[data-widget=collapse]').click(); }
shinyjs.blink = function(id) { $('#' + id).fadeOut(500).fadeIn(500, blink); }
"
csscode <- "
  .shiny-notification { 
    position: fixed;
    top: 45px; right: 40%; 
    min-width: 20%; 
    margin-top: 5px; 
  }
  .multicolor { 
    text-align: center;
    font-weight: bold;
    font-size: 250%;
    background-image: linear-gradient(to left, violet, indigo, green, blue, yellow, orange, red);
    -webkit-background-clip: text;
    -moz-background-clip: text;
    background-clip: text;
    color: transparent;
  }
  .blinking {
    z-index: 105;
    animation: blinker 1s linear infinite;
  }
  .blink_me {
    animation: blinker 1s linear infinite;
  }
  @keyframes blinker {
    50% { opacity: 0; }
  }
"
uibody = dashboardBody(
  useShinyjs(),
  extendShinyjs(text = jscode,functions = c("collapse","blink")),
  fluidRow(
    box(width = 3, 
        background = 'blue', 
        solidHeader = F, status='primary',
        title = 'Click me if you dare!',
        bsButton(inputId="playsound", label = "",size='large',style='primary',icon = icon('play-circle')),
        uiOutput('wishes'),
    )
  ),
  tags$head(tags$style(csscode)),
  fluidRow(
    box( id='growth',
         title='Growth rate',
         width = 8, 
         background = 'black', collapsed = T, collapsible = T,
         solidHeader = T, status='primary',
         uiOutput('song'),
         imageOutput(outputId = "birthdayAnim", height=600,width=1000)
    )
  ),
  fluidRow(
    box( id='sessioninfo',
         title='Session info',
         status='info',
         width = 12, 
         collapsed = T, collapsible = T,
         htmlOutput("sessionInfo")
    )
  )
)

ui <- dashboardPage(
  header = dashboardHeader(title = 'Surprise...'),
  sidebar = dashboardSidebar(collapsed = T),
  body = uibody,
  skin = "black"
)

