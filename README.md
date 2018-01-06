# DataScienceCapstone
Coursera Data Science Specialization Capstone Repo
## The Application

This application is intended to predict the next word as the user types a sentence.There is a simple back-off algorithm using n-gram tokens starting with a 4-gram, then 3, and finally 2-gram model to loop through a sample data set built modeled extracts from internet news, blogs, and twitter feeds in an attempt to determine what you will want to type next.

### Steps
1. Type your word or phrase into the textbox on the left-hand side. **"NULL"** shown until something is entered.
2. Please ensure english words only. The application cannot supprot other languages at this time


### Results
1. Next word predicted will be displayed in the box to the right.
2. Information on the n-gram backoff algorithm used to predict is shown as indication.
3. A "?" will be displayed if the application is unable to determine the next word and the information will let you know this

### The Application
The application can be found on [Shiny] (https://yadushj.shinyapps.io/shinyPredictor)
