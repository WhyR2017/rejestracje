library(knitr)
library(rmarkdown)
# devtools::install_github("rpremraj/mailR") # wymaga instalacji java jdk 32bit
library(mailR)

participants <- read.csv2(file = "data/participants.csv")

for (i in 1:nrow(participants)){
  rmarkdown::render(input = "docs/mail_content.Rmd",
                    output_format = "html_document",
                    output_dir = "docs/",
                    params = list(
                      p1 = participants$plec[i],
                      p2 = participants$imie_w[i],
                      p3 = participants$warsztat_nazwa[i]))
  
  email <- send.mail(from = uzupelnic,
                     to   = uzupelnic,
                     subject = "Potwierdzenie rejestracji na warsztaty",
                     body = "docs/mail_content.html",
                     html = TRUE,
                     encoding = "utf-8",
                     smtp = list(host.name = "smtp.gmail.com", 
                                 port = 465, 
                                 user.name = login_email, 
                                 passwd = login_pass, 
                                 ssl = TRUE),
                     authenticate = TRUE,
                     send = FALSE)
  
  # email$addBcc(c(""))
  # email$addReplyTo(c(""))
  email$send()
}