CREATE DATABASE faculdade_nova_horizonte;
USE faculdade_nova_horizonte;

CREATE TABLE tb_alunos(
	pk_rgm INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome_aluno VARCHAR(120) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    email VARCHAR(120) UNIQUE
);

CREATE TABLE tb_disciplinas(
	pk_id_disciplina INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    nome_disciplina VARCHAR(120) NOT NULL,
    carga_horaria INT NOT NULL,
    descricao VARCHAR(280),
    status_disciplina VARCHAR(20) NOT NULL DEFAULT 'ativo'
);

CREATE TABLE tb_matriculas(
	pk_id_matricula INT AUTO_INCREMENT PRIMARY KEY,
	fk_rgm INT NOT NULL,
	fk_id_disciplina INT NOT NULL,
	data_matricula DATE NOT NULL,
	status_matricula VARCHAR(20) NOT NULL DEFAULT 'ativo',
	FOREIGN KEY (fk_rgm) REFERENCES tb_alunos(pk_rgm),
	FOREIGN KEY (fk_id_disciplina) REFERENCES tb_disciplinas(pk_id_disciplina)
);

CREATE TABLE tb_turmas(
	pk_id_turma INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_disciplina INT NOT NULL,
    nome_turma VARCHAR(50) NOT NULL,
    ano INT NOT NULL,
    semestre INT NOT NULL,
    status_turma VARCHAR(20) NOT NULL DEFAULT 'ativo',
    FOREIGN KEY (fk_id_disciplina) REFERENCES tb_disciplinas(pk_id_disciplina)
);

CREATE TABLE tb_grade_horaria(
	pk_id_grade INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_turma INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    sala VARCHAR(20) NOT NULL,
    FOREIGN KEY (fk_id_turma) REFERENCES tb_turmas(pk_id_turma)
);

CREATE TABLE tb_notas(
	pk_id_nota INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_matricula INT NOT NULL,
	nota_p1 DECIMAL(3,1),
    nota_p2 DECIMAL(3,1),
    nota_af DECIMAL(3,1),
    data_registro DATE NOT NULL,
    ultima_atualizacao DATE,
    FOREIGN KEY (fk_id_matricula) REFERENCES tb_matriculas(pk_id_matricula)
);

CREATE TABLE tb_faltas(
	pk_id_falta INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_matricula INT NOT NULL,
    quantidade INT NOT NULL,
    data_registro DATE NOT NULL,
    ultima_atualizacao DATE,
    FOREIGN KEY (fk_id_matricula) REFERENCES tb_matriculas(pk_id_matricula)
);

CREATE TABLE tb_contratos_educacionais(
	pk_id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    fk_rgm INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    status_contrato VARCHAR(20) NOT NULL DEFAULT 'ativo',
    data_criacao DATE NOT NULL,
    ultima_atualizacao DATE,
    FOREIGN KEY (fk_rgm) REFERENCES tb_alunos(pk_rgm)
);

CREATE TABLE tb_parcelas_contrato(
	pk_id_parcela INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_contrato INT NOT NULL,
    numero_parcela INT NOT NULL,
    valor_parcela DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status_parcela VARCHAR(20) NOT NULL DEFAULT 'ativo',
    data_criacao DATE NOT NULL,
    ultima_atualizacao DATE,
    FOREIGN KEY (fk_id_contrato) REFERENCES tb_contratos_educacionais(pk_id_contrato)
);

CREATE TABLE tb_inadimplencia(
	pk_id_inadimplencia INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_parcela INT NOT NULL,
    data_registro DATE NOT NULL,
    status_inadimplencia VARCHAR(20) NOT NULL DEFAULT 'ativo',
    observacao VARCHAR(200),
    FOREIGN KEY (fk_id_parcela) REFERENCES tb_parcelas_contrato(pk_id_parcela)
);

CREATE TABLE tb_funcionarios(
	pk_id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome_funcionario VARCHAR(120) NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    data_nascimento DATE NOT NULL,
    email VARCHAR(120) UNIQUE,
    telefone VARCHAR(15),
    cargo VARCHAR(50) NOT NULL,
    status_funcionario VARCHAR(20) NOT NULL DEFAULT 'ativo',
    data_admissao DATE NOT NULL,
    data_demissao DATE
);

CREATE TABLE tb_professores(
	pk_id_professor INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_funcionario INT NOT NULL,
    titulacao VARCHAR(50),
    area_atuacao VARCHAR(100),
    FOREIGN KEY (fk_id_funcionario) REFERENCES tb_funcionarios(pk_id_funcionario)
);