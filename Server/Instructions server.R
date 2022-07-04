# Instructions server

url <- a("Instructions website for NofapApp", href='https://wonderful-albattani-0cbd0e.netlify.app/instructions.html')

output$instructSite <- renderUI({
  tagList('URL link:', url)
})
