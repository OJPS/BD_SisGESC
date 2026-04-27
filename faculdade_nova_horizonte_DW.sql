CREATE DATABASE faculdade_NH_dw;
USE faculdade_NH_dw;

CREATE TABLE dim_disciplina (
    sk_disciplina INT AUTO_INCREMENT PRIMARY KEY,
    nk_id_disciplina INT NOT NULL,
    nome_disciplina VARCHAR(120) NOT NULL,
    carga_horaria INT NOT NULL,
    status_disciplina VARCHAR(20) NOT NULL
);

CREATE TABLE dim_aluno ( 
    sk_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nk_rgm INT NOT NULL,
    nome_aluno VARCHAR(120),
    data_nascimento DATE
);

CREATE TABLE dim_funcionario (
    sk_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nk_id_funcionario INT NOT NULL,
    nome_funcionario VARCHAR(120),
    cargo VARCHAR(50),
    status_funcionario VARCHAR(20)
);

CREATE TABLE dim_turma (
    sk_turma INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    nk_id_turma INT NOT NULL,
    nome_turma VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    semestre INT NOT NULL,
    status_turma VARCHAR(20) NOT NULL
);

CREATE TABLE dim_tempo (
    sk_tempo INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    dia DATE NOT NULL,
    ano INT NOT NULL,
    mes INT NOT NULL,
    semestre INT NOT NULL
);

CREATE TABLE fato_desempenho (
    sk_fato INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    fk_aluno INT NOT NULL,
    fk_disciplina INT NOT NULL,
    fk_turma INT NOT NULL,
    fk_tempo INT NOT NULL,
	fk_funcionario INT NULL, 
    nota_p1 DECIMAL(3,1) NOT NULL,
    nota_p2 DECIMAL(3,1) NOT NULL,
    nota_af DECIMAL(3,1) NOT NULL,
    aprovacao VARCHAR(20) NOT NULL,
    FOREIGN KEY (fk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (fk_disciplina) REFERENCES dim_disciplina(sk_disciplina),
    FOREIGN KEY (fk_turma) REFERENCES dim_turma(sk_turma),
    FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo)
);

CREATE TABLE fato_financeiro (
    sk_fato INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    fk_aluno INT NOT NULL,
    fk_tempo INT NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    parcelas_pagas INT NOT NULL,
    FOREIGN KEY (fk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo)
);

CREATE TABLE fato_frequencia (
    sk_fato INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    fk_aluno INT NOT NULL,
    fk_disciplina INT NOT NULL,
    fk_tempo INT NOT NULL,
    total_faltas INT NOT NULL,
    FOREIGN KEY (fk_aluno) REFERENCES dim_aluno(sk_aluno),
    FOREIGN KEY (fk_disciplina) REFERENCES dim_disciplina(sk_disciplina),
    FOREIGN KEY (fk_tempo) REFERENCES dim_tempo(sk_tempo)
);

INSERT INTO dim_funcionario (nk_id_funcionario, nome_funcionario, cargo, status_funcionario) SELECT  pk_id_funcionario, nome_funcionario, cargo, status_funcionario FROM faculdade_nova_horizonte.tb_funcionarios;
INSERT INTO dim_aluno (nk_rgm, nome_aluno, data_nascimento) SELECT pk_rgm, nome_aluno, data_nascimento FROM faculdade_nova_horizonte.tb_alunos;
INSERT INTO dim_disciplina (nk_id_disciplina, nome_disciplina, carga_horaria, status_disciplina) SELECT pk_id_disciplina, nome_disciplina, carga_horaria, status_disciplina FROM faculdade_nova_horizonte.tb_disciplinas;
INSERT INTO dim_turma (nk_id_turma, nome_turma, ano, semestre, status_turma) SELECT pk_id_turma, nome_turma, ano, semestre, status_turma FROM faculdade_nova_horizonte.tb_turmas;
INSERT INTO dim_tempo (dia, ano, mes, semestre) SELECT DISTINCT data_matricula, YEAR(data_matricula), MONTH(data_matricula), IF(MONTH(data_matricula) <= 6, 1, 2) FROM faculdade_nova_horizonte.tb_matriculas;
INSERT INTO fato_desempenho (
    fk_aluno, 
    fk_disciplina, 
    fk_turma, 
    fk_tempo, 
    nota_p1, 
    nota_p2, 
    nota_af
)
SELECT 
    da.sk_aluno, 
    dd.sk_disciplina, 
    dt.sk_turma, 
    dtempo.sk_tempo,

    n.nota_p1,
    n.nota_p2,

    CASE
        WHEN (n.nota_p1 + n.nota_p2) < 6 AND n.nota_af IS NOT NULL THEN
            (GREATEST(n.nota_p1, n.nota_p2) + n.nota_af) / 2
        ELSE
            (n.nota_p1 + n.nota_p2) / 2
    END

