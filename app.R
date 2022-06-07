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

tryCatch({
  drv <- dbDriver("PostgreSQL")
  print("Connecting to Database…")
  connec <- dbConnect(RPostgres::Postgres(),
                      dbname = db,
                      host=host_db,
                      port=db_port,
                      user=db_user,
                      password=db_password)
  print("Database Connected!")
},
error=function(cond) {
  print("Unable to connect to Database.")
})

num_func = dbGetQuery(connec, paste0("SELECT COUNT(id_func) FROM Funcionarios",";"))
num_filial = dbGetQuery(connec, paste0("SELECT COUNT(id_filial) FROM Filial",";"))
avg_salary = round(dbGetQuery(connec, paste0("SELECT AVG(salario) FROM Funcionarios",";")),2)

counts_filial = dbGetQuery(connec, paste0("SELECT id_filial FROM Funcionarios",";"))
names_func = dbGetQuery(connec, paste0("SELECT nome FROM Funcionarios",";"))
columns_names = names(dbGetQuery(connec, paste0("SELECT * FROM Funcionarios",";")))


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
    menuItem("Update Tables", tabName = "update_table", icon = icon("exchange-alt")),
    menuItem("Insert Entries", tabName = "insert_value", icon = icon("edit")),
    menuItem("Delete Tables", tabName = "del_table", icon = icon("trash-alt")),
    menuItem("About US", tabName = "about", icon = icon("info-circle"))
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
            numericInput('num_input', '',value=100),
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
                      choice=c('Todas',counts_filial$id_filial),
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
      #  collapsible = T,
      #  closable = FALSE,
      #  solidHeader = F,
      #  width=7,
      #  tableOutput("table1"),
      #  status='primary'
      #)
      ),
    tabItem(tabName = "del_table",uiOutput("tab2UI")),
    tabItem(tabName = "update_table", uiOutput("tab3UI")),
    tabItem(tabName = "create_table", uiOutput("tab4UI")),
    tabItem(tabName = "insert_value", uiOutput("tab5UI")),
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
    print(c(input$file_type,input$columns_names,input$name_func))
    if (input$file_type == "Todas" & input$columns_names == "Todas" & input$name_func==""){
      print('TESTANDO')
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
  columns_names
output$table1 <- DT::renderDataTable({
  db = dataInput()
  db
},options = list(scrollX = TRUE),escape = FALSE,server=F)


output$totalestoque <- renderInfoBox({
  infoBox(
    "Estoque", 123456, icon = icon("list"),
    color = "purple"
  )
})
output$totalfilial <- renderInfoBox({
  infoBox(
    "Filiais", num_filial, icon = icon("	glyphicon glyphicon-home", lib = "glyphicon"),
    color = "fuchsia"
  )
})
output$totalfuncionario <- renderInfoBox({
  infoBox(
    "Funcionarios", num_func, icon = icon("glyphicon glyphicon-user", lib = "glyphicon"),
    color = "blue"
  )
})
output$salariomedio <- renderInfoBox({
  infoBox(
    "Salário médio", paste0("R$"," ",avg_salary), icon = icon("glyphicon glyphicon-usd", lib = "glyphicon"),
    color = "green"
  )
})

output$plot1 <- renderPlot({
  db = dataInput()
  print(db)
  mu <- ddply(db, "sexo", summarise, grp.mean=mean(salario))
  
  # Add mean lines
  p<-ggplot(db, aes(x=salario, color=sexo)) +
    geom_histogram(fill="white", position="dodge")+
    geom_vline(data=mu, aes(xintercept=grp.mean, color=sexo),
               linetype="dashed")+
    theme(legend.position="top")
  p
})
}

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