library(shiny)
library(Biostrings)
library(seqinr)


# Define UI
ui <- fluidPage(
  titlePanel("Sequence Converter"),
  sidebarLayout(
    sidebarPanel(
      fileInput("fasta_file", "Upload FASTA file"),
      actionButton("convert_button", "Convert"),
      downloadButton("complement_download", "Download Complement Sequence"),
      downloadButton("reverse_complement_download", "Download Reverse Complement Sequence")
    ),
    mainPanel(
      textOutput("status_message")
    )
  )
)

# Define server
server <- function(input, output) {
  observeEvent(input$convert_button, {
    req(input$fasta_file)
    
    # Read the FASTA file
    fasta_data <- readAAStringSet(input$fasta_file$datapath)
    
    # Extract the sequence
    sequence <- as.character(fasta_data[[1]])
    
    # Create a DNAString object
    dna_sequence <- DNAString(sequence)
    
    # Calculate the complement and reverse complement sequences
    complement <- complement(dna_sequence)
    reverse_complement <- reverse(complement)
    
    # Convert the sequences to character strings
    complement_sequence <- as.character(complement)
    reverse_complement_sequence <- as.character(reverse_complement)
    
    # Save the complement and reverse complement sequences as separate FASTA files
    write.fasta(sequences = complement_sequence, names = "Complement Sequence", file.out = "complement_sequence.fasta")
    write.fasta(sequences = reverse_complement_sequence, names = "Reverse Complement Sequence", file.out = "reverse_complement_sequence.fasta")
    
    # Display status message
    output$status_message <- renderText("Conversion completed. Complement and Reverse Complement sequences are ready for download.")
  })
  
  output$complement_download <- downloadHandler(
    filename = "complement_sequence.fasta",
    content = function(file) {
      file.copy("complement_sequence.fasta", file)
    }
  )
  
  output$reverse_complement_download <- downloadHandler(
    filename = "reverse_complement_sequence.fasta",
    content = function(file) {
      file.copy("reverse_complement_sequence.fasta", file)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
