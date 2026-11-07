# ============================================================
# LEZIONE 11
# DATI, INDICATORI E ANALISI EMPIRICA IN R
#
# Corso:
# Politiche Pubbliche per l'Innovazione e le Imprese
#
# Script didattico per studenti principianti
# ============================================================


# ============================================================
# COME LEGGERE QUESTO SCRIPT
# ============================================================

# In R, tutto ciò che viene dopo il simbolo # è un commento.
#
# I commenti NON vengono eseguiti da R.
#
# Servono per spiegare:
#
# - che cosa stiamo facendo;
# - perché lo stiamo facendo;
# - come interpretare i risultati.
#
# Per eseguire una riga in RStudio:
#
# Windows:
# CTRL + ENTER
#
# Mac:
# CMD + ENTER
#
# È consigliabile eseguire il codice poco alla volta,
# controllando ogni volta cosa succede.


# ============================================================
# 1. INSTALLARE I PACCHETTI
# ============================================================

# R contiene già molte funzioni di base.
#
# Tuttavia, per lavorare più comodamente con dati,
# grafici e regressioni utilizzeremo alcuni pacchetti.
#
# Un pacchetto è un insieme di funzioni aggiuntive.
#
# install.packages() serve per INSTALLARE un pacchetto.
#
# L'installazione va fatta soltanto la prima volta.
#
# Per questo motivo le righe seguenti sono precedute da #.
#
# Se non avete ancora installato i pacchetti,
# togliete il simbolo # ed eseguite le righe.

# install.packages("tidyverse")
# install.packages("fixest")
# install.packages("modelsummary")
# install.packages("sf")


# ============================================================
# 2. CARICARE I PACCHETTI
# ============================================================

# Dopo aver installato un pacchetto,
# dobbiamo caricarlo nella sessione di R.
#
# library() serve proprio a questo.
#
# Questa operazione va ripetuta ogni volta
# che riapriamo R.

library(tidyverse)

# tidyverse contiene diversi pacchetti utili:
#
# dplyr   -> manipolazione dei dati
# tidyr   -> trasformazione dei dati
# ggplot2 -> grafici
# readr   -> importazione di file CSV
# stringr -> gestione di stringhe di testo


library(fixest)

# fixest viene utilizzato per:
#
# - regressioni lineari;
# - effetti fissi;
# - difference-in-differences;
# - errori standard clusterizzati;
# - event study.


# ============================================================
# 3. PRIMO PRINCIPIO: UN DATASET È UNA TABELLA
# ============================================================

# Un dataset può essere immaginato come una normale tabella.
#
# Le RIGHE rappresentano le osservazioni.
#
# Le COLONNE rappresentano le variabili.
#
# Nel nostro esempio:
#
# osservazione = impresa in un determinato anno
#
# variabili =
# - identificativo dell'impresa;
# - anno;
# - settore;
# - regione;
# - numero di dipendenti;
# - vendite;
# - investimenti;
# - trattamento.


# ============================================================
# 4. CREIAMO UN DATASET DIDATTICO
# ============================================================

# In questa lezione non vogliamo dipendere
# dalla disponibilità di un file esterno.
#
# Creiamo quindi artificialmente un dataset.
#
# Questo ci permette di eseguire tutto lo script
# dall'inizio alla fine.
#
# Immaginiamo:
#
# 200 imprese
#
# osservate dal:
#
# 2020 al 2025.


# set.seed() rende casualità riproducibile.
#
# Significa che tutti gli studenti che eseguono
# questo codice otterranno gli stessi numeri casuali.

set.seed(123)


# Numero di imprese.

n_firms <- 200


# Anni osservati.

years <- 2020:2025


# ============================================================
# 5. CREARE UNA STRUTTURA PANEL
# ============================================================

# Vogliamo osservare la stessa impresa
# in più anni.
#
# Questo tipo di dati prende il nome di:
#
# PANEL DATA
#
# Ogni impresa compare quindi più volte.
#
# expand_grid() crea tutte le possibili combinazioni
# tra:
#
# impresa
#
# e
#
# anno.

df <- expand_grid(
  id = 1:n_firms,
  year = years
  
)


# Visualizziamo le prime righe.

head(df)


# Dovremmo osservare qualcosa del tipo:
#
# id   year
# 1    2020
# 1    2021
# 1    2022
# ...
# 2    2020
# 2    2021
# ...


# ============================================================
# 6. CONTROLLARE LE DIMENSIONI DEL DATASET
# ============================================================

# dim() restituisce:
#
# numero di righe
#
# numero di colonne

dim(df)


# Abbiamo:
#
# 200 imprese
#
# x
#
# 6 anni
#
# =
#
# 1200 osservazioni.


# ============================================================
# 7. CREIAMO CARATTERISTICHE FISSE DELLE IMPRESE
# ============================================================

# Supponiamo che ogni impresa appartenga:
#
# - a un settore;
# - a una regione;
# - a una dimensione iniziale.
#
# Queste caratteristiche vengono create
# una sola volta per impresa.


firm_characteristics <- tibble(
  
  id = 1:n_firms,
  
  
  # sample() estrae casualmente un valore.
  #
  # Ogni impresa viene assegnata a uno dei tre settori.
  
  sector = sample(
    
    c(
      "Manufacturing",
      "Services",
      "ICT"
    ),
    
    n_firms,
    
    replace = TRUE
    
  ),
  
  
  # Assegniamo anche una macro-area geografica.
  
  region = sample(
    
    c(
      "North",
      "Centre",
      "South"
    ),
    
    n_firms,
    
    replace = TRUE
    
  ),
  
  
  # Creiamo il numero iniziale di dipendenti.
  #
  # Utilizziamo una distribuzione lognormale
  # perché la distribuzione della dimensione
  # delle imprese è spesso asimmetrica:
  #
  # molte imprese piccole
  # e poche imprese grandi.
  
  employees_2020 = round(
    
    exp(
      
      rnorm(
        
        n_firms,
        
        mean = log(25),
        
        sd = 0.7
        
      )
      
    )
    
  )
  
)


# Guardiamo le prime righe.

