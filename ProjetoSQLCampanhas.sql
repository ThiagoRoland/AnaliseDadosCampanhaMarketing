-- 1 - Qual o número total de campanhas de marketing registradas?

-- Fazendo a análise exploratória da primeira tabela cuja informação é requerida
SELECT * FROM campaigns

-- Resposta final (50)
SELECT COUNT(campaign_id) FROM campaigns

-- 2 - Qual é o orçamento total investido, somando todas as campanhas? (2.535.923,78)
SELECT SUM(total_budget) FROM campaigns

-- 3 - Quantos anúncios foram criados para cada plataforma (ex: Facebook, Instagram)?

-- Análise exploratória
SELECT * FROM ads

-- Verificando o número de categorias diferentes nesta coluna (2)
SELECT COUNT(DISTINCT ad_platform) FROM ads

-- Respondendo a pergunta (127 e 73)
SELECT COUNT(ad_platform) FROM ads WHERE ad_platform = 'Facebook'
SELECT COUNT(ad_platform) FROM ads WHERE ad_platform = 'Instagram'

-- 4 - Quais são os diferentes tipos de eventos de anúncio (event_type) e quantas vezes cada um ocorreu?

-- Visualizando a tabela em questão
SELECT * FROM ad_events

-- Calculando os diferentes tipos de evento ocorridos na coluna em questão (6)
SELECT COUNT(DISTINCT event_type) FROM ad_events

-- Calculando quantas vezes cada um ocorreu (12013, 1957, 339812, 2031, 40079, 4108)
SELECT event_type, COUNT(event_id) FROM ad_events GROUP BY event_type;

-- 5 Qual a distribuição de usuários por país?

-- Descobrindo quantos países existem nesta database (10)
SELECT COUNT(DISTINCT country) FROM users

-- Respondendo a pergunta (716, 607, 1000, 377, 823, 946, 490, 512, 1510, 3019)
SELECT country, COUNT(user_id) FROM users GROUP BY country;

-- 6 - Quantos usuários temos em cada faixa etária? (889, 3116, 4137 ,1456, 319 , 83)
SELECT COUNT(user_id), age_group FROM users GROUP BY age_group

-- 7 - Qual campanha teve o maior orçamento individual? (Campanha 20, 98904.66)
SELECT campaign_id, MAX(total_budget) FROM campaigns

-- 8 - Quantos eventos do tipo "Compra" (Purchase) foram registrados no total? (2031)
SELECT event_type, COUNT(event_type) FROM ad_events WHERE event_type = 'Purchase'

-- 9 - Liste todos os anúncios que foram direcionados especificamente para o público feminino. (Foram 83 no total)
SELECT ad_id, target_gender FROM ads WHERE target_gender = 'Female'

-- 10 - Qual é a duração média, em dias, de uma campanha de marketing? (66.04)
SELECT AVG(duration_days) FROM campaigns 

-- 11 - Qual é a taxa de cliques (CTR - Cliques / Impressões) para cada anúncio?  
SELECT ad_id,
    CAST(SUM(CASE WHEN event_type = 'Click' THEN 1 ELSE 0 END) AS REAL) /
    NULLIF(SUM(CASE WHEN event_type = 'Impression' THEN 1 ELSE 0 END), 0) AS CTR
FROM ad_events
GROUP BY ad_id

-- Ordenando pelas maiores taxas de CTR
ORDER BY CTR DESC;

-- 12 - Qual plataforma de anúncio (Facebook ou Instagram) gera o maior número de compras? (Facebook)
SELECT ad.ad_platform, COUNT(ev.event_id) AS total_de_compras
FROM ad_events AS ev
JOIN ads AS ad ON ev.ad_id = ad.ad_id
WHERE ev.event_type = 'Purchase'
GROUP BY ad.ad_platform
ORDER BY total_de_compras DESC;

-- 13 - Quais são os 5 principais interesses (target_interests) dos anúncios que resultaram no maior número de cliques? (news 2400, photography	2381, fashion 2381, art	2002, sports 1591)
SELECT a.target_interests, COUNT(e.event_type) AS total_clicks FROM ad_events AS e
JOIN ads AS a ON a.ad_id = e.ad_id
WHERE e.event_type = 'Click'
GROUP BY a.target_interests
ORDER BY total_clicks DESC LIMIT 5

