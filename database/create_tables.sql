CREATE TABLE Filial(
	id_filial int NOT NULL PRIMARY KEY,
	endereco varchar NOT NULL,
	cep varchar(8) NOT NULL,
	rua varchar(255),
	numero int,
	cidade varchar(255),
	nome varchar(255)
);

CREATE TABLE Funcionarios(
	id_func int NOT NULL PRIMARY KEY,
	id_filial int NOT NULL,/*FOREIGN KEY REFERENCES Filial(id_filial),*/
	nome varchar(255) NOT NULL,
	cep varchar(8),
	rua varchar(255),
	numero int,
	salario float NOT NULL DEFAULT 1218,
	sexo varchar(255),
	FOREIGN KEY (id_filial) REFERENCES Filial(id_filial)
);


CREATE TABLE Remedios(
    id_remedio INT NOT NULL,
    Nome_Fantasia varchar(50) NOT NULL,
    Principio_ativo varchar(50) NOT NULL,
    Remedio_generico varchar(5) NOT NULL,
    Valor_Custo float NOT NULL,
    Valor_Venda float NOT NULL,
    Tarja_Preta varchar(5) NOT NULL,
    Fornecedor varchar(50) NOT NULL
);


CREATE TABLE Estoque(
    id_estoque INT NOT NULL,
    id_filial INT NOT NULL,
    id_remedio INT NOT NULL,
    qtd_remedio INT NOT NULL
);


CREATE TABLE Promocao(
    id_promocao int not null,
    id_remedio int not null,
    valor_promocional float not null
);