head(firm_characteristics)


# ============================================================
# 8. JOIN: UNIRE DUE DATASET
# ============================================================

# Attualmente abbiamo:
#
# df
#
# con id e anno
#
# e
#
# firm_characteristics
#
# con settore, regione e dipendenti iniziali.
#
# Vogliamo unire i due dataset.
#
# Utilizziamo:
#
# left_join()
#
# La variabile comune è:
#
# id


df <- df |>
  
  left_join(
    
    firm_characteristics,
    
    by = "id"
    
  )


# Controlliamo il risultato.

head(df)


# ============================================================
# 9. CHE COS'È L'OPERATORE |>
# ============================================================

# Nel codice precedente abbiamo utilizzato:
#
# |>
#
# Questo simbolo si chiama PIPE.
#
# Può essere letto come:
#
# "prendi ciò che c'è a sinistra
# e passalo alla funzione successiva".
#
# Ad esempio:
#
# df |>
#   head()
#
# significa:
#
# prendi df
# e applica head().


df |>
  head()


# ============================================================
# 10. CREARE UNA VARIABILE DUMMY
# ============================================================

# Una variabile dummy è una variabile binaria.
#
# Può assumere soltanto due valori:
#
# 0 = caratteristica assente
#
# 1 = caratteristica presente
#
# Creiamo una dummy chiamata:
#
# large_firm
#
# che vale:
#
# 1 se l'impresa aveva almeno 50 dipendenti nel 2020
#
# 0 altrimenti.


df <- df |>
  
  mutate(
    
    large_firm = if_else(
      
      employees_2020 >= 50,
      
      1,
      
      0
      
    )
    
  )


# mutate() serve a creare
# o modificare variabili.
#
# if_else() funziona così:
#
# if_else(
#
#   condizione,
#
#   valore se la condizione è vera,
#
#   valore se la condizione è falsa
#
# )


# Controlliamo la variabile.

table(df$large_firm)


# table() conta quante osservazioni
# hanno ciascun valore.


# ============================================================
# 11. DUMMY DA UNA VARIABILE CATEGORICA
# ============================================================

# Creiamo una dummy:
#
# ict
#
# che vale:
#
# 1 se l'impresa opera nel settore ICT
#
# 0 negli altri casi.


df <- df |>
  
  mutate(
    
    ict = if_else(
      
      sector == "ICT",
      
      1,
      
      0
      
    )
    
  )


table(df$ict)


# ============================================================
# 12. CREARE IL GRUPPO TRATTATO
# ============================================================

# Supponiamo ora di voler valutare
# una politica pubblica.
#
# Una parte delle imprese riceve la politica.
#
# Queste imprese vengono chiamate:
#
# TRATTATE.
#
# Le altre imprese costituiscono:
#
# GRUPPO DI CONTROLLO.
#
# Supponiamo che circa il 40% delle imprese
# riceva il trattamento.


treated_ids <- sample(
  
  1:n_firms,
  
  size = round(
    n_firms * 0.40
  )
  
)


# treated_ids contiene gli ID
# delle imprese che ricevono la policy.


treated_ids<-sort(treated_ids)


# Creiamo ora una dummy:
#
# treated = 1 -> impresa trattata
#
# treated = 0 -> impresa di controllo


df <- df |>
  
  mutate(
    
    treated = if_else(
      
      id %in% treated_ids,
      
      1,
      
      0
      
    )
    
  )


table(df$treated)


# ============================================================
# 13. CREARE LA VARIABILE POST
# ============================================================

# Supponiamo che la politica inizi nel 2023.
#
# Vogliamo distinguere:
#
# periodo PRE-policy
#
# e
#
# periodo POST-policy.
#
# Creiamo quindi:
#
# post = 0 prima del 2023
#
# post = 1 dal 2023 in poi.


df <- df |>
  
  mutate(
    
    post = if_else(
      
      year >= 2023,
      
      1,
      
      0
      
    )
    
  )


# Controlliamo.

table(
  df$year,
  df$post
)


# ============================================================
# 14. CREARE L'INTERAZIONE DID
# ============================================================

# Nella Difference-in-Differences
# la variabile fondamentale è l'interazione:
#
# treated * post
#
# Essa vale 1 soltanto quando:
#
# treated = 1
#
# E
#
# post = 1.
#
# Quindi identifica:
#
# le imprese trattate
# dopo l'introduzione della politica.


df <- df |>
  
  mutate(
    
    did = treated * post
    
  )


# Controlliamo tutte le combinazioni.

table(
  df$treated,
  df$post
)


# Possiamo anche controllare did.

table(df$did)


# ============================================================
# 15. CREARE VARIABILI ECONOMICHE
# ============================================================

# Creiamo ora alcune variabili economiche artificiali.
#
# L'obiettivo NON è simulare perfettamente la realtà.
#
# Serve semplicemente ad avere dati plausibili
# su cui esercitarci.
#
# Creiamo:
#
# employees
# investment
# sales
# productivity


df <- df |>
  
  mutate(
    
    
    # --------------------------------------------------------
    # DIPENDENTI
    # --------------------------------------------------------
    
    # Il numero di dipendenti evolve nel tempo.
    #
    # Inseriamo:
    #
    # - una crescita media annuale;
    # - una componente casuale.
    
    employees =
      
      employees_2020 *
      
      exp(
        
        0.025 * (year - 2020) +
          
          rnorm(
            n(),
            0,
            0.08
          )
        
      ),
    
    
    # --------------------------------------------------------
    # INVESTIMENTI
    # --------------------------------------------------------
    
    # Gli investimenti dipendono da:
    #
    # - dimensione;
    # - settore ICT;
    # - essere trattati;
    # - trattamento nel periodo post;
    # - una componente casuale.
    
    investment =
      
      100 +
      
      20 * large_firm +
      
      15 * ict +
      
      10 * treated +
      
      25 * did +
      
      rnorm(
        n(),
        0,
        25
      ),
    
    
    # --------------------------------------------------------
    # VENDITE
    # --------------------------------------------------------
    
    sales =
      
      employees * 80 +
      
      300 * ict +
      
      250 * did +
      
      rnorm(
        n(),
        0,
        400
      ),
    
    
    # --------------------------------------------------------
    # PRODUTTIVITÀ
    # --------------------------------------------------------
    
    productivity =
      
      sales / employees
    
  )