-- Por desatenção, acabei respondendo a pergunta de forma ligeiramente diferente e em minha primeira solução demonstrei os interesses dos usuários que mais clicam, e não os interesses dos anúncios que geram mais cliques. 
-- Fica o código aqui mesmo, por também poder responder à uma diferente pergunta de negócio. (fitness 1171, health 1118, photography 1108, lifestyle 1087, news 1074)
SELECT u.interests, COUNT(e.event_type) AS total_clicks FROM users AS u
JOIN ad_events AS e ON u.user_id = e.user_id
WHERE e.event_type = 'Click'
GROUP BY u.interests
ORDER BY total_clicks DESC LIMIT 5

-- 14 - Para cada campanha, qual foi o número total de impressões, cliques e compras geradas?

-- Respondendo à pergunta e já demonstrando o número total de interações desejadas, somadas e ordenadas de maior para menor
SELECT c.name,
    SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END) AS total_impressoes,
    SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS total_cliques,
    SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS total_compras,
    COUNT(e.event_type) AS total_eventos
FROM ad_events AS e
JOIN ads AS a ON a.ad_id = e.ad_id
JOIN campaigns AS c ON c.campaign_id = a.campaign_id
GROUP BY c.campaign_id
ORDER BY total_eventos DESC;

-- 15 - Qual é a taxa de conversão (Compras / Cliques) para cada campanha?
SELECT c.campaign_id, 
    CAST(SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS REAL ) / 
    NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END), 0) AS taxa_conversao
FROM ad_events AS e
JOIN ads AS a ON a.ad_id = e.ad_id
JOIN campaigns AS c ON c.campaign_id = a.campaign_id
GROUP BY c.campaign_id
ORDER BY taxa_conversao DESC;

-- 16 - Em qual dia da semana (segunda, terça, etc.) há o maior engajamento geral dos usuários com os anúncios?

-- Primeiramente, dos 400000 eventos que ocorreram, descobrindo quantos foram completamente "passivos", ou seja, não necessariamente geraram engajamento algum por parte dos usuários (339812,
-- sobrando cerca de 60000 que geraram algum engajamento, ou seja, qualquer reação menos Impression)
SELECT event_type FROM ad_events WHERE event_type = 'Impression'

-- Agora, respondendo a pergunta (Monday, segunda-feira)
SELECT day_of_week, COUNT(event_type) AS numero_interacoes
FROM ad_events WHERE event_type != 'Impression'
GROUP BY day_of_week ORDER BY numero_interacoes DESC

-- 17 - Qual é o perfil demográfico (gênero e faixa etária) dos usuários que mais realizam compras? (Male 25-34	471, Male 18-24	363, Female	25-34 288)
SELECT u.user_gender, u.age_group,
    SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS total_compras
FROM users AS u
JOIN ad_events AS e ON u.user_id = e.user_id
GROUP BY u.user_gender, u.age_group
ORDER BY total_compras DESC

-- 18 - Como o tipo de anúncio (Vídeo, Imagem, Stories) impacta a quantidade de "Likes" e "Shares"? (Stories é a categoria com o maior número de likes ou shares, e vídeo é a categoria com menos reações)
SELECT a.ad_type, 
    COUNT(CASE WHEN e.event_type = 'Like' THEN 1 END) AS total_likes,
    COUNT(CASE WHEN e.event_type = 'Share' THEN 1 END) AS total_shares,
    COUNT(e.event_type) AS numero_eventos FROM ads AS a
JOIN ad_events AS e ON a.ad_id = e.ad_id
WHERE e.event_type = 'Like' OR e.event_type = 'Share'
GROUP BY a.ad_type
ORDER BY numero_eventos DESC

-- 19 - Qual é o Custo por Aquisição (CPA - Orçamento Total da Campanha / Total de Compras) para cada campanha?

-- Respondendo a pergunta ordenando pelos menores custos de aquisição, portanto mais "lucrativos"
WITH CampaignCompras AS (
    SELECT
        c.campaign_id,
        COUNT(e.event_type) AS total_compras
    FROM
        campaigns AS c
    JOIN ads AS a ON c.campaign_id = a.campaign_id
    JOIN ad_events AS e ON a.ad_id = e.ad_id
    WHERE e.event_type = 'Purchase'
    GROUP BY c.campaign_id
)
SELECT
    c.campaign_id,
    cc.total_compras,
    c.total_budget / NULLIF(cc.total_compras, 0) AS cpa
