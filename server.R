### load libraries
library(shiny)
library(googlesheets)
suppressPackageStartupMessages(library(dplyr))

### functions
choices <- list("Aperitiv","Vorspeise","Hauptgang","Nachspeise","Digestiv")

GetTableMetadata <- function() {
  fields <- c(Name = "Name", Vorschlag = "Menuevorschlag", Gang = "Gang")
  result <- list(fields = fields)
  return (result)
}

CastData <- function(data) {
  datar <- data.frame(Name = data["Name"], 
                      Vorschlag = data["Vorschlag"], 
                      Gang = data["Gang"],
                      stringsAsFactors = FALSE)
  return (datar)
}
### remote data

#authentification
#token <- gs_auth()
#setwd('D:/Eigene Dokumente/webapps/dynamic ui_rshiny')
#saveRDS(token, "token.rds")
gs_auth(token = "token.rds")
key <- extract_key_from_url('https://docs.google.com/spreadsheets/d/1IQfMOiP6pvB6rcsb_C3RDDqTuOWHwmMoq7RM-GEl3oQ/edit#gid=0')
remoteData <- key %>% gs_key()

###
shinyServer(function(input, output) {
  
  rv <- reactiveValues(theswitch=0)
  
  observeEvent(input$but1,{
    #uppon click of action button "but1" do the following:
    #...write inputvalues into a data frame
      datlist <- sapply(names(GetTableMetadata()$fields), function(x){input[[x]]})
      dfinput <- CastData(datlist)
    #...load the new row in the data frame to a google spreadsheet
      remoteData %>% gs_add_row(ws = "Sheet1", input = dfinput[1,])  
    #...read the updated google spreadsheet to a dataframe, which will be outputted
      output$tab1 <- renderTable({remoteData %>% gs_read()})
    #...set the "switch" to one (to alter the ui after clicking "but1")
      rv$theswitch <- 1
  })
  

  observeEvent(input$but2, {
    #uppon click of action button "but2" do the following:
    #...set the "switch" back to zero (to get back to the landing page)
    rv$theswitch <- 0
  })
  
  observe({
    
    if(rv$theswitch <= 0){ #...then show the landing page of the app (data entry)
      
      output$ui1 <- renderUI({
        tagList(
          h3(textOutput('welcome')),
          textInput("Name", "Dein Vorname:", ""),
          textInput("Vorschlag", "Dein Vorschlag;", ""),
          selectInput("Gang", "Was für ein Gang ist das? ", choices = choices),
          actionButton("but1", "Schick´s dem Luz")
        )
      })
      output$ui2 <- renderUI({})
      output$ui3 <- renderUI({})
      output$ui4 <- renderUI({})
      
    }else if(rv$theswitch > 0 ){ #...then show the content of the remote google spreadsheet

      output$ui1 <- renderUI({})
      output$ui2 <- renderUI({
        tagList(
          h3(textOutput('thanks')),
          textOutput('close'),
          actionButton("but2", "...hast du noch einen anderen Wunsch?")
        )
      })      
      output$ui3 <- renderUI({
        tagList(
          textOutput('others')
        )
      })
      output$ui4 <- renderUI({
        tagList(
          tableOutput('tab1')
        )
      })
    }
  })
  output$welcome <- renderText({'Was hättest du gerne am Weihnachtsessen auf dem Teller?'})
  output$thanks <- renderText({'Danke! Dafür erhältst du 12 Karmapunkte.'})
  output$others <- renderText({'Das haben sich die anderen gewünscht:'})
  output$close <- renderText({'Du kannst das Browserfenster jetzt schliessen...'})
})