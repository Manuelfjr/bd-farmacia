library(shiny)
library(shinyjs)
library(shinyauthr)
library(shinydashboard)
library(shinydashboardPlus)

library(DBI)
library(RODBC)

library(plyr)
library(ggplot2)

db <- 'postgres'  #provide the name of your db
host_db <- "localhost" #i.e. # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'  
db_port <- '5432'  # or any other port specified by the DBA
db_user <- "postgres"  
db_password <- "20180008601"
#Consultas
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

num_func = dbGetQuery(connec, paste0("SELECT COUNT(id_func) FROM Funcionarios",";"))
num_filial = dbGetQuery(connec, paste0("SELECT COUNT(id_filial) FROM Filial",";"))
avg_salary = round(dbGetQuery(connec, paste0("SELECT AVG(salario) FROM Funcionarios",";")),2)

counts_filial = dbGetQuery(connec, paste0("SELECT id_filial FROM Funcionarios",";"))
names_func = dbGetQuery(connec, paste0("SELECT nome FROM Funcionarios",";"))
columns_names = names(dbGetQuery(connec, paste0("SELECT * FROM Funcionarios",";")))
names(dbGetQuery(connec, paste0("SELECT * FROM Filial",";")))

ui <- dashboardPage(
dashboardHeader(title = tags$div(icon("fa-solid fa-pills"),"Farmácias M&W"),
                dropdownMenu(type = "messages",
                             messageItem(
                               from = "Support",
                               message = tags$div("Call me if has a problem"),
                               icon = icon("life-ring"),
                               time = format(Sys.time(), "%a %b %d %X %Y"),
                               href = "mailto:ferreira.jr.ufpb@gmail.com"
                             )
                ),
                tags$li(a(href = 'https://github.com/Manuelfjr',
                          icon("github"),
                          title = "Github"),
                        class = "dropdown"),
                tags$li(a(href = 'https://sites.google.com/site/marceloiury/cursos/',
                          img(src = "https://cdn-icons-png.flaticon.com/512/3161/3161158.png",#icon("fa-solid fa-database"),
                              title = "Banco de Dados 01", height = "30px"),
                          style = "padding-top:10px; padding-bottom:10px;"),
                        class = "dropdown")),
dashboardSidebar(
  collapsed = F, 
  div(htmlOutput("welcome"), style = "padding: 20px"),
  sidebarMenu(
    menuItem("View Tables", 
             tabName = "view_table", icon = icon("search")),
    #menuItem("Create Tables", tabName = "create_table", icon = icon("plus-square")),
    menuItem("Update", tabName = "update_table", icon = icon("exchange-alt")),
    menuItem("Insert", tabName = "insert_value", icon = icon("edit")),
    menuItem("Delete", tabName = "del_table", icon = icon("trash-alt")),
    #menuItem("Consultas", tabName = "del_table", icon = icon("file-import")),
    menuItem("Sobre nós", tabName = "about", icon = icon("info-circle"))#glyphicon glyphicon-save
  )
),
dashboardBody(
  tabItems(
    tabItem(
      # infoBoxes with fill=FALSE
      fluidRow(
        infoBoxOutput("totalestoque",widt=3),
        infoBoxOutput("totalfilial",widt=3),
        infoBoxOutput("totalfuncionario",widt=3),
        infoBoxOutput("salariomedio",widt=3)
      ),
      fluidRow(
        box(
            title='Linhas',
            id = "filter1",
            collapsible = T,
            closable = FALSE,
            solidHeader = T,
            width=3,
            numericInput('num_input', '',value=1000),
            status='primary'
          ),
        box(
          title='Colunas',
          id = "filter5",
          collapsible = T,
          closable = FALSE,
          solidHeader = T,
          width=3,
          selectInput(inputId = "columns_names",
                      label = "",
                      choice=c('Todas',columns_names),
                      selected='Todas'),
          status='primary'
        ),
        box(
          title='Filial',
          id = "filter2",
          collapsible = T,
          closable = FALSE,collapsed =T,
          solidHeader = T,
          width=3,
          selectInput(inputId = "file_type",
                      label = "",
                      choice=c('Todas',counts_filial$id_filial),
                      selected='Todas'),
          status='primary'
        ),
        box(
          title='Funcionário',
          id = "filter3",
          collapsible = T,
          closable = FALSE,collapsed =T,
          solidHeader = T,
          width=3,
          textInput('name_func', '',value="",placeholder="Todos"),
          status='primary'
        )
      ),
      tabName = "view_table",
      uiOutput("tab1UI"),
      fluidRow(
        #column(
        box(
          title="Tabela de Funcionários",
          id = "mytable",
          collapsible = T,
            closable = FALSE,
            solidHeader = T,
            width=12,
          DT::dataTableOutput("table1"),
            status='primary'
        ),
        box(
          title="Distribuição dos salários",
          id = "myplot1",
          collapsible = T,
          closable = FALSE,collapsed =T,
          solidHeader = T,
          width=12,
          plotOutput("plot1"),
          status='primary'
        )
        #,width=12)
      )
      #box(#title = h2("Base"),
      #  uiOutput("tab1UI"),
      #  id = "mybox",
      #  collapsible = T,Todas
      #  closable = FALSE,
      #  solidHeader = F,
      #  width=7,
      #  tableOutput("table1"),
      #  status='primary'
      #)
      ),
    tabItem(tabName = "del_table",
            box(
              title='Informe o ID do funcionario',
              id = "del_input_id_func",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=12,
              numericInput('num_del', '',value=2),
                #tags$head(tags$script(src = "message-handler.js")),
              actionButton("del", "Delete", class = "btn-link"),
              status='primary'
            ),
            uiOutput("tab2UI")),
    tabItem(tabName = "update_table",
            box(
              title='Selecione o ID do funcionario',
              id = "id_fun",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=9,
              numericInput('id_fun_up', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='ID filial',
              id = "id_filial",
              collapsible = T,
              collapsed =T,
              closable = FALSE,
              solidHeader = T,
              width=3,
              checkboxInput("id_filial__up", "", FALSE),
              numericInput('id_fil_up', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Nome',
              id = "nome",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("nome__up", "", FALSE),
              textInput('nome_up', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='CEP',
              id = "cep",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("cep__up", "", FALSE),
              textInput('cep_up', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Rua',
              id = "rua",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("rua__up", "", FALSE),
              textInput('rua_up', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Numero',
              id = "numero",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("numero__up", "", FALSE),
              numericInput('numero_up', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Salario',
              id = "salario",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("salario__up", "", FALSE),
              numericInput('salario_up', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Sexo',
              id = "sexo",
              collapsible = T,
              closable = FALSE,collapsed =T,
              solidHeader = T,
              width=4,
              checkboxInput("sexo__up", "", FALSE),
              textInput("sexo_up",''),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            fluidPage(
              column(12,actionButton("up", "Update", class = "btn-link"), align="center")),
            uiOutput("tab3UI")),
    #tabItem(tabName = "create_table", uiOutput("tab4UI")),
    tabItem(tabName = "insert_value",
            box(
              title='ID filial',
              id = "id_filial",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              numericInput('id_fil', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='nome',
              id = "nome",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              textInput('nome_', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='CEP',
              id = "cep",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              textInput('cep_', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Rua',
              id = "rua",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              textInput('rua_', '',value=""),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Numero',
              id = "numero",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              numericInput('numero_', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Salario',
              id = "salario",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=4,
              numericInput('salario_', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            box(
              title='Sexo',
              id = "sexo",
              collapsible = T,
              closable = FALSE,
              solidHeader = T,
              width=12,
              textInput('sexo_', '',value=NULL),
              #tags$head(tags$script(src = "message-handler.js")),
              #actionButton("inser", "Insert", class = "btn-link"),
              status='primary'
            ),
            fluidPage(
              column(12,actionButton("inser", "Insert", class = "btn-link"), align="center")),
            uiOutput("tab5UI")),
    tabItem(tabName = "about",
            userBox(
              title = userDescription(
                title = tags$a(href="https://manuelfjr.github.io","Manuel Ferreira Junior",style="color:white"),
                subtitle = tags$div("Jr. Data Scientist at ", tags$b(tags$a(href="https://www.semprocesso.com.br/", "Sem Processo"))),
                type = 1,
                image = "https://raw.githubusercontent.com/Manuelfjr/birt-gd/main/assets/author.jpg",
                backgroundImage = "https://cdn.statically.io/img/wallpaperaccess.com/full/1119564.jpg"
              ),
              status = "primary",
              footer = "I’m an undergraduate student in statistics at the Federal University of Paraiba (UFPB). I’m 82% statistic, I come from my second scientific initiation project, I have mastered the R, Python languages. Maybe I don’t know, but I’m going after that, slogan :), I like to program in my free time and learn new things, ah, it is worth mentioning that a coffee helps a lot."
            ),
            userBox(
              title = userDescription(
                tags$a(href="https://github.com/wanusapontes","Wanusa Pontes",style="color:white"),
                subtitle = tags$div("Data Analyst at ", tags$b(tags$a(href="https://deal.com.br/", "DEAL"))),
                type = 1,
                image = "https://media-exp1.licdn.com/dms/image/C4E03AQFpwrSKCqAacw/profile-displayphoto-shrink_800_800/0/1623117087852?e=1659571200&v=beta&t=NWBaEZj5Tfyj70ADj_ajTaBlhN4PmmNCB1hT75J5Pxw",
                backgroundImage = "https://cdn.statically.io/img/wallpaperaccess.com/full/1119564.jpg"
              ),
              status = "primary",
              footer = tags$div(
                tags$ul(
                  tags$li("I’m currently working on Data Analysis and Data Science."), 
                  tags$li("I’m currently learning Oracle, Machine Learning and Cloud Computer."), 
                  tags$li("Pronouns: She/Her")
                )
              )
            ),
            uiOutput("tab6UI"))
    )
  )

)




server <- function(input, output, session) {
  dataInput <- reactive({
    #dbGetQuery(connec, paste0(
    #  "SELECT * FROM Funcionarios LIMIT ", input$num_input,";"))
    if (input$file_type == "Todas" & input$columns_names == "Todas" & input$name_func==""){
      dbGetQuery(connec, paste0(
        "SELECT * FROM Funcionarios LIMIT ", input$num_input,";"))
    }else{
      if (input$file_type != "Todas" & input$columns_names == "Todas" & input$name_func==""){
        dbGetQuery(connec, paste0(
          "SELECT * FROM Funcionarios WHERE id_filial='",input$file_type,"' LIMIT ", input$num_input,";"))
      }else{
        if (input$file_type == "Todas" & input$columns_names != "Todas" & input$name_func==""){
          dbGetQuery(connec, paste0(
            "SELECT ",input$columns_names," FROM Funcionarios LIMIT ", input$num_input,";"))
        }else{
          if (input$file_type == "Todas" & input$columns_names == "Todas" & input$name_func!=""){
            dbGetQuery(connec, paste0(
              "SELECT * FROM Funcionarios WHERE nome='",input$name_func,"' LIMIT ", input$num_input,";"))
          }else{
            if (input$file_type == "Todas" & input$columns_names != "Todas" & input$name_func!=""){
              dbGetQuery(connec, paste0(
                "SELECT ",input$columns_names," FROM Funcionarios WHERE nome='",input$name_func,"' LIMIT ", input$num_input,";"))
            }else{
              if (input$file_type != "Todas" & input$columns_names == "Todas" & input$name_func!=""){
                dbGetQuery(connec, paste0(
                  "SELECT * FROM Funcionarios WHERE nome='",input$name_func,"' AND id_filial='",input$file_type,"' LIMIT ", input$num_input,";"))
              }else{
                if (input$file_type != "Todas" & input$columns_names != "Todas" & input$name_func==""){
                  dbGetQuery(connec, paste0(
                    "SELECT ",input$columns_names," FROM Funcionarios WHERE id_filial='",input$file_type,"' LIMIT ", input$num_input,";"))
                }else{
                  if (input$file_type != "Todas" & input$columns_names != "Todas" & input$name_func!=""){
                    dbGetQuery(connec, paste0(
                      "SELECT ",input$columns_names," FROM Funcionarios WHERE id_filial='",input$file_type,"' AND id_filial='",input$file_type,"' LIMIT ", input$num_input,";"))
                  }
                }
              }
            }
          }
        }
      }
    }
  })
  
output$table1 <- DT::renderDataTable({
  db = dataInput()
  db
},options = list(scrollX = TRUE),escape = FALSE,server=F)


output$totalestoque <- renderInfoBox({
  infoBox(
    "Estoque", 1250, icon = icon("list"),
    color = "purple"
  )
})
output$totalfilial <- renderInfoBox({
  infoBox(
    "Filiais", dbGetQuery(connec, paste0("SELECT COUNT(id_filial) FROM Filial",";")), icon = icon("	glyphicon glyphicon-home", lib = "glyphicon"),
    color = "fuchsia"
  )
})
output$totalfuncionario <- renderInfoBox({
  infoBox(
    "Funcionarios", dbGetQuery(connec, paste0("SELECT COUNT(id_func) FROM Funcionarios",";")), icon = icon("glyphicon glyphicon-user", lib = "glyphicon"),
    color = "blue"
  )
})
output$salariomedio <- renderInfoBox({
  infoBox(
    "Salário médio", paste0("R$"," ",avg_salary = round(dbGetQuery(connec, paste0("SELECT AVG(salario) FROM Funcionarios",";")),2)), icon = icon("glyphicon glyphicon-usd", lib = "glyphicon"),
    color = "green"
  )
})

output$plot1 <- renderPlot({
  db = dataInput()
  mu <- ddply(db, "sexo", summarise, grp.mean=mean(salario))
  
  # Add mean lines
  p<-ggplot(db, aes(x=salario, color=sexo)) +
    geom_histogram(fill="white", position="dodge")+
    geom_vline(data=mu, aes(xintercept=grp.mean, color=sexo),
               linetype="dashed")+
    labs(x="Salário",y="Frequência")+
    theme(legend.position="top")
  p
})

delete <- function(query){
  query = paste("DELETE FROM Funcionarios WHERE id_func=",input$num_del,";",sep='')
  dbGetQuery(connec, query)
}

insert <- function(query){
  num_func_extra = dbGetQuery(connec, paste0("SELECT MAX(id_func) FROM Funcionarios",";"))
  a = paste(
    num_func_extra$max+1,
    input$id_fil,
    paste0("'",input$nome_,"'"),
    paste0("'",input$cep_,"'"),
    paste0("'",input$rua_,"'"),
    input$numero_,
    input$salario_,
    paste0("'",input$sexo_,"'"),
    sep=", ")
  query = paste("INSERT INTO Funcionarios (id_func, id_filial, nome, cep, rua, numero, salario, sexo) ",
                "VALUES (", a,");",sep='')
  print(query)
  #print(insert)
  dbGetQuery(connec, query)
}

update <- function(a, b){
  names_to_change = columns_names[a]
  values_to_change = b
  
  if(length(names_to_change)==1){
    tryCatch(
      {
        query=paste0("UPDATE Funcionarios SET ",names_to_change,"= '",values_to_change,"' WHERE id_func=",input$id_fun_up)
        dbGetQuery(connec, query)
      },
      error=function(cond) {
        query=paste0("UPDATE Funcionarios SET ",names_to_change,"= ",values_to_change," WHERE id_func=",input$id_fun_up)
        dbGetQuery(connec, query)
      }
    )
  }else{
    names = "UPDATE Funcionarios SET "
    names_char = NULL
    names_float = NULL
    bool_char = columns_names[c(F, F, T, T, T, F, F, T)]
    #bool_char = which(bool_char==T)
    bool_float = columns_names[!c(F, F, T, T, T, F, F, T)]
    #bool_float = which(bool_float==T)
    
    
    # char
    z = 0
    if(T%in%(names_to_change%in%bool_char)){
      #names_char = numeric(length(names_to_change%in%bool_char))
      k=1
      for (i in 1:length(bool_char)){
        for (j in 1:length(names_to_change)){
          if (bool_char[i]==names_to_change[j]){
            names_char[k] = paste0(names_to_change[j],"='",values_to_change[j],"'")
            k=k+1
          }
        }
      }
      #print(names_char)
      z=1
    }
    
    # float
    w = 0
    if(T%in%(names_to_change%in%bool_float)){
      #names_char = numeric(length(names_to_change%in%bool_char))
      k=1
      for (i in 1:length(bool_float)){
        for (j in 1:length(names_to_change)){
          if (bool_float[i]==names_to_change[j]){
            names_float[k] = paste0(names_to_change[j],"=",values_to_change[j])
            k=k+1
          }
        }
      }
      #print(names_float)
      w=1
    }
    
    if (z!=0 & w==0){
      names_final = paste0(names,
                           paste0(names_char, collapse = ", "),
                           " WHERE id_func=",input$id_fun_up,";")#sep=' ')
    }else{
      if (z==0 & w!=0){
        names_final = paste0(names,
                             paste0(names_float, collapse = ", "),
                             " WHERE id_func=",input$id_fun_up,';')
      }else{
        if (z!=0 & w!=0){
          names_final = paste0(names,
                               paste0(names_float, collapse = ", "),', ',
                               paste0(names_char, collapse = ", "),
                               " WHERE id_func=",input$id_fun_up,';')#sep=' ')
        }
      }
    }
    query = names_final
    dbGetQuery(connec, query)
   }
  }

observeEvent(input$del, {
  # 0 will be coerced to FALSE
  # 1+ will be coerced to TRUE
  delete()
  showNotification(paste0('Você acaba de deletar o funcionario ', input$num_del, " da base de dados"), duration = 5)
  #session$sendCustomMessage(type = 'testmessage',
  #                          message = paste0('Você acaba de deletar o funcionario', input$num_del, "da base de dados"))
})

observeEvent(input$inser, {
  # 0 will be coerced to FALSE
  # 1+ will be coerced to TRUE
  insert()
  showNotification(paste0('Você acaba de inserir um novo Funcionario na base de dados'), duration = 5)
  #session$sendCustomMessage(type = 'testmessage',
  #                          message = paste0('Você acaba de deletar o funcionario', input$num_del, "da base de dados"))
})

observeEvent(input$up, {
  # 0 will be coerced to FALSE
  # 1+ will be coerced to TRUE
  #update()
  a = c(FALSE,c(input$id_filial__up,input$nome__up,input$cep__up, input$rua__up, input$numero__up, input$salario__up, input$sexo__up))
  alls = c(0,input$id_fil_up,input$nome_up,input$cep_up,input$rua_up, input$numero_up,input$salario_up,input$sexo_up)
  b = alls[a]
  
  update(a,b)
  showNotification(paste0('Você acaba de atualizar as informações de um Funcionario na base de dados'), duration = 5)
  #session$sendCustomMessage(type = 'testmessage',
  #                          message = paste0('Você acaba de deletar o funcionario', input$num_del, "da base de dados"))
})
}
#http://127.0.0.1:3925
# id_fil,id_filial__, nome_,nome__, cep_,cep__, rua_,rua__, numero_,numero__,
# salario_,salario__, sexo_,sexo__

shinyApp(ui, server)

#output$table1 <- renderTable({
#  conn <- dbConnect(
#    drv = RMySQL::MySQL(),#plot
#    dbname = "shinydemo",
#    host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
#    username = "guest",
#    password = "guest")
#  on.exit(dbDisconnect(conn), add = TRUE)
#  dbGetQuery(conn, paste0(
#    "SELECT * FROM City LIMIT ", input$num_input, ";"))
#})
# uma interface grafica para uma das entidades para cadastros (tabela funcionarios, principio ativo, etc)
# uma interface grafica para uma das consultas