FROM campaigns AS c
JOIN CampaignCompras AS cc ON c.campaign_id = cc.campaign_id
ORDER BY cpa ASC;

-- 20 - Qual grupo de interesse (interests) de usuários demonstra maior engajamento (qualquer tipo de evento) durante os fins de semana (sábado e domingo)? (fitness 507, lifestyle	481, news 478)
SELECT
    u.interests,
    COUNT(e.event_id) AS engajamento_no_fds
FROM users AS u
JOIN ad_events AS e ON u.user_id = e.user_id
WHERE e.day_of_week IN ('Saturday', 'Sunday') 
    AND e.event_type != 'Impression'
GROUP BY u.interests 
ORDER BY engajamento_no_fds DESC

-- 21 - Qual período do dia (Manhã, Tarde, Noite) apresenta a maior Taxa de Cliques (CTR = Cliques / Impressões) em todas as campanhas? (Afternoon, período da tarde)
SELECT e.time_of_day,
    CAST(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END) AS REAL) /
    NULLIF(SUM(CASE WHEN e.event_type = 'Impression' THEN 1 ELSE 0 END), 0) AS ctr
FROM ad_events AS e
GROUP BY e.time_of_day
ORDER BY ctr DESC

-- 22 - Qual campanha possui o Custo por Clique (CPC) mais eficiente?  (Campaign_42_Summer, menor custo por clique:	4.96)
SELECT c.name,
    c.total_budget /
    NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END), 0) AS cpc
FROM campaigns AS c
JOIN ads AS a ON c.campaign_id = a.campaign_id
JOIN ad_events AS e ON a.ad_id = e.ad_id
GROUP BY c.name
ORDER BY cpc ASC

-- 23 - Para os anúncios que foram especificamente direcionados ao público "Feminino", qual foi a distribuição real de gênero (Feminino, Masculino, Outro)
-- entre os usuários que efetivamente realizaram uma compra a partir desses anúncios? (Other 0.43, Female 0.43, Male 0.38)

-- Minha query que responderia à pergunta possui um erro de lógica, pois calcula a proporção de compras em anúncios femininos para cada gênero, e não a distribuição de gênero dentro das compras destinadas ao público feminino.
SELECT u.user_gender,
    CAST(COUNT(CASE WHEN a.target_gender = 'Female' AND e.event_type = 'Purchase' THEN 1 END) AS REAL) /
    COUNT(u.user_id) AS porcentagem_compras_anuncios_femininos
FROM users AS u
JOIN ad_events AS e ON u.user_id = e.user_id
JOIN ads AS a ON e.ad_id = a.ad_id
WHERE e.event_type = 'Purchase'
GROUP BY u.user_gender
ORDER BY porcentagem_compras_anuncios_femininos DESC

-- A query fornecida pela IA: (Male	0.51824817518248, Female 0.37347931873479, Other 0.10827250608273)
WITH ComprasDeAnunciosFemininos AS (
    SELECT
        u.user_gender
    FROM users AS u
    JOIN ad_events AS e ON u.user_id = e.user_id
    JOIN ads AS a ON e.ad_id = a.ad_id
    WHERE
        a.target_gender = 'Female'
        AND e.event_type = 'Purchase'
)
SELECT
    user_gender,
    CAST(COUNT(*) AS REAL) / (SELECT COUNT(*) FROM ComprasDeAnunciosFemininos) AS distribuicao_genero
FROM
    ComprasDeAnunciosFemininos
GROUP BY
    user_gender
ORDER BY
    distribuicao_genero DESC;

-- 24 - Qual é a combinação de plataforma (ad_platform) e tipo de anúncio (ad_type) que gera a maior taxa de conversão (Compras / Cliques)? (Facebook - Stories - 0.05519866761837)
SELECT a.ad_platform, a.ad_type, 
    CAST(SUM(CASE WHEN e.event_type = 'Purchase' THEN 1 ELSE 0 END) AS REAL) /
    NULLIF(SUM(CASE WHEN e.event_type = 'Click' THEN 1 ELSE 0 END), 0) AS taxa_conversao
FROM ads AS a
JOIN ad_events AS e ON a.ad_id = e.ad_id
GROUP BY a.ad_platform, a.ad_type
ORDER BY taxa_conversao DESC
