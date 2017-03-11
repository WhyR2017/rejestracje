library(dplyr)
library(knitr)
# devtools::install_github("rpremraj/mailR") # wymaga instalacji java jdk 32bit
library(mailR)
library(pander)
library(readr)
library(rmarkdown)

# Mail vars
email_from <- ""
subject <- "Potwierdzenie rejestracji na konferencję"
login_email <- "xxx@gmail.com"
login_pass  <- "xxx"

# Frame vars
currSheet <- read_csv("link_to_spreadsheet")
# Classes of attributes
# sapply(currSheet, class) %>% unname() %>% strtrim(1) %>% paste0(collapse = "")
prevSheet <- read_csv("data/prevSheet.csv",
                      col_types = "ccccccccccccccccnnccccc")
diffSheet <- setdiff(currSheet, prevSheet) %>%
  rename(`Stopień naukowy` = `Stopień naukowy do umieszczenia na certyfikacie uczestnictwa w konferencji (o ile dotyczy)`,
         `Udział w konferencji` = `Czy chcesz uczestniczyć w konferencji?`,
         `Rezygnacja z cateringu` = `Zaznacz poniżej jeżeli chcesz zrezygnować z opłaty cateringowej (10 zł)`,
         `Warsztaty poranny` = `W którym warsztacie porannym chciałabyś/chciałbyś uczestniczyć 27.09?`,
         `Warsztat popołudniowy` = `W którym warsztacie popołudniowym chciałabyś/chciałbyś uczestniczyć 27.09?`,
         `Data urodzin` = `Proszę podaj swoją datę urodzin`) %>%
  select(Imię, Nazwisko, `Afiliacja / Firma`, `Stopień naukowy`, Email,
         `Udział w konferencji`, `Rezygnacja z cateringu`, `Warsztaty poranny`,
         `Warsztat popołudniowy`, `Obecne stanowisko`, `Data urodzin`, Płeć,
         Kraj, Miasto) %>%
  mutate(`Rezygnacja z cateringu` = if_else(is.na(`Rezygnacja z cateringu`),
                                            true = "Nie",
                                            false = "Tak"))

bodyList <- apply(diffSheet, 1, function(row) {
  data_frame(Formularz = names(row), Dane = unname(row))
})

mailNumber <- which(bodyList[[1]]$Formularz == "Email")

for (i in 1:length(bodyList)){
  rmarkdown::render(input = "docs/mail_content.Rmd",
                    output_format = "html_document",
                    output_dir = "docs/",
                    params = list(form = bodyList[[i]][-mailNumber, ]),
                    encoding = "utf-8")
  
  email <- mailR::send.mail(from = email_from,
                            to = bodyList[[i]]$Dane[mailNumber],
                            subject = subject,
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
  
  email$send()
}

write_csv(currSheet, "data/prevSheet.csv")