# Vediamo le prime righe.

head(df)


# ============================================================
# 16. ESPLORARE UN DATASET
# ============================================================

# Prima di fare qualunque analisi
# dobbiamo sempre capire come è fatto il dataset.
#
# Alcuni comandi fondamentali:


# Prime righe.

head(df)


# Ultime righe.

tail(df)


# Dimensioni.

dim(df)


# Numero di righe.

nrow(df)


# Numero di colonne.

ncol(df)


# Nomi delle variabili.

names(df)


# Struttura completa.

glimpse(df)
str(df)

# Statistiche riassuntive.

summary(df)


# ============================================================
# 17. SELECT: SCEGLIERE LE VARIABILI
# ============================================================

# select() serve a scegliere
# soltanto alcune colonne.
#
# Ad esempio, vogliamo lavorare solo con:
#
# id
# year
# treated
# sales
# investment


df_small <- df |>
  
  select(
    
    id,
    year,
    treated,
    sales,
    investment
    
  )


head(df_small)





# 1. Carica il pacchetto necessario
library(ggplot2)

# 2. Crea il grafico con ggplot e assegnalo alla variabile 'c'
# (Nota: assume che 'df' sia il tuo dataframe e 'investment' la colonna)
c <- ggplot(df, aes(x = seq_along(investment), y = investment)) +
  geom_line() + # Crea un grafico a linee (usa geom_point() se preferisci i punti)
  labs(x = "Indice", y = "Investimento") +
  theme_minimal()


c

# 3. Salva il grafico sul tuo computer
ggsave(
  filename = "mio_grafico.pdf", # Devi specificare il nome e l'estensione del file
  plot = c,
  dpi = 300,
  limitsize = TRUE,
  bg = "white" # Usare "white" evita che lo sfondo diventi trasparente o nero in alcuni visualizzatori
)





# ============================================================
# 18. FILTER: SCEGLIERE LE OSSERVAZIONI
# ============================================================

# filter() seleziona le righe
# che soddisfano una condizione.
#
# Ad esempio:
#
# prendiamo solo le imprese trattate.


treated_firms <- df |>
  
  filter(
    
    treated == 1
    
  )


head(treated_firms)


# ============================================================
# 19. FILTER PER ANNO
# ============================================================

# Prendiamo solo l'anno 2025.

df_2025 <- df |>
  
  filter(
    
    year == 2025
    
  )


head(df_2025)


# ============================================================
# 20. FILTER CON PIÙ CONDIZIONI
# ============================================================

# Vogliamo:
#
# imprese trattate
#
# localizzate nel Sud
#
# dopo il 2023.


df_example <- df |>
  
  filter(
    
    treated == 1,
    
    region == "South",
    
    year >= 2023
    
  )


head(df_example)


# Quando inseriamo più condizioni separate da virgola,
# tutte devono essere soddisfatte.


# ============================================================
# 21. ARRANGE: ORDINARE I DATI
# ============================================================

# arrange() ordina il dataset.
#
# Ordiniamo prima per impresa
# e poi per anno.


df |>
  
  arrange(
    
    id,
    region
    
  ) |>
  
  head(20)


# ============================================================
# 22. ORDINE DECRESCENTE
# ============================================================

# desc() significa descending:
#
# ordine decrescente.
#
# Troviamo quindi le imprese
# con le vendite più elevate.


df |>
  
  arrange(
    
    desc(sales)
    
  ) |>
  
  head(10)


# ============================================================
# 23. MUTATE: CREARE NUOVI INDICATORI
# ============================================================

# Possiamo costruire indicatori economici
# a partire dalle variabili disponibili.
#
# Ad esempio:
#
# vendite per dipendente
#
# investimenti per dipendente
#
# logaritmo delle vendite
#
# logaritmo dei dipendenti.


df <- df |>
  
  mutate(
    
    sales_per_employee =
      sales / employees,
    
    investment_per_employee =
      investment / employees,
    
    log_sales =
      log(sales),
    
    log_employees =
      log(employees)
    
  )


head(df)




# ============================================================
# 24. PERCHÉ USARE I LOGARITMI?
# ============================================================

# Nelle applicazioni economiche
# è molto comune usare logaritmi.
#
# Due ragioni:
#
# 1. molte variabili economiche
#    hanno distribuzioni molto asimmetriche;
#
# 2. i coefficienti possono spesso
#    essere interpretati in termini percentuali.
#
# ATTENZIONE:
#
# log() non può essere calcolato
# su valori uguali o inferiori a zero.


# ============================================================
# 25. CASE_WHEN: CREARE CATEGORIE
# ============================================================

# case_when() è utile quando abbiamo
# più di due categorie.
#
# Creiamo una variabile:
#
# size_class
#
# con quattro categorie.


df <- df |>
  
  mutate(
    
    size_class = case_when(
      
      employees < 10 ~
        "Micro",
      
      employees >= 10 &
        employees < 50 ~
        "Small",
      
      employees >= 50 &
        employees < 250 ~
        "Medium",
      
      employees >= 250 ~
        "Large"
      
    )
    
  )




# ============================================================
# 26. MISSING VALUES
# ============================================================

# Nei dataset reali alcuni valori
# sono spesso mancanti.
#
# In R un valore mancante
# viene indicato con:
#
# NA
#
# Introduciamo artificialmente
# alcuni missing nella variabile investment.


set.seed(321)


missing_rows <- sample(
  
  1:nrow(df),
  
  size = 40
  
)


df$investment[missing_rows] <- NA


# Quanti valori mancanti abbiamo?

sum(
  is.na(df$investment)
)


# ============================================================
# 27. ATTENZIONE AI MISSING NELLE MEDIE
# ============================================================

# Se proviamo a calcolare una media
# in presenza di NA:

mean(df$investment)


# R restituisce NA.
#
# Per dire a R di ignorare i valori mancanti
# utilizziamo:
#
# na.rm = TRUE