FROM faculdade_nova_horizonte.tb_matriculas m
JOIN dim_aluno da ON da.nk_rgm = m.fk_rgm 
JOIN dim_disciplina dd ON dd.nk_id_disciplina = m.fk_id_disciplina

JOIN dim_turma dt 
    ON dt.nk_id_turma = (
        SELECT t.pk_id_turma
        FROM faculdade_nova_horizonte.tb_turmas t
        WHERE t.fk_id_disciplina = m.fk_id_disciplina
        LIMIT 1
    )

JOIN dim_tempo dtempo ON dtempo.data = m.data_matricula LEFT JOIN faculdade_nova_horizonte.tb_notas n ON n.fk_id_matricula = m.pk_id_matricula;

INSERT INTO fato_financeiro (fk_aluno, fk_tempo, valor_pago, parcelas_pagas)
SELECT
    da.sk_aluno,
    dt.sk_tempo,
    SUM(IF(p.data_pagamento IS NOT NULL, p.valor_parcela, 0)),
    COUNT(p.data_pagamento)

FROM faculdade_nova_horizonte.tb_contratos_educacionais c

JOIN dim_aluno da ON da.nk_rgm = c.fk_rgm
JOIN faculdade_nova_horizonte.tb_parcelas_contrato p ON p.fk_id_contrato = c.pk_id_contrato
JOIN dim_tempo dt ON dt.data = p.data_vencimento
GROUP BY da.sk_aluno, dt.sk_tempo;

INSERT INTO fato_frequencia (fk_aluno, fk_disciplina, fk_tempo, total_faltas)
SELECT
    da.sk_aluno,
    dd.sk_disciplina,
    dt.sk_tempo,
    f.quantidade

FROM faculdade_nova_horizonte.tb_faltas f

JOIN faculdade_nova_horizonte.tb_matriculas m ON m.pk_id_matricula = f.fk_id_matricula
JOIN dim_aluno da ON da.nk_rgm = m.fk_rgm
JOIN dim_disciplina dd ON dd.nk_id_disciplina = m.fk_id_disciplina
JOIN dim_tempo dt ON dt.data = f.data_registro;

UPDATE fato_desempenho
SET status_aprovacao =
    CASE
        WHEN nota_final >= 6 THEN 'APROVADO'
        ELSE 'REPROVADO'
    END;

-- Média por disciplina
SELECT d.nome_disciplina, AVG(f.nota_final) AS media FROM fato_desempenho f JOIN dim_disciplina d ON f.fk_disciplina = d.sk_disciplina
GROUP BY d.nome_disciplina;
-- Receita mensal
SELECT t.mes, SUM(f.valor_pago) AS receita FROM fato_financeiro f JOIN dim_tempo t ON f.fk_tempo = t.sk_tempo
GROUP BY t.mes;
-- Total de faltas por disciplina
SELECT d.nome_disciplina, SUM(f.total_faltas) AS faltas FROM fato_frequencia f JOIN dim_disciplina d ON f.fk_disciplina = d.sk_disciplina
GROUP BY d.nome_disciplina;
-- Alunos reprovados
SELECT * FROM fato_desempenho WHERE status_aprovacao = 'REPROVADO';

describe dim_disciplina;
describe dim_aluno;
describe dim_funcionario;
describe dim_turma;
describe dim_tempo;
describe fato_desempenho;
describe fato_financeiro;
describe fato_frequencia;
