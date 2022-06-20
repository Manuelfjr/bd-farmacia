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