mean(
  
  df$investment,
  
  na.rm = TRUE
  
)




# ============================================================
# 28. ELIMINARE OSSERVAZIONI CON MISSING
# ============================================================

# Possiamo eliminare le osservazioni
# con investment mancante.


df_no_missing <- df |>
  
  filter(
    
    !is.na(investment)
    
  )


# Confrontiamo il numero di righe.

nrow(df)

nrow(df_no_missing)


# Un metodo alternativo è:

df_no_missing_2 <- df |>
  
  drop_na(investment)


# ============================================================
# 29. STATISTICHE DESCRITTIVE
# ============================================================

# Media.

mean(
  df$sales,
  na.rm = TRUE
)


# Mediana.

median(
  df$sales,
  na.rm = TRUE
)


# Deviazione standard.

sd(
  df$sales,
  na.rm = TRUE
)


# Minimo.

min(
  df$sales,
  na.rm = TRUE
)


# Massimo.

max(
  df$sales,
  na.rm = TRUE
)


# Quantili.

plot(
  df$sales,
  na.rm = TRUE
)


# ============================================================
# 30. GROUP_BY + SUMMARISE
# ============================================================

# Questa è una delle operazioni
# più importanti di dplyr.
#
# group_by() significa:
#
# "dividi il dataset in gruppi".
#
# summarise() significa:
#
# "calcola una statistica
# separatamente per ciascun gruppo".
#
# Calcoliamo la media delle vendite
# per ciascun anno.


sales_by_year <- df |>
  
  group_by(year) |>
  
  summarise(
    
    mean_sales = mean(
      
      sales,
      
      na.rm = TRUE
      
    ),
    
    n = n()
    
  )


sales_by_year


# ============================================================
# 31. CONFRONTARE TRATTATI E CONTROLLI
# ============================================================

# Vogliamo confrontare:
#
# treated = 1
#
# e
#
# treated = 0.


group_summary <- df |>
  
  group_by(treated) |>
  
  summarise(
    
    mean_sales = mean(
      sales,
      na.rm = TRUE
    ),
    
    mean_investment = mean(
      investment,
      na.rm = TRUE
    ),
    
    mean_employees = mean(
      employees,
      na.rm = TRUE
    ),
    
    n = n()
    
  )


group_summary


# ATTENZIONE:
#
# una differenza tra trattati e controlli
# NON è automaticamente un effetto causale.
#
# I due gruppi possono essere diversi
# anche prima della policy.


# ============================================================
# 32. MEDIE PER ANNO E TRATTAMENTO
# ============================================================

# Ora calcoliamo la media delle vendite
# separatamente:
#
# per anno
#
# e
#
# per status di trattamento.


trend_data <- df |>
  
  group_by(
    
    year,
    
    treated
    
  ) |>
  
  summarise(
    
    mean_sales = mean(
      
      sales,
      
      na.rm = TRUE
      
    ),
    
    .groups = "drop"
    
  )


trend_data


# ============================================================
# 33. PRIMO GRAFICO CON GGPLOT2
# ============================================================

# ggplot() è il principale strumento
# per creare grafici in R.
#
# La struttura generale è:
#
# ggplot(data, aes(...)) +
#
#   tipo_di_grafico +
#
#   altre_opzioni


ggplot(
  
  trend_data,
  
  aes(
    
    x = year,
    
    y = mean_sales,
    
    group = treated,
    
    color = factor(treated)
    
  )
  
) +
  
  geom_line(
    
    linewidth = 1
    
  ) +
  
  geom_point(
    
    size = 2
    
  ) +
  
  labs(
    
    x = "Year",
    
    y = "Average sales",
    
    color = "Treated",
    
    title =
      "Average sales: treated and control firms"
    
  ) +
  
  theme_minimal()


# ============================================================
# 34. COME LEGGERE IL GRAFICO
# ============================================================

# Asse X:
#
# anno
#
# Asse Y:
#
# vendite medie
#
# Le due linee rappresentano:
#
# imprese trattate
#
# e
#
# imprese di controllo.
#
# Questo tipo di grafico è particolarmente importante
# nella Difference-in-Differences.


# ============================================================
# 35. SCATTERPLOT
# ============================================================

# Uno scatterplot mostra la relazione
# tra due variabili quantitative.
#
# Qui osserviamo:
#
# employees
#
# e
#
# sales.


ggplot(
  
  df,
  
  aes(
    
    x = employees,
    
    y = sales
    
  )
  
) +
  
  geom_point(
    
    alpha = 0.3
    
  ) +
  
  labs(
    
    x = "Employees",
    
    y = "Sales",
    
    title =
      "Firm size and sales"
    
  ) +
  
  theme_minimal()


# ============================================================
# 36. RETTA DI REGRESSIONE NEL GRAFICO
# ============================================================

# geom_smooth(method = "lm")
#
# aggiunge una retta di regressione lineare.


ggplot(
  
  df,
  
  aes(
    
    x = employees,
    
    y = sales
    
  )
  
) +
  
  geom_point(
    
    alpha = 0.25
    
  ) +
  
  geom_smooth(
    
    method = "lm",
    
    se = FALSE
    
  ) +
  
  theme_minimal()


#prova di regressione
fit <- lm(sales ~ employees, data = df)
summary(fit)




# Installa il pacchetto se non lo hai già fatto: install.packages("AER")
library(AER)

# Formula: vendite spiegate da dipendenti, strumentata da produttività
fit <- ivreg(sales ~ employees | productivity, data = df)
summary(fit)



# ============================================================
# 37. BOXPLOT
# ============================================================

# Il boxplot consente di confrontare
# la distribuzione di una variabile
# tra gruppi diversi.
#
# Confrontiamo gli investimenti
# di trattati e controlli.


ggplot(
  
  df,
  
  aes(
    
    x = factor(treated),
    
    y = investment
    
  )
  
) +
  
  geom_boxplot() +
  
  labs(
    
    x = "Treatment status",
    
    y = "Investment",
    
    title =
      "Investment by treatment status"
    
  ) +
  
  theme_minimal()


