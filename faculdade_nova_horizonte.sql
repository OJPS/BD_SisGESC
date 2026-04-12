CREATE DATABASE faculdade_nova_horizonte;
USE faculdade_nova_horizonte;

CREATE TABLE alunos(
	rgm INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome_aluno VARCHAR(120) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    email VARCHAR(120) UNIQUE
);

CREATE TABLE disciplinas(
	id_disciplina INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome_disciplina VARCHAR(120) NOT NULL,
    carga_horaria INT NOT NULL,
    descricao VARCHAR(280),
    status_disciplina VARCHAR(20) NOT NULL
);

CREATE TABLE matriculas(
	id_matricula int auto_increment PRIMARY KEY,
	rgm INT NOT NULL,
	id_disciplina INT NOT NULL,
	data_matricula DATE NOT NULL,
	status_matricula VARCHAR(20) NOT NULL,
	foreign key (rgm) references alunos(rgm),
	foreign key (id_disciplina) references disciplinas(id_disciplina)
);

CREATE TABLE turmas(
	id_turma INT auto_increment PRIMARY KEY,
    id_disciplina INT NOT NULL,
    nome_turma VARCHAR(50) NOT NULL,
    ano INT NOT NULL,
    semestre INT NOT NULL,
    status_turma VARCHAR(20) NOT NULL,
    foreign key (id_disciplina) references disciplinas(id_disciplina)
);

CREATE TABLE grade_horaria(
	id_grade INT auto_increment PRIMARY KEY,
    id_turma INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    sala VARCHAR(20) NOT NULL,
    foreign key (id_turma) references turmas(id_turma)
);

CREATE TABLE notas(
	id_nota INT auto_increment PRIMARY KEY,
    id_matricula INT NOT NULL,
	nota_p1 DECIMAL(3,1),
    nota_p2 DECIMAL(3,1),
    nota_af DECIMAL(3,1),
    data_registro DATE NOT NULL,
    ultima_atualizacao DATE,
    foreign key (id_matricula) references matriculas(id_matricula)
);

CREATE TABLE faltas(
	id_falta INT auto_increment PRIMARY KEY,
    id_matricula INT NOT NULL,
    quantidade INT NOT NULL,
    data_registro DATE NOT NULL,
    ultima_atualizacao DATE,
    foreign key (id_matricula) references matriculas(id_matricula)
);

CREATE TABLE contratos_educacionais(
	id_contrato INT auto_increment PRIMARY KEY,
    rgm INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    status_contrato VARCHAR(20) NOT NULL,
    data_criacao DATE NOT NULL,
    ultima_atualizacao DATE,
    foreign key (rgm) references alunos(rgm)
);

CREATE TABLE parcelas_contrato(
	id_parcela INT auto_increment PRIMARY KEY,
    id_contrato INT NOT NULL,
    numero_parcela INT NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status_parcela VARCHAR(20) NOT NULL,
    data_criacao DATE NOT NULL,
    ultima_atualizacao DATE,
    foreign key (id_contrato) references contratos_educacionais(id_contrato)
);

CREATE TABLE inadimplencia(
	id_inadimplencia INT auto_increment PRIMARY KEY,
    id_parcela INT NOT NULL,
    data_registro DATE NOT NULL,
    status_inadimplencia VARCHAR(20) NOT NULL,
    observacao VARCHAR(200),
    foreign key (id_parcela) references parcelas_contrato(id_parcela)
);

CREATE TABLE funcionarios(
	id_funcionario INT auto_increment PRIMARY KEY,
    nome_funcionario VARCHAR(120) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    data_nascimento DATE NOT NULL,
    email VARCHAR(120) UNIQUE,
    telefone VARCHAR(15),
    cargo VARCHAR(50) NOT NULL,
    status_funcionario VARCHAR(20) NOT NULL,
    data_admissao DATE NOT NULL,
    data_demissao DATE
);

CREATE TABLE professores(
	id_professor INT auto_increment PRIMARY KEY,
    id_funcionario INT NOT NULL,
    titulacao VARCHAR(50),
    area_atuacao VARCHAR(100),
    foreign key (id_funcionario) references funcionarios(id_funcionario)
);












