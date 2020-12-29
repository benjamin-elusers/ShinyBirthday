library(gganimate)
library(ggplot2)
library(ggthemes)
library(gifski)
library(png)
library(prettyunits)
#RDIR=dirname(.rs.api.getSourceEditorContext()$path)
#source(file.path(RDIR,"theme_black.r"))
pal=c("0"="#cccccc","1"="#ff460f","2"="#f5bd3d","3"="#ffccd7","4"="#44a7f2","5"="#ffffff")
msg='After detailed analysis,\nwe conclude that your age\nis growing in a very reliable way'

make_birthday_data = function(max_age=30){
  birthday=data.frame(age=1:max_age,years=1:max_age,current=1*((1:max_age==max_age)))
  return(birthday)
}

get_birthday_plot = function(B=make_birthday_data()){
  require(ggplot2)
  require(ggthemes)
  # barplot age vs years with candles on top
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

get_birthday_anim = function(animated=T,...){
  require(gganimate) 
  require(gifski)
  #require(magick)
  #require(av)
  anim =  get_birthday_plot() + 
    scale_fill_manual(values = pal,aesthetics = c('color','fill')) +
    transition_states(age,wrap=T) + 
    ease_aes()
  if(!animated){ return(anim) }
  animate(plot = anim, ... )
}

get_anim_uri = function(anim){
  require(base64enc)
  b64 <- dataURI(file = anim, mime = "image/gif")
  return(b64)
}