# ============================================================
# 38. ISTOGRAMMA
# ============================================================

# L'istogramma mostra la distribuzione
# di una variabile quantitativa.


ggplot(
  
  df,
  
  aes(
    
    x = sales
    
  )
  
) +
  
  geom_histogram(
    
    bins = 30
    
  ) +
  
  labs(
    
    x = "Sales",
    
    y = "Frequency",
    
    title =
      "Distribution of sales"
    
  ) +
  
  theme_minimal()


# ============================================================
# 39. CORRELAZIONE
# ============================================================

# cor() misura la correlazione lineare
# tra due variabili.
#
# Il coefficiente varia tra:
#
# -1
#
# e
#
# +1.
#
# Vicino a +1:
# forte relazione positiva.
#
# Vicino a -1:
# forte relazione negativa.
#
# Vicino a 0:
# relazione lineare debole.


cor(
  
  df$sales,
  
  df$employees,
  
  use = "complete.obs"
  
)


# ATTENZIONE:
#
# correlazione
#
# NON significa
#
# causalità.


# ============================================================
# 40. REGRESSIONE LINEARE SEMPLICE
# ============================================================

# La regressione lineare studia
# la relazione tra:
#
# una variabile dipendente Y
#
# e
#
# una o più variabili esplicative X.
#
# Modello:
#
# sales_i =
#
# beta_0 +
#
# beta_1 employees_i +
#
# errore_i

library(plm)


df_panel<-pdata.frame(df, index =c("id","year"))

model_1 <- lm(
  
  sales ~ employees,
  
  data = df
  
)


# Visualizziamo i risultati.

summary(model_1)


# ============================================================
# 41. COME LEGGERE SUMMARY()
# ============================================================

# Nel risultato troviamo:
#
# Estimate
#
# = coefficiente stimato
#
# Std. Error
#
# = errore standard
#
# t value
#
# = statistica t
#
# Pr(>|t|)
#
# = p-value
#
# R-squared
#
# = quota di variabilità spiegata dal modello.


# ============================================================
# 42. INTERPRETAZIONE DEL COEFFICIENTE
# ============================================================

# Se il coefficiente di employees
# fosse ad esempio:
#
# 80
#
# l'interpretazione sarebbe:
#
# un dipendente aggiuntivo
#
# è associato in media
#
# a 80 unità aggiuntive di sales.
#
# ATTENZIONE:
#
# "associato"
#
# non significa automaticamente
#
# "causato".


# ============================================================
# 43. REGRESSIONE MULTIPLA
# ============================================================

# Inseriamo più variabili esplicative.
#
# Ora chiediamo:
#
# qual è la relazione tra employees e sales
#
# controllando anche per:
#
# investment
#
# ICT
#
# dimensione iniziale.


model_2 <- lm(
  
  sales ~
    
    employees +
    
    investment +
    
    ict +
    
    large_firm,
  
  data = df
  
)


summary(model_2)


# ============================================================
# 44. REGRESSIONE CON UNA DUMMY
# ============================================================

# Confrontiamo trattati e controlli.


model_3 <- lm(
  
  sales ~
    
    treated,
  
  data = df
  
)


summary(model_3)


# Il coefficiente di treated rappresenta:
#
# differenza media nelle vendite
#
# tra:
#
# trattati
#
# e
#
# controlli.
#
# Ma questo NON è necessariamente
# un effetto causale.


# ============================================================
# 45. DIFFERENCE-IN-DIFFERENCES:
# INTUIZIONE
# ============================================================

# La Difference-in-Differences confronta:
#
# 1. cambiamento dei trattati
#    prima e dopo la policy;
#
# 2. cambiamento dei controlli
#    nello stesso periodo.
#
# Poi sottrae le due variazioni.
#
# In formula:
#
# DID =
#
# (Treated_post - Treated_pre)
#
# -
#
# (Control_post - Control_pre)


# ============================================================
# 46. REGRESSIONE DID ELEMENTARE
# ============================================================

# Utilizziamo:
#
# treated
#
# post
#
# treated:post
#
# Il termine treated:post
# è l'interazione.
#
# Il coefficiente associato
# all'interazione è la stima DiD.


did_simple <- lm(
  
  sales ~
    
    treated +
    
    post +
    
    treated:post,
  
  data = df
  
)


summary(did_simple)


# ============================================================
# 47. SCRITTURA ABBREVIATA DELL'INTERAZIONE
# ============================================================

# In R:
#
# treated * post
#
# equivale a:
#
# treated
#
# +
#
# post
#
# +
#
# treated:post


did_simple_2 <- lm(
  
  sales ~
    
    treated * post,
  
  data = df
  
)


summary(did_simple_2)


# ============================================================
# 48. INTERPRETAZIONE DEI COEFFICIENTI DID
# ============================================================

# Nel modello:
#
# sales =
#
# beta0
#
# + beta1 treated
#
# + beta2 post
#
# + beta3 treated*post
#
# abbiamo:
#
# beta0
#
# media del gruppo di controllo
# nel periodo pre-policy.
#
# beta1
#
# differenza iniziale
# tra trattati e controlli.
#
# beta2
#
# variazione nel tempo
# del gruppo di controllo.
#
# beta3
#
# DIFFERENCE-IN-DIFFERENCES.
#
# beta3 è il coefficiente
# più importante per noi.


# ============================================================
# 49. DID CON FIXEST
# ============================================================

# Possiamo stimare lo stesso modello
# utilizzando feols().


did_fixest <- feols(
  
  sales ~
    
    treated * post,
  
  data = df
  
)


summary(did_fixest)


# ============================================================
# 50. EFFETTI FISSI
# ============================================================

# Nei dati panel possiamo controllare
# per caratteristiche non osservate
# che restano costanti nel tempo.
#
# Ad esempio:
#
# capacità manageriale;
#
# cultura dell'impresa;
#
# caratteristiche strutturali;
#
# posizione geografica stabile.
#
# Inseriamo quindi:
#
# effetti fissi di impresa
#
# e
#
# effetti fissi di anno.


