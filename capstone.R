# load librarys to explore, clean and plot the data
library(stringi)
library(tm)
library(stringr)
library(dplyr)
library(RWeka)
library(ggplot2)
library(R.utils)

# check and create unique directory to hosue data on user system
if (!file.exists("capstone")){
        dir.create("capstone")
}


sourceUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
sourcefile <- "./capstone/Coursera-Swiftkey.zip"

# for reproduceability check first if file was downloaded and if not set the source of the data
# and unzip the file
if (!file.exists(sourcefile)){
        download.file(sourceUrl, destfile = "./capstone/Coursera-Swiftkey.zip")
        unzip(sourcefile, exdir = "./capstone")
}

# read three data files into R and provide a brief summarazation of the text files
blogData    <- readLines("./capstone/final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul = TRUE)
twitterData <- readLines("./capstone/final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = TRUE)
con <- file("final/en_US/en_US.news.txt", open="rb")
newsData    <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
rm(con)


# summarize and then display basic information for the three fles we will be working with

# file size
mb <- 1024 ^2
blogData.size     <-file.info("./capstone/final/en_US/en_US.blogs.txt")$size / mb
twitterData.size  <-file.info("./capstone/final/en_US/en_US.twitter.txt")$size / mb
newsData.size     <-file.info("./capstone/final/en_US/en_US.news.txt")$size / mb

# number of words
blogData.words     <-stri_count_words(blogData)
twitterData.words  <-stri_count_words(twitterData)
newsData.words     <-stri_count_words(newsData)

# build a dataframe to display summarization
dfSummary <- data.frame(source = c("blogs", "twitter", "news"),
                        file.MB    = c(blogData.size, twitterData.size, newsData.size),
                        file.words = c(sum(blogData.words), sum(twitterData.words), sum(newsData.words)),
                        file.lines = c(length(blogData), length(twitterData), length(newsData)),
                        avg.words  = c(c(mean(blogData.words), mean(twitterData.words), mean(newsData.words))))
dfSummary

# create sample (old version method limited to computer small sample size)
#set.seed(456)
#sampleData<- c(sample(blogData, length(blogData) * 0.003),
#                 sample(twitterData, length(twitterData) * 0.001),
#                 sample(newsData, length(newsData) * 0.001))

# create sample
sampletext <- function(textbody, portion) {
        taking <- sample(1:length(textbody), length(textbody)*portion)
        Sampletext <- textbody[taking]
        Sampletext
}

# sampling text files 
set.seed(19530)
portion <- 25/50
SampleTwitter <- sampletext(twitterData, portion)
SampleBlog <- sampletext(blogData, portion)
SampleNews <- sampletext(newsData, portion)

# combine sampled texts into one variable
sampleData <- c(SampleBlog, SampleNews, SampleTwitter)

# transform data such as emojis
sampleData <- iconv(sampleData, "UTF-8", "ASCII")
sampleData[which(is.na(sampleData))] <-"NULLVALUES"

# write sampled texts into text files for further analysis
writeLines(sampleData, "./shinyPredictor/TMP/SampleAll.txt")


# build corpus
#sampleCorpus <- VCorpus(VectorSource(sampleData))
sampleCorpus <- VCorpus(DirSource( "./shinyPredictor/TMP", encoding = "UTF-8"))
toSpace <-content_transformer(function(x, pattern) gsub(pattern, " ", x))


# clean corpus
# clean the data by building a small sample corpus in memory and then removing special characters
# and web sites
sampleCorpus <- tm_map(sampleCorpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
sampleCorpus <- tm_map(sampleCorpus, toSpace, "@[^\\s]+")
sampleCorpus <- tm_map(sampleCorpus, toSpace, "NULLVALUES")
sampleCorpus <- tm_map(sampleCorpus, tolower)
sampleCorpus <- tm_map(sampleCorpus, removeWords, stopwords("en"))
sampleCorpus <- tm_map(sampleCorpus, removePunctuation)
sampleCorpus <- tm_map(sampleCorpus, removeNumbers)
sampleCorpus <- tm_map(sampleCorpus, stripWhitespace)
sampleCorpus <- tm_map(sampleCorpus, PlainTextDocument)

# build ngrams for exploring the data

uniToken <- function(x) {NGramTokenizer(x, Weka_control(min = 1, max = 1))}
unigram  <- DocumentTermMatrix(sampleCorpus, control = list(tokenize = uniToken))
unigram_freq <- sort(colSums(as.matrix(unigram)), decreasing = TRUE)
unigram_freq_df <- data.frame(word = names(unigram_freq), frequency = unigram_freq)


biToken <- function(x) {NGramTokenizer(x, Weka_control(min = 2, max = 2))}
bigram  <- DocumentTermMatrix(sampleCorpus, control = list(tokenize = biToken))
bigram_freq <- sort(colSums(as.matrix(bigram)), decreasing = TRUE)
bigram_freq_df <- data.frame(word = names(bigram_freq), frequency = bigram_freq)


triToken <- function(x) {NGramTokenizer(x, Weka_control(min = 3, max = 3))}
trigram  <- DocumentTermMatrix(sampleCorpus, control = list(tokenize = triToken))
trigram_freq <- sort(colSums(as.matrix(trigram)), decreasing = TRUE)
trigram_freq_df <- data.frame(word = names(trigram_freq), frequency = trigram_freq)

quadToken <- function(x) {NGramTokenizer(x, Weka_control(min = 4, max = 4))}
quadgram  <- DocumentTermMatrix(sampleCorpus, control = list(tokenize = quadToken))
quadgram_freq <- sort(colSums(as.matrix(quadgram)), decreasing = TRUE)
quadgram_freq_df <- data.frame(word = names(quadgram_freq), frequency = quadgram_freq)

# plot
par(mfrow = c(3,1), mar = c(4,4,2,1))
unigram_freq_df %>% 
        filter(frequency > 200) %>%
        ggplot(aes(reorder(word,-frequency), frequency)) +
        geom_bar(stat = "identity") +
        ggtitle("Top Unigrams") +
        xlab("Unigrams") + ylab("Frequency")

bigram_freq_df %>% 
        filter(frequency > 15) %>%
        ggplot(aes(reorder(word,-frequency), frequency)) +
        geom_bar(stat = "identity") +
        ggtitle("Top biigrams") +
        xlab("biigrams") + ylab("Frequency")

trigram_freq_df %>% 
        filter(frequency > 3) %>%
        ggplot(aes(reorder(word,-frequency), frequency)) +
        theme(axis.text.x = element_text(angle = 60, size = 12, hjust = 1)) +
        geom_bar(stat = "identity") +
        ggtitle("Top trigrams") +
        xlab("trigrams") + ylab("Frequency")

quadgram_freq_df %>% 
        filter(frequency > 4) %>%
        ggplot(aes(reorder(word,-frequency), frequency)) +
        theme(axis.text.x = element_text(angle = 60, size = 12, hjust = 1)) +
        geom_bar(stat = "identity") +
        ggtitle("Top quadgrams") +
        xlab("quadgrams") + ylab("Frequency")



# save the frequency tables
saveRDS(unigram_freq_df, file = './shinyPredictor/unigram.rds')
saveRDS(bigram_freq_df, file = './shinyPredictor/bigram.rds')
saveRDS(trigram_freq_df, file = './shinyPredictor/trigram.rds')
saveRDS(quadgram_freq_df, file = './shinyPredictor/quadgram.rds.')

## save the n-grams into data tabes
bigram <- data.frame(rows=rownames(bigram_freq_df),count=bigram_freq_df$frequency)
bigram$rows <- as.character(bigram$rows)
bigram_split <- strsplit(as.character(bigram$rows),split=" ")
bigram <- transform(bigram,first = sapply(bigram_split,"[[",1),second = sapply(bigram_split,"[[",2))
bigram <- data.frame(unigram = bigram$first,bigram = bigram$second,freq = bigram$count,stringsAsFactors=FALSE)
write.csv(bigram[bigram$freq > 1,],"./shinyPredictor/bigram.csv",row.names=F)
bigram <- read.csv("./shinypredictor/bigram.csv",stringsAsFactors = F)
saveRDS(bigram,"./shinyPredictor/bigram.RData")

trigram <- data.frame(rows=rownames(trigram_freq_df),count=trigram_freq_df$frequency)
trigram$rows <- as.character(trigram$rows)
trigram_split <- strsplit(as.character(trigram$rows),split=" ")
trigram <- transform(trigram,first = sapply(trigram_split,"[[",1),second = sapply(trigram_split,"[[",2),third = sapply(trigram_split,"[[",3))
trigram <- data.frame(unigram = trigram$first,bigram = trigram$second, trigram = trigram$third, freq = trigram$count,stringsAsFactors=FALSE)
write.csv(trigram[trigram$freq > 1,],"./shinyPredictor//trigram.csv",row.names=F)
trigram <- read.csv("./shinyPredictor/trigram.csv",stringsAsFactors = F)
saveRDS(trigram,"./shinyPredictor/trigram.RData")

quadgram <- data.frame(rows=rownames(quadgram_freq_df),count=quadgram_freq_df$frequency)
quadgram$rows <- as.character(quadgram$rows)
quadgram_split <- strsplit(as.character(quadgram$rows),split=" ")
quadgram <- transform(quadgram,first = sapply(quadgram_split,"[[",1),second = sapply(quadgram_split,"[[",2),third = sapply(quadgram_split,"[[",3), fourth = sapply(quadgram_split,"[[",4))
quadgram <- data.frame(unigram = quadgram$first,bigram = quadgram$second, trigram = quadgram$third, quadgram = quadgram$fourth, freq = quadgram$count,stringsAsFactors=FALSE)
write.csv(quadgram[quadgram$freq > 1,],"./shinyPredictor/quadgram.csv",row.names=F)
quadgram <- read.csv("./shinyPredictor/quadgram.csv",stringsAsFactors = F)
saveRDS(quadgram,"./ShinyPredictor/quadgram.RData")
