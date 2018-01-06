#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

suppressWarnings(library(tm))
suppressWarnings(library(stringr))
suppressWarnings(library(shiny))

# Load the n-gram data

bigram <- readRDS("bigram.RData");
trigram <-readRDS("trigram.RData");
quadgram <- readRDS("quadgram.RData");
helpermsg <<- ""

# Cleaning of user input before predicting the next word

Predict <- function(x) {
        xclean <- removeNumbers(removePunctuation(tolower(x)))
        xs <- strsplit(xclean, " ")[[1]]
        
# Backoff looping through the 4,3,&2 n-grams. Default is "the"
        
        if (length(xs)>= 3) {
                xs <- tail(xs,3)
                if (identical(character(0),head(quadgram[quadgram$unigram == xs[1] & quadgram$bigram == xs[2] & quadgram$trigram == xs[3], 4],1))){
                        Predict(paste(xs[2],xs[3],sep=" "))
                }
                else {helpermsg <<- "A Quadgram was used."; head(quadgram[quadgram$unigram == xs[1] & quadgram$bigram == xs[2] & quadgram$trigram == xs[3], 4],1)}
        }
        else if (length(xs) == 2){
                xs <- tail(xs,2)
                if (identical(character(0),head(trigram[trigram$unigram == xs[1] & trigram$bigram == xs[2], 3],1))) {
                        Predict(xs[2])
                }
                else {helpermsg<<- "A Trigram was used."; head(trigram[trigram$unigram == xs[1] & trigram$bigram == xs[2], 3],1)}
        }
        else if (length(xs) == 1){
                xs <- tail(xs,1)
                if (identical(character(0),head(bigram[bigram$unigram == xs[1], 2],1))) {helpermsg<<-"Unable to find a pattern :-("; head("?",1)}
                else {helpermsg <<- "A Bigramwas used."; head(bigram[bigram$unigram == xs[1],2],1)}
        }
}


shinyServer(function(input, output) {
        output$prediction <- renderPrint({
                result <- Predict(input$inputString)
                output$text <- renderText({helpermsg})
                result
        });
        

}
)
