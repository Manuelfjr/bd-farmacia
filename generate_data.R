##install.packages('maps')
#install.packages('randomNames')
library(maps)
library(randomNames)
library(DBI)

data(world.cities)
names(world.cities)

db <- 'postgres'  #provide the name of your db
host_db <- "localhost" #i.e. # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'  
db_port <- '5432'  # or any other port specified by the DBA
db_user <- "postgres"  
db_password <- "20180008601"

#tryCatch({
drv <- dbDriver("PostgreSQL")
print("Connecting to Database…")
connec <- dbConnect(RPostgres::Postgres(),
                      dbname = db,
                      host=host_db,
                      port=db_port,
                      user=db_user,
                      password=db_password)
print("Database Connected!")
#},
#error=function(cond) {
#  print("Unable to connect to Database.")
#})


# Generate filial datas ##############
## Generate columns values ###########
### Generate Filiais data ############
n = 30
set.seed(2022)
id_filial = seq(1,n)
endereco = sample(world.cities$name, size=n)
cep = NULL
for(i in 1:(n)){
  cep[i] = paste(sample(0:9, 8),sep='',collapse="")
}
rua = sample(world.cities$name, size=n)
numero = sample(0:n, size=n)
cidade = sample(world.cities$name[1:33], size=n,replace=T)
nome = sample(randomNames(n)[1:12],n,replace=T)

#rua[14] = 'xablau'
#endereco[21] = 'casa'

query = paste0(
  #"SELECT * FROM Filial;"
  "INSERT INTO Filial ",
  "VALUES (",id_filial[1],", 'cristo', '58070403', 'jose borges', 68, 'jp', 'manel');"
)
dbGetQuery(connec, query)

query = paste0(
  "SELECT * FROM Filial;"
)
dbGetQuery(connec, query)

for (i in 2:n){ 
  #print(i)
  #if (i <= 34){
  #  next
  #}
  query = paste(
    "INSERT INTO Filial VALUES (",paste(id_filial[i],
                                        paste("'",gsub("'","",endereco[i]),"'", sep=''),
                                        paste("'",gsub("'","",cep[i]),"'", sep=''),
                                        paste("'",gsub("'","",rua[i]),"'", sep=''),
                                        numero[i],
                                        paste("'",gsub("'","",cidade[i]),"'", sep=''),
                                        paste("'",gsub("'","",nome[i]),"'",sep=''),sep=", "),")"
  )
  dbGetQuery(connec, query)
}

query = paste0(
  "SELECT * FROM Filial;"
  #"INSERT INTO Filial ",
  #"VALUES (1, 'cristo', '58070403', 'jose borges', 68, 'jp', 'manel');"
)
dbGetQuery(connec, query)


### Generate Funcionarios data #######
m = 654
set.seed(2023)
id_func = seq(1,m)
#id_filial = c(id_filial[1], sample(id_filial[-1],size=m))
id_filial = c(id_filial[1], sample(id_filial[-1],size=m-1, replace=T))
#id_filial = sample(id_filial, size=n)
nome = sample(randomNames(m),m,replace=T)
cep = NULL
for(i in 1:(m)){
  cep[i] = paste(sample(0:9, 8),sep='',collapse="")
}
rua = sample(world.cities$name, size=m)
numero = sample(0:m, size=m)
salario = round(rnorm(m, mean=2750, sd = 1000),2)
sexo = sample(c('homem','mulher','outros'), size=m,replace=T)

query = paste0(
  #"SELECT * FROM Filial;"
  "INSERT INTO Funcionarios ",
  "VALUES (",id_func[1],", ",id_filial[1],", 'manuel', '58070403', 'jose borges', 68, 4500,'homem');"
)
dbGetQuery(connec, query)

query = paste0(
  "SELECT * FROM Funcionarios;"
)
dbGetQuery(connec, query)

for (i in 2:m){ 
  query = paste(
    "INSERT INTO Funcionarios VALUES (",paste(id_func[i],
                                        id_filial[i],
                                        paste("'",gsub("'","",nome[i]),"'",sep=''),
                                        paste("'",gsub("'","",cep[i]),"'", sep=''),
                                        paste("'",gsub("'","",rua[i]),"'", sep=''),
                                        numero[i],
                                        salario[i],
                                        paste("'",gsub("'","",sexo[i]),"'", sep=''),
                                        sep=", "),")"
  )
  dbGetQuery(connec, query)
}


query = paste0(
  "SELECT * FROM Funcionarios;"
  #"INSERT INTO Filial ",
  #"VALUES (1, 'cristo', '58070403', 'jose borges', 68, 'jp', 'manel');"
)
head(dbGetQuery(connec, query))

