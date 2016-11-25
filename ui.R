###
shinyUI(fluidPage(
  titlePanel(""),
  
  fluidRow(column(6, align="center", offset = 3,
                  uiOutput("ui1"))),
  
  fluidRow(column(6, align="center", offset = 3,
                  uiOutput("ui2"))),
  
  fluidRow(column(6, align="center", offset = 3,div(style="height:40px"),
                  uiOutput("ui3"))),
  
  fluidRow(column(6, align="center", offset = 3,div(style="height:30px"),
                  uiOutput("ui4")))
))