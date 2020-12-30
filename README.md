# ShinyBirthday

Here is a shiny app I've made for wishing happy birthday to my colleague Meta!
> All the content is 100% made using R code !_(e.g. not using any external resource file)_

## Testing

Click for a [demo](https://benjamin-elusers.shinyapps.io/ShinyBirthday/ "ShinyBirthday app")! 
_(Shiny app hosted at shinyapps.io)_

## Description

This app does the following:

- Using shinydashboard layout with boxes
- Bootstrap button with icon to launch different events


  - Blinking multicolor birthday wish message using CSS
  - Uncollapse a box using custom JS function
  - Making and playing birthday song as wave audio (passed as a dataURI with base64 encryption)
  - Showing animated candles as bar plot (saved as temporary .gif)

## Dependencies

R packages used:

- *shinyverse*: shiny / shinydashboard / shinyjs / shinyBS / shinybusy / htmltools
- *tidyverse*: dplyr / readr / stringr / 
- *graphics*: ggplot2 / ggthemes / gganimate / gifski / png
- *others* : audio / prettyunits

