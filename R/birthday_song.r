library(dplyr)
library(stringr)
library(audio)
library(htmltools)

towords  <- function(x){ return( unlist(strsplit(x,split="\\s")) ) } # split string by any white space

make_birthday_song = function(){
  # Source: http://stackoverflow.com/questions/31782580/how-can-i-play-birthday-music-using-r
  # Taken from https://gist.github.com/emhart/89fd49401bc9795d790ef47ca638726f
  notes <- c(A = 0, B = 2, C = 3, D = 5, E = 7, F = 8, G = 10)
  pitch <- "D D E D G F# D D E D A G D D D5 B G F# E C5 C5 B G A G"
  duration <- c(rep(c(0.75, 0.25, 1, 1, 1, 2), 2),
                0.75, 0.25, 1, 1, 1, 1, 1, 0.75, 0.25, 1, 1, 1, 2)
  bday <- tibble(pitch = towords(pitch), duration = duration)
  bday <- bday %>%
          mutate(octave = substring(pitch, nchar(pitch)) %>% {suppressWarnings(as.numeric(.))} %>% ifelse(is.na(.), 4, .),
                 note = notes[substr(pitch, 1, 1)],
                 note = note + grepl("#", pitch) - grepl("b", pitch) + octave * 12 + 12 * (note < 3),
                 freq = 2 ^ ((note - 60) / 12) * 440
          )
  tempo <- 120
  sample_rate <- 44100
  
  make_sine <- function(freq, duration) {
    wave <- sin(seq(0, duration / tempo * 60, 1 / sample_rate) * freq * 2 * pi)
    fade <- seq(0, 1, 50 / sample_rate)
    wave * c(fade, rep(1, length(wave) - 2 * length(fade)), rev(fade))
  }
  
  bday_wave <- mapply(make_sine, bday$freq, bday$duration) %>%
    do.call("c", .)
  return(bday_wave)
}

play_birthday_song = function(bday=make_birthday_song()){
  require(audio)
  audio::play(bday)
}

save_birthday_song = function(bday=make_birthday_song(),name="birthday_song.wav"){
  require(audio)
  if( !file.exists(name) ){ audio::save.wave(bday,name) }
  return(name)
}

get_birthday_song = function(songfile=save_birthday_song()){
  require(base64enc)
  b64 <- dataURI(file = songfile, mime = "audio/wav")
  return(b64)
}

get_audio_tag <- function(filename,auto=NULL,ctl=NULL,rep=NULL, setvol="setHalfVolume()") {
  require(htmltools)
  au = htmltools::tags$audio(src = filename, type = "audio/wave",  controls = ctl, autoplay=ctl, )
  if(!is.null(rep)){ au = htmltools::tagAppendAttributes(au,loop=rep) }
  if(!is.null(setvol)){  au = htmltools::tagAppendAttributes(au,onloadeddata=setvol) }
  return(au)
}

get_audio_birthday = function(){
  get_audio_tag(filename=get_birthday_song(),rep=T,ctl=T,auto=T,setvol="setMaxVolume()")
}

get_audio_tag_bday <- function() {
  htmltools::tags$audio(src = get_birthday_song(),
             type = "audio/wave",
             controls = "controls",autoplay=TRUE)
}    

