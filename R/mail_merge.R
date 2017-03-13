library(dplyr)
library(knitr)
# devtools::install_github("rpremraj/mailR") # wymaga instalacji java jdk 32bit
library(mailR)
library(readr)
library(rmarkdown)
library(tidyr)

# Mail vars
emailFrom <- ""
subject <- "Potwierdzenie rejestracji na konferencję"
smtp <- list(host.name = "",
             port = 465,
             user.name = "",
             passwd = "",
             ssl = TRUE)

# Frame vars
currSheet <- read_csv("link_to_whole_spreadsheet")
prevSheet <- read_csv("data/prevSheet.csv",
                      col_types = "ccccccccccccccccnnccccc")
diffSheet <- setdiff(currSheet, prevSheet) %>%
  rename(`Stopień naukowy` = `Stopień naukowy do umieszczenia na certyfikacie uczestnictwa w konferencji (o ile dotyczy)`,
         `Udział w konferencji` = `Czy chcesz uczestniczyć w konferencji?`,
         `Rezygnacja z opłaty cateringowej` = `Zaznacz poniżej jeżeli chcesz zrezygnować z opłaty cateringowej (10 zł)`,
         `Warsztaty poranny` = `W którym warsztacie porannym chciałabyś/chciałbyś uczestniczyć 27.09?`,
         `Warsztat popołudniowy` = `W którym warsztacie popołudniowym chciałabyś/chciałbyś uczestniczyć 27.09?`,
         `Data urodzin` = `Proszę podaj swoją datę urodzin`) %>%
  select(Imię, Nazwisko, `Afiliacja / Firma`, `Stopień naukowy`, Email,
         `Udział w konferencji`, `Rezygnacja z cateringu`, `Warsztaty poranny`,
         `Warsztat popołudniowy`, `Obecne stanowisko`, `Data urodzin`, Płeć,
         Kraj, Miasto) %>%
  mutate(`Rezygnacja z opłaty cateringowej` = if_else(
    is.na(`Rezygnacja z cateringu`),
    true = "Nie",
    false = "Tak")
  )

for (i in 1:nrow(diffSheet)) {
  rmarkdown::render(input = "docs/mail_content.Rmd",
                    output_format = "html_document",
                    output_dir = "docs/",
                    params = list(form = diffSheet[i, ] %>% select(-Email)),
                    encoding = "utf-8")
  
  email <- mailR::send.mail(from = emailFrom,
                            to = diffSheet[i, ]$Email,
                            subject = subject,
                            body = "docs/mail_content.html",
                            encoding = "utf-8",
                            html = TRUE,
                            smtp = smtp,
                            authenticate = TRUE,
                            send = FALSE)
  
  email$send()
}

write_csv(currSheet, "data/prevSheet.csv")