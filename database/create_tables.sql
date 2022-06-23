

CREATE TABLE Remedios(
    id_remedio INT NOT NULL,
    Nome_Fantasia varchar(50) NOT NULL,
    Principio_ativo varchar(50) NOT NULL,
    Remedio_generico varchar(5) NOT NULL,
    Valor_Custo float NOT NULL,
    Valor_Venda float NOT NULL,
    Tarja_Preta varchar(5) NOT NULL,
    Fornecedor varchar(50) NOT NULL,
    PRIMARY KEY (id_remedio)
);

INSERT INTO Remedios VALUES (1,'TesteDip','Dipi','Sim',2.5, 5.4, 'Não', 'WForne');
INSERT INTO Remedios VALUES (2, 'TesteAzi','Azi','Sim',4, 6.7, 'Não', 'WForne');
INSERT INTO Remedios VALUES (3, 'Teste2Dip','Azi','Sim',5, 10, 'Não', 'WForne');
select * from Remedios

CREATE TABLE Promocao(
    id_promocao int not null,
    id_remedio int not null,
    principio_ativo varchar(50) not null,
    valor_promocional float not null,
    PRIMARY KEY (id_promocao),
    CONSTRAINT fk_Remedios
      FOREIGN KEY(id_remedio) 
	  REFERENCES Remedios(id_remedio)
);

CREATE TABLE Filial(
	id_filial int NOT NULL PRIMARY KEY,
	endereco varchar NOT NULL,
	cep varchar(8) NOT NULL,
	rua varchar(255),
	numero int,
	cidade varchar(255),
	nome varchar(255)
);

INSERT INTO Filial VALUES ( 1, 'Centro', '115236', 'Rua 1', 45, 'Camus', 'DrograMais');
INSERT INTO Filial VALUES ( 2, 'Centro', '005624', 'Rua 2', 489, 'Timba', 'DrograMais');


CREATE TABLE Estoque(
    id_filial INT NOT NULL,
    id_remedio INT NOT NULL,
    qtd_remedio INT NOT NULL,
    CONSTRAINT fk_Remedios_Estoque
      FOREIGN KEY(id_remedio) 
	  REFERENCES Remedios(id_remedio),
    CONSTRAINT fk_Filial_Estoque
      FOREIGN KEY(id_filial) 
	  REFERENCES Filial(id_filial)
);



INSERT INTO Estoque VALUES ( 1, 1, 8);
INSERT INTO Estoque VALUES ( 1, 2, 10);

select * from Estoque

-------------------------------------
--TRIGGER E PROCEDURE ATUALIZA ESTOQUE E PEDE PARA CADASTRAR
--O REMEDIO QUE AINDA NÃO CONSTA NO ESTOQUE
-------------------------------------

CREATE OR REPLACE FUNCTION atualiza_estoque() RETURNS TRIGGER
AS 
$$
DECLARE
    qtde integer;
BEGIN
    
    select count(*) into qtde FROM Estoque 
        WHERE id_filial = NEW.id_filial AND id_remedio = NEW.id_remedio;
    
	IF qtde > 0 THEN 
        UPDATE Estoque set qtd_remedio = qtd_remedio + NEW.qtd_remedio 
			where id_remedio = NEW.id_remedio AND id_filial = NEW.id_filial;
	ELSE
		raise exception 'Produto precisa ser cadastrado.';
    end if;
	return NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER t_atualiza_estoque
BEFORE INSERT ON Estoque
FOR EACH ROW
EXECUTE PROCEDURE atualiza_estoque();


CREATE OR REPLACE FUNCTION atualiza_estoque_delete() RETURNS TRIGGER
AS 
$$
BEGIN
	IF OLD.id_remedio = NEW.id_remedio AND OLD.id_filial = NEW.id_filial AND OLD.qtd_remedio = NEW.qtd_remedio THEN 
        DELETE FROM Estoque where qtd_remedio = NEW.qtd_remedio AND id_remedio = NEW.id_remedio AND id_filial = NEW.id_filial;
    end if;
	return NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER t_atualiza_estoque_delete
AFTER INSERT ON Estoque
FOR EACH ROW
EXECUTE PROCEDURE atualiza_estoque_delete();

INSERT INTO Estoque VALUES ( 1, 5, 3);
INSERT INTO Estoque VALUES ( 1, 2, 3);
DELETE FROM Estoque where qtd_remedio = 3
SELECT * FROM Estoque


---------------------------------
-- VIEW TEMP ESTOQUE MINIMO
---------------------------------

CREATE VIEW View_Estoque_Minimo AS 
select *
from Estoque 
where qtd_remedio <= 8;
    
select * from View_Estoque_Minimo;



-------------------
--PROMOCAO
-------------------

select * from Promocao;

CREATE OR REPLACE FUNCTION valor_promocao() RETURNS TRIGGER
AS 
$$
DECLARE 
    qtde float;
BEGIN
	select SUM(Valor_Custo) into qtde from Remedios 
           where id_remedio = NEW.id_remedio;
           
    IF NEW.valor_promocional < 1.1 * qtde then
        raise exception 'Valor Promocional menor que 110 Percento do Valor de Custo.';
    end if;
    return NEW;
END
$$ LANGUAGE plpgsql;


CREATE TRIGGER t_promocao_valor
BEFORE INSERT ON Promocao
FOR EACH ROW
WHEN (pg_trigger_depth() = 0) 
EXECUTE PROCEDURE valor_promocao();


CREATE OR REPLACE FUNCTION promocao_principio_ativo() RETURNS TRIGGER
AS 
$$
declare 
    _principio_ativo varchar;
BEGIN
    FOR _principio_ativo IN 
        select principio_ativo from Promocao LOOP
           IF NEW.principio_ativo = _principio_ativo then
                raise exception 'Principio Ativo ja existente.';
           END IF;
        END LOOP;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_promocao_principio_ativo
BEFORE INSERT ON Promocao
FOR EACH ROW
WHEN (pg_trigger_depth() = 0) 
EXECUTE PROCEDURE promocao_principio_ativo();


INSERT INTO Promocao VALUES (1, 2, 'Azi', 4);
INSERT INTO Promocao VALUES (1, 2, 'Azi', 6);
INSERT INTO Promocao VALUES (2, 3, 'Azi', 9);
DELETE FROM Promocao where id_remedio = 1
select * from Promocao
select * from Remedios




----------------------------------------------
--DEMAIS CREATES
-------------------------------------------



CREATE TABLE Venda(
	id_venda INT NOT NULL PRIMARY KEY,
	id_nf INT NOT NULL,
	id_remedio INT NOT NULL,
	data_fim DATE NOT NULL,
	valor_total float NOT NULL,
	qtd_item INT NOT NULL,
	FOREIGN KEY (id_remedio) REFERENCES Remedios(id_remedio)
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

CREATE TABLE Nf(
	id_nf INT NOT NULL PRIMARY KEY,
	id_vendedor INT NOT NULL,
	id_filial INT NOT NULL,
	valor_total FLOAT NOT NULL,
	qtd_remedios INT NOT NULL,
	data_nf DATE NOT NULL,
	FOREIGN KEY (id_filial) REFERENCES Filial(id_filial),
	FOREIGN KEY (id_vendedor) REFERENCES Funcionarios(id_func)
);


CREATE TABLE Comissao(
	id_comissao INT NOT NULL PRIMARY KEY,
	id_vendedor INT NOT NULL,
	comissao float NOT NULL,
	FOREIGN KEY (id_vendedor) REFERENCES Funcionarios(id_func)
);