did_fe <- feols(
  
  sales ~
    
    did |
    
    id + year,
  
  data = df
  
)


summary(did_fe)


# ============================================================
# 51. COME LEGGERE LA SINTASSI FIXEST
# ============================================================

# La sintassi è:
#
# outcome ~ regressori | effetti_fissi
#
# Nel nostro caso:
#
# sales ~ did | id + year
#
# significa:
#
# outcome:
#
# sales
#
# regressore di interesse:
#
# did
#
# effetti fissi:
#
# id
#
# e
#
# year.


# ============================================================
# 52. ERRORI STANDARD CLUSTERIZZATI
# ============================================================

# Nei dati panel osserviamo
# la stessa impresa più volte.
#
# Le osservazioni appartenenti alla stessa impresa
# possono quindi essere correlate nel tempo.
#
# Per questo motivo possiamo clusterizzare
# gli errori standard per impresa.


did_cluster <- feols(
  
  sales ~
    
    did |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(did_cluster)


# ============================================================
# 53. TEMPO RELATIVO ALLA POLICY
# ============================================================

# Per costruire un event study
# dobbiamo sapere quanto tempo manca
# o è trascorso dalla policy.
#
# Policy:
#
# 2023
#
# Definiamo:
#
# event_time = year - 2023


df <- df |>
  
  mutate(
    
    event_time =
      
      year - 2023
    
  )


table(df$event_time)


# Interpretazione:
#
# -3 = tre anni prima
#
# -2 = due anni prima
#
# -1 = un anno prima
#
#  0 = anno della policy
#
# +1 = un anno dopo
#
# +2 = due anni dopo


# ============================================================
# 54. EVENT STUDY
# ============================================================

# Un event study permette di osservare
# come l'effetto evolve nel tempo.
#
# È utile anche per controllare
# cosa accade prima della policy.
#
# i() crea automaticamente
# le interazioni tra:
#
# event_time
#
# e
#
# treated.
#
# ref = -1 significa:
#
# utilizziamo l'anno immediatamente precedente
# alla policy come categoria di riferimento.


event_model <- feols(
  
  sales ~
    
    i(
      
      event_time,
      
      treated,
      
      ref = -1
      
    ) |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(event_model)


# ============================================================
# 55. GRAFICO EVENT STUDY
# ============================================================

# iplot() produce automaticamente
# il grafico dei coefficienti dinamici.


iplot(event_model)


# ============================================================
# 56. COME LEGGERE L'EVENT STUDY
# ============================================================

# Prima della policy:
#
# guardiamo se i coefficienti
# sono vicini a zero.
#
# Se i gruppi presentano dinamiche
# molto diverse già prima della policy,
# la strategia DiD può essere poco credibile.
#
# Dopo la policy:
#
# osserviamo:
#
# - se compare un effetto;
# - quando compare;
# - se cresce;
# - se diminuisce;
# - se persiste.


# ============================================================
# 57. ANALISI DI ETEROGENEITÀ
# ============================================================

# Una politica non deve necessariamente
# produrre lo stesso effetto
# su tutte le imprese.
#
# Ad esempio:
#
# grandi imprese
#
# e
#
# piccole imprese
#
# possono reagire diversamente.
#
# Interagiamo quindi:
#
# did
#
# e
#
# large_firm.


heterogeneity_model <- feols(
  
  sales ~
    
    did * large_firm |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(
  heterogeneity_model
)


# ============================================================
# 58. ETEROGENEITÀ PER SETTORE
# ============================================================

# Possiamo fare lo stesso
# confrontando imprese ICT
# e imprese non ICT.


model_sector <- feols(
  
  sales ~
    
    did * ict |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(model_sector)


# ============================================================
# 59. ETEROGENEITÀ TERRITORIALE
# ============================================================

# Creiamo una dummy:
#
# south = 1
#
# se l'impresa si trova nel Sud.


df <- df |>
  
  mutate(
    
    south = if_else(
      
      region == "South",
      
      1,
      
      0
      
    )
    
  )


table(df$south)


# Ora interagiamo la policy
# con la localizzazione nel Sud.


model_south <- feols(
  
  sales ~
    
    did * south |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(model_south)


# ============================================================
# 60. REGRESSIONE CON OUTCOME IN LOG
# ============================================================

# Abbiamo creato:
#
# log_sales = log(sales)
#
# Stimiamo quindi:


model_log <- feols(
  
  log_sales ~
    
    did |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(model_log)


# Se il coefficiente è piccolo,
# può essere letto approssimativamente
# come una variazione percentuale.
#
# Ad esempio:
#
# coefficiente = 0.05
#
# circa:
#
# +5%


# ============================================================
# 61. DATI WIDE E DATI LONG
# ============================================================

# Due strutture molto comuni sono:
#
# WIDE
#
# e
#
# LONG.
#
# In un dataset WIDE
# lo stesso indicatore compare
# in colonne diverse per anno.


wide_data <- tibble(
  
  id = 1:3,
  
  sales_2023 = c(
    100,
    120,
    140
  ),
  
  sales_2024 = c(
    110,
    135,
    150
  )
  
)


wide_data


# ============================================================
# 62. DA WIDE A LONG
# ============================================================

# pivot_longer()
# trasforma più colonne
# in una struttura lunga.


long_data <- wide_data |>
  
  pivot_longer(
    
    cols =
      starts_with("sales_"),
    
    names_to =
      "year",
    
    values_to =
      "sales"
    
  )


long_data


# Ora abbiamo una riga
# per ciascuna combinazione
# impresa-anno.


# ============================================================
# 63. PULIRE IL NOME DELL'ANNO
# ============================================================

# La variabile year contiene:
#
# sales_2023
#
# sales_2024
#
# Vogliamo tenere soltanto:
#
# 2023
#
# 2024.
#
# str_remove() rimuove una parte
# di una stringa.


long_data <- long_data |>
  
  mutate(
    
    year = str_remove(
      
      year,
      
      "sales_"
      
    ),
    
    year = as.numeric(year)
    
  )


long_data


# ============================================================
# 64. DA LONG A WIDE
# ============================================================

# Possiamo fare anche l'operazione inversa.


wide_again <- long_data |>
  
  pivot_wider(
    
    names_from = year,
    
    values_from = sales
    
  )


wide_again


# ============================================================
# 65. IMPORTARE UN FILE CSV
# ============================================================

# Nei dati reali normalmente partiremo
# da un file esterno.
#
# Supponiamo di avere:
#
# data/imprese.csv
#
# Potremmo utilizzare:


# dati <- read_csv(
#   "data/imprese.csv"
# )


# ============================================================
# 66. FILE CSV CON SEPARATORE ;
# ============================================================

# In molti file europei
# il separatore non è la virgola,
# ma il punto e virgola.
#
# In questo caso possiamo usare:


# dati <- read_csv2(
#   "data/imprese.csv"
# )


# ============================================================
# 67. DOPO AVER IMPORTATO UN FILE
# ============================================================

# Le prime operazioni dovrebbero sempre essere:


# head(dati)

# glimpse(dati)

# dim(dati)

# names(dati)

# summary(dati)


# Mai iniziare subito una regressione
# senza prima capire:
#
# come sono strutturati i dati.


# ============================================================
# 68. CONTROLLARE I DUPLICATI
# ============================================================

# In un panel:
#
# id + year
#
# dovrebbe identificare univocamente
# un'osservazione.
#
# Verifichiamo eventuali duplicati.


duplicates <- df |>
  
  count(
    
    id,
    year
    
  ) |>
  
  filter(
    
    n > 1
    
  )


duplicates


# Se la tabella è vuota,
# non abbiamo duplicati
# nella combinazione id-year.


# ============================================================
# 69. CONTROLLARE IL PANEL
# ============================================================

# Contiamo quante osservazioni
# ha ciascuna impresa.


df |>
  
  count(id) |>
  
  head()


# Nel nostro esempio
# ogni impresa dovrebbe avere
# 6 osservazioni.


# ============================================================
# 70. SALVARE UN DATASET PULITO
# ============================================================

# write_csv() salva un dataset
# in formato CSV.


write_csv(
  
  df,
  
  "dataset_lezione11.csv"
  
)


# Dopo aver eseguito la riga,
# il file apparirà
# nella working directory.


# ============================================================
# 71. SALVARE UN GRAFICO
# ============================================================

# Prima salviamo il grafico
# dentro un oggetto.


graph_trends <- ggplot(
  
  trend_data,
  
  aes(
    
    x = year,
    
    y = mean_sales,
    
    color = factor(treated)
    
  )
  
) +
  
  geom_line(
    
    linewidth = 1
    
  ) +
  
  geom_point(
    
    size = 2
    
  ) +
  
  theme_minimal()


# Visualizziamo il grafico.

graph_trends


# Salviamo il grafico come PNG.

ggsave(
  
  filename =
    "trend_trattati_controlli.png",
  
  plot =
    graph_trends,
  
  width = 8,
  
  height = 5
  
)


# ============================================================
# 72. CONFRONTARE PIÙ MODELLI
# ============================================================

# etable() permette di visualizzare
# più regressioni insieme.


etable(
  
  did_fixest,
  
  did_cluster,
  
  model_log
  
)


# Questo è utile quando vogliamo mostrare:
#
# diverse specificazioni
#
# della stessa analisi.


# ============================================================
# 73. WORKFLOW COMPLETO
# ============================================================

# Ora riassumiamo il processo completo
# che gli studenti dovrebbero utilizzare
# in un lavoro empirico.


# ------------------------------------------------------------
# STEP 1
# CAPIRE I DATI
# ------------------------------------------------------------

glimpse(df)


# ------------------------------------------------------------
# STEP 2
# CONTROLLARE MISSING E DUPLICATI
# ------------------------------------------------------------

sum(
  is.na(df$sales)
)


df |>
  
  count(
    id,
    year
  ) |>
  
  filter(
    n > 1
  )


# ------------------------------------------------------------
# STEP 3
# CREARE IL DATASET DI ANALISI
# ------------------------------------------------------------

df_analysis <- df |>
  
  filter(
    
    !is.na(sales),
    
    !is.na(investment)
    
  )


# ------------------------------------------------------------
# STEP 4
# STATISTICHE DESCRITTIVE
# ------------------------------------------------------------

df_analysis |>
  
  group_by(treated) |>
  
  summarise(
    
    mean_sales =
      mean(sales),
    
    mean_investment =
      mean(investment),
    
    mean_employees =
      mean(employees),
    
    n =
      n()
    
  )


# ------------------------------------------------------------
# STEP 5
# OSSERVARE I TREND
# ------------------------------------------------------------

trend_analysis <- df_analysis |>
  
  group_by(
    
    year,
    
    treated
    
  ) |>
  
  summarise(
    
    mean_sales =
      mean(sales),
    
    .groups =
      "drop"
    
  )


ggplot(
  
  trend_analysis,
  
  aes(
    
    x = year,
    
    y = mean_sales,
    
    color =
      factor(treated)
    
  )
  
) +
  
  geom_line(
    
    linewidth = 1
    
  ) +
  
  geom_point() +
  
  theme_minimal()


# ------------------------------------------------------------
# STEP 6
# STIMARE IL MODELLO
# ------------------------------------------------------------

final_model <- feols(
  
  sales ~
    
    did |
    
    id + year,
  
  cluster = ~id,
  
  data =
    df_analysis
  
)


summary(
  final_model
)


# ------------------------------------------------------------
# STEP 7
# INTERPRETARE
# ------------------------------------------------------------

# Dopo la regressione dobbiamo chiederci:
#
# qual è il segno del coefficiente?
#
# qual è la sua dimensione?
#
# è statisticamente preciso?
#
# è economicamente rilevante?
#
# l'identificazione causale è credibile?
#
# esistono possibili spillover?
#
# il gruppo di controllo è appropriato?


# ============================================================
# 74. ESERCIZIO 1
# ============================================================

# Calcolare l'investimento medio
# separatamente per:
#
# trattati
#
# e
#
# controlli.


exercise_1 <- df |>
  
  group_by(treated) |>
  
  summarise(
    
    mean_investment =
      mean(
        
        investment,
        
        na.rm = TRUE
        
      )
    
  )


exercise_1


# ============================================================
# 75. ESERCIZIO 2
# ============================================================

# Calcolare le vendite medie
# per ogni anno
# e gruppo di trattamento.


exercise_2 <- df |>
  
  group_by(
    
    year,
    
    treated
    
  ) |>
  
  summarise(
    
    mean_sales =
      mean(
        
        sales,
        
        na.rm = TRUE
        
      ),
    
    .groups =
      "drop"
    
  )


exercise_2


# ============================================================
# 76. ESERCIZIO 3
# ============================================================

# Disegnare il trend delle vendite
# per trattati e controlli.


ggplot(
  
  exercise_2,
  
  aes(
    
    x = year,
    
    y = mean_sales,
    
    color =
      factor(treated)
    
  )
  
) +
  
  geom_line(
    
    linewidth = 1
    
  ) +
  
  geom_point(
    
    size = 2
    
  ) +
  
  theme_minimal()


# ============================================================
# 77. ESERCIZIO 4
# ============================================================

# Stimare una Difference-in-Differences
# con:
#
# effetti fissi di impresa
#
# effetti fissi di anno
#
# errori standard clusterizzati
# a livello di impresa.


exercise_model <- feols(
  
  sales ~
    
    did |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(
  exercise_model
)


# ============================================================
# 78. ESERCIZIO 5
# ============================================================

# Ripetere l'analisi
# utilizzando investment
# come outcome.


exercise_investment <- feols(
  
  investment ~
    
    did |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(
  exercise_investment
)


# ============================================================
# 79. ESERCIZIO 6
# ============================================================

# Verificare se l'effetto della policy
# è diverso per le imprese ICT.


exercise_ict <- feols(
  
  sales ~
    
    did * ict |
    
    id + year,
  
  cluster = ~id,
  
  data = df
  
)


summary(
  exercise_ict
)


# ============================================================
# 80. LE DOMANDE DA FARSI PRIMA DI OGNI ANALISI
# ============================================================

# Prima di iniziare una regressione,
# dobbiamo sempre essere in grado
# di rispondere a queste domande:
#
#
# 1. Qual è la domanda di ricerca?
#
#
# 2. Qual è l'unità di osservazione?
#
#    Impresa?
#    Comune?
#    Regione?
#    Individuo?
#
#
# 3. Qual è l'outcome?
#
#    Investimenti?
#    Occupazione?
#    Produttività?
#    Numero di imprese?
#
#
# 4. Qual è il trattamento?
#
#
# 5. Quando viene introdotta la politica?
#
#
# 6. Chi sono i trattati?
#
#
# 7. Chi sono i controlli?
#
#
# 8. Perché il gruppo di controllo
#    rappresenta un buon controfattuale?
#
#
# 9. I trattati e i controlli
#    avevano trend simili prima della policy?
#
#
# 10. Esistono spillover tra unità?
#
#
# 11. Il trattamento potrebbe essere
#     selezionato in modo endogeno?
#
#
# 12. Qual è il livello corretto
#     per clusterizzare gli errori standard?
#
#
# 13. L'effetto è statisticamente significativo?
#
#
# 14. L'effetto è economicamente rilevante?
#
#
# 15. Quali implicazioni di policy
#     possiamo realmente trarre?


# ============================================================
# 81. COSA NON FARE
# ============================================================

# ERRORE 1:
#
# importare un dataset
# e lanciare immediatamente una regressione.
#
#
# ERRORE 2:
#
# ignorare i missing.
#
#
# ERRORE 3:
#
# non controllare i duplicati.
#
#
# ERRORE 4:
#
# interpretare una correlazione
# come effetto causale.
#
#
# ERRORE 5:
#
# interpretare un p-value
# senza considerare
# la dimensione economica dell'effetto.
#
#
# ERRORE 6:
#
# usare un gruppo di controllo
# senza spiegare perché sia credibile.
#
#
# ERRORE 7:
#
# copiare codice
# senza capire cosa faccia.


# ============================================================
# 82. LOGICA COMPLETA DELL'ANALISI EMPIRICA
# ============================================================

# Il workflow che utilizzeremo
# può essere riassunto così:
#
#
# DOMANDA DI RICERCA
#
#        ↓
#
# DATI
#
#        ↓
#
# CONTROLLO DEL DATASET
#
#        ↓
#
# DATA CLEANING
#
#        ↓
#
# COSTRUZIONE DELLE VARIABILI
#
#        ↓
#
# STATISTICHE DESCRITTIVE
#
#        ↓
#
# VISUALIZZAZIONE
#
#        ↓
#
# STRATEGIA EMPIRICA
#
#        ↓
#
# REGRESSIONE
#
#        ↓
#
# ROBUSTEZZA / ETEROGENEITÀ
#
#        ↓
#
# INTERPRETAZIONE ECONOMICA
#
#        ↓
#
# IMPLICAZIONI DI POLICY


# ============================================================
# 83. FINE DELLA LEZIONE
# ============================================================

# Alla fine di questo script
# uno studente dovrebbe essere in grado di:
#
# - capire la struttura di un dataset;
#
# - distinguere righe e variabili;
#
# - lavorare con dati panel;
#
# - creare variabili dummy;
#
# - utilizzare select();
#
# - utilizzare filter();
#
# - utilizzare mutate();
#
# - utilizzare group_by();
#
# - utilizzare summarise();
#
# - utilizzare left_join();
#
# - gestire missing values;
#
# - costruire indicatori;
#
# - creare grafici con ggplot2;
#
# - stimare una regressione lineare;
#
# - interpretare una dummy;
#
# - creare una interaction term;
#
# - stimare una Difference-in-Differences;
#
# - utilizzare effetti fissi;
#
# - clusterizzare gli errori standard;
#
# - costruire un event study;
#
# - analizzare eterogeneità degli effetti;
#
# - esportare dati e grafici;
#
# - collegare risultati empirici
#   e interpretazione economica.


# ============================================================
# FINE SCRIPT
# ============================================================