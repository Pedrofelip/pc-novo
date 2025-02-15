DECLARE @REFE NVARCHAR(50);
SET @REFE = '09/2023' ;



SELECT DISTINCT  
ASS.CPF
, CASE WHEN CHARINDEX(' ', LTRIM(RTRIM(ASS.NOME_TITULAR))) > 0 THEN LEFT(ASS.NOME_TITULAR, CHARINDEX(' ', LTRIM(RTRIM(ASS.NOME_TITULAR))) - 1) ELSE ASS.NOME_TITULAR END AS [Primeiro Nome],                         ASS.EMAIL
, CASE WHEN ASS.DT_FILIACAO IS NULL THEN ASS.DT_INCLUSAO ELSE ASS.DT_FILIACAO END AS Data_filiacao
,(SELECT COUNT(AL.[ID]) AS TOTAL FROM [INTRANET_ANAJUSTRA].[dbo].[acoes_lancamento] AL INNER JOIN [INTRANET_ANAJUSTRA].[dbo].associados_completo A ON AL.ID_ASSOCIADO = A.PK_ANJ_ASSOCIADO  WHERE A.CPF = ASS.CPF) 'Acoes_participa'
,(SELECT COUNT (AC.[ID]) AS TOTAL FROM [INTRANET_ANAJUSTRA].[dbo].[acoes] AC WHERE AC.ID NOT IN (SELECT AL.[ID_ACAO] FROM [INTRANET_ANAJUSTRA].[dbo].[acoes_lancamento] AL INNER JOIN [INTRANET_ANAJUSTRA].[dbo].associados_completo A ON AL.ID_ASSOCIADO = A.PK_ANJ_ASSOCIADO WHERE A.CPF = ASS.CPF) AND  AC.ATIVAR =  1 AND AC.EXIBIR = 1) 'Acoes_nao_participa'
,(SELECT COUNT(AL.[ID]) AS TOTAL FROM [INTRANET_ANAJUSTRA].[dbo].[acoes_lancamento] AL INNER JOIN [INTRANET_ANAJUSTRA].[dbo].associados_completo A ON AL.ID_ASSOCIADO = A.PK_ANJ_ASSOCIADO  WHERE A.CPF = ASS.CPF AND AL.PAG_DATAREGISTRO LIKE '%' + @REFE + '' ) 'Acoes_ingresso_mes'

,format(cast( replace(RRA.[VALOR_PAGAMENTO],',','.') as decimal(18,6)), 'C', 'pt-br') 'RRA_valor_recebido'
,RRA.[DATA DO PAGAMENTO] 'RRA_data_deposito'
,RRA.[INSTITUI��O FINANCEIRA] 'RRA_banco_pagador'

,format(cast( replace(PSS.[VALOR_PAGAMENTO],',','.') as decimal(18,6)), 'C', 'pt-br') 'PSS_valor_recebido'
,PSS.[DATA DO PAGAMENTO] 'PSS_data_deposito'
,PSS.[INSTITUI��O FINANCEIRA] 'PSS_banco_pagador'

,format(cast( replace(QUI.[VALOR_PAGAMENTO],',','.') as decimal(18,6)), 'C', 'pt-br') 'QUINTOS_valor_recebido'
,QUI.[DATA DO PAGAMENTO] 'QUINTOS_data_deposito'
,QUI.[INSTITUI��O FINANCEIRA] 'QUINTOS_banco_pagador'

,format(cast( replace(URV.[VALOR_PAGAMENTO],',','.') as decimal(18,6)), 'C', 'pt-br') 'URV_valor_recebido'
,URV.[DATA DO PAGAMENTO] 'URV_data_deposito'
,URV.[INSTITUI��O FINANCEIRA] 'URV_banco_pagador'

,'' ACOES_DECISOES_FAVORAVEIS
,DECL.TOTAL 'Conv_N_DECLARACOES_ EMITIDAS'
,DECL.CONVENIO 'Conv_lista_desconto'
,CLET.[VEICULO] 'Conv_VEICULO_CHEVROLET'
,format(cast( replace(replace(replace(CLET.DESCONTO,'R$',''),' ',''),',','.') as decimal(18,6)), 'C', 'pt-br') 'Conv_DESCONTO_CHEVROLET'


,(SELECT TOP 1 TOTAL  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN( 'AUTOMOVEL','AUTO') AND CPF = ASS.CPF AND REFERENCIA = @REFE) 'Corretora_N_apolice_auto'
,(SELECT TOP 1 SEGURADORAS  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN( 'AUTOMOVEL','AUTO') AND CPF = ASS.CPF AND REFERENCIA = @REFE )  'CORR_SEGURADORA_AUTO'

,(SELECT TOP 1 TOTAL  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN(  'RESIDENCIA','RESIDENCIAL') AND CPF = ASS.CPF AND REFERENCIA = @REFE) 'Corretora_N_apolice_residencial'
,(SELECT TOP 1 SEGURADORAS  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN( 'RESIDENCIA','RESIDENCIAL') AND CPF = ASS.CPF AND REFERENCIA = @REFE )  'CORR_SEGURADORA_RESID'

,(SELECT TOP 1 TOTAL  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN('VIDA') AND CPF = ASS.CPF AND REFERENCIA = @REFE) 'Corretora_N_apolice_vida'
,(SELECT TOP 1 SEGURADORAS  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_APOLICES WHERE [RAMO] IN('VIDA') AND CPF = ASS.CPF AND REFERENCIA = @REFE )  'CORR_SEGURADORA_VIDA'

,format(cast( replace((SELECT SUM(CAST(REPLACE(PREMIO_LIQUIDO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('AUTOMOVEL','AUTO') AND CPF = ASS.CPF  AND REFERENCIA = @REFE  AND PREMIO_LIQUIDO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br')  'CORR_LIQUIDO_AUTO'
,format(cast( replace((SELECT SUM(CAST(REPLACE(SEGURO_VAREJO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('AUTOMOVEL','AUTO') AND CPF = ASS.CPF AND REFERENCIA = @REFE AND SEGURO_VAREJO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_VAREJO_AUTO'
,format(cast( replace((SELECT SUM(CAST(REPLACE(ECONOMIA,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('AUTOMOVEL','AUTO') AND CPF = ASS.CPF  AND REFERENCIA = @REFE AND ECONOMIA IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_ECONOMIA_AUTO'

,format(cast( replace((SELECT SUM(CAST(REPLACE(PREMIO_LIQUIDO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('RESIDENCIA','RESIDENCIAL') AND CPF = ASS.CPF  AND REFERENCIA = @REFE AND PREMIO_LIQUIDO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br')  'CORR_LIQUIDO_RESID'
,format(cast( replace((SELECT SUM(CAST(REPLACE(SEGURO_VAREJO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('RESIDENCIA','RESIDENCIAL') AND CPF = ASS.CPF AND REFERENCIA = @REFE AND SEGURO_VAREJO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_VAREJO_RESID'
,format(cast( replace((SELECT SUM(CAST(REPLACE(ECONOMIA,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] IN ('RESIDENCIA','RESIDENCIAL') AND CPF = ASS.CPF   AND REFERENCIA = @REFE AND ECONOMIA IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_ECONOMIA_RESID'

,format(cast( replace((SELECT SUM(CAST(REPLACE(PREMIO_LIQUIDO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] = 'VIDA' AND CPF = ASS.CPF AND REFERENCIA = @REFE  AND PREMIO_LIQUIDO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_LIQUIDO_VIDA'
,format(cast( replace((SELECT SUM(CAST(REPLACE(SEGURO_VAREJO,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] = 'VIDA' AND CPF = ASS.CPF  AND REFERENCIA = @REFE  AND SEGURO_VAREJO IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br') 'CORR_VAREJO_VIDA'
,format(cast( replace((SELECT SUM(CAST(REPLACE(ECONOMIA,',','.') AS DECIMAL(18, 6))) FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA] WHERE [RAMO] = 'VIDA' AND CPF = ASS.CPF  AND REFERENCIA = @REFE  AND ECONOMIA IS NOT NULL),',','.') as decimal(18,6)), 'C', 'pt-br')  'CORR_ECONOMIA_VIDA'

,'' CORR_NUM_DEPENDENTES
,(SELECT COUNT([CPF]) TOTAL  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[CONSIGNADO_PORTABILIDADE] WHERE CPF = ASS.CPF  AND REFERENCIA = @REFE) 'Consignado_N_contrato'
,format(cast( replace((SELECT SUM(CAST(REPLACE(ECONOMIA_MENSAL,',','.') AS DECIMAL(10, 4)))  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[CONSIGNADO_PORTABILIDADE] WHERE CPF = ASS.CPF  AND REFERENCIA = @REFE),',','.') as decimal(18,6)), 'C', 'pt-br') 'Consignado_Economia_mensal_portabilidade'
,format(cast( replace((SELECT SUM(CAST(REPLACE(ECONOMIA_TOTAL,',','.') AS DECIMAL(10, 4)))   FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[CONSIGNADO_PORTABILIDADE] WHERE CPF = ASS.CPF  AND REFERENCIA = @REFE),',','.') as decimal(18,6)), 'C', 'pt-br') 'Consignado_Economia_total_portabilidade'
,(SELECT TOTAL  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_CONSIGNADO_NOVO]  WHERE CPF = ASS.CPF  AND REFERENCIA = @REFE) CONS_QTDE_CONTRATOS_NOVO
,(SELECT CONTRATOS FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_CONSIGNADO_NOVO] WHERE CPF = ASS.CPF  AND REFERENCIA = @REFE) 'CONS_COD_CONTRATO_NOVO'
,'' CONS_TAXA_NEGOCIADA_NOVO
,(SELECT OPERADORAS  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VW_SEGURADORAS_PLANO_SAUDE WHERE CPF = ASS.CPF AND REFERENCIA = @REFE) 'Saude_operadora'
,'' SAUDE_TIPO_PLANO
,'' SAUDE_QTDE_DEPENDENTES
,'' SAUDE_ECONOMIA_REAIS
,'' SAUDE_ECONOMIA_PORC
,CASE
    WHEN PD.CPF IS NULL THEN 'N�O'
    ELSE 'SIM'
END AS DENTAL_UNI
,'' AMIL_TIPO_PLANO
,'' AMIL_QTDE_DEPENDENTES
,'' AMIL_ECONOMIA_REAIS
,'' AMIL_ECONOMIA_PORC
,'' FINAN_QTDE_CHAMADOS
,'' PARLA_QTDE_CHAMADOS
,'' CALL_QTDE_LIGACOES
,'' CALL_QTDE_WHATSAPP
,CASE
         WHEN IG.NOME_INDICADO IS NULL THEN 'N�O'
         ELSE 'SIM'
       END AS INDIQUE_GANHE
,IG.NOME_INDICADO
,CASE
    WHEN AGP.[NOME] IS NULL THEN 'N�O'
    ELSE 'SIM'
END AS AGILIZA_PRECATORIOS
,CASE
    WHEN AGP.[NOME] IS NULL THEN 'N�O'
    ELSE 'SIM'
END AS AGILIZA_PRECATORIOS

--,CASE
--    WHEN IRPF.CPF IS NULL THEN 'N�O'
--    ELSE 'SIM'
--END AS CONTATO_IRPF

,@REFE  REFERENCIA
,getdate() DATA_GERACAO
FROM dbo.associados_completo ASS
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VALORES_RRA RRA ON ASS.CPF = RRA.CPF AND  RRA.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VALORES_PSS PSS ON ASS.CPF = PSS.CPF AND  PSS.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VALORES_DIF_QUINTOS QUI ON ASS.CPF = QUI.CPF AND  QUI.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].VALORES_URV URV ON ASS.CPF = URV.CPF AND  URV.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_DECLARACOES_CONVENIOS] DECL ON ASS.CPF = DECL.CPF  AND DECL.REFERENCIA = @REFE 



LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[DECLARACOES_CHEVROLET] CLET ON ASS.CPF = CLET.CPF AND CLET.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_SEGURADORAS_APOLICES] V_AUTO ON ASS.CPF = V_AUTO.CPF AND (V_AUTO.RAMO = 'AUTOMOVEL' OR V_AUTO.RAMO = 'AUTO') AND V_AUTO.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_SEGURADORAS_APOLICES] V_RESI ON ASS.CPF = V_RESI.CPF AND (V_RESI.RAMO = 'RESIDENCIA' OR V_RESI.RAMO = 'RESIDENCIAl')  AND V_RESI.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_SEGURADORAS_APOLICES] V_VIDA ON ASS.CPF = V_VIDA.CPF AND V_VIDA.RAMO = 'VIDA'  AND V_VIDA.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[VW_SEGURADORAS_PLANO_SAUDE] PS ON ASS.CPF = PS.CPF  AND PS.REFERENCIA = @REFE
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].DENTAL_UNI PD ON ASS.CPF = PD.CPF  AND PD.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[INDIQUE_GANHE] IG ON ASS.CPF = IG.CPF  AND IG.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].AGILIZA_PRECATORIOS AGP ON ASS.CPF = AGP.CPF  AND AGP.REFERENCIA = @REFE 
LEFT JOIN [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].CONTATO_IRPF IRPF ON ASS.CPF = IRPF.CPF  AND IRPF.REFERENCIA = @REFE 

LEFT JOIN [INTRANET_ANAJUSTRA].dbo.TB_LOTACAO_NIVEL1 LOT ON LOT.ID = ASS.FK_LOTACAO_NIVEL1
INNER JOIN INTRANET_ANAJUSTRA.INTEGRACAO_SALESFORCE.TB_ASSOCIADOS SF ON REPLACE(REPLACE(ASS.CPF,'-',''),'.','') = SF.CPF__c

WHERE ASS.SINDICALIZADO IN ('S','B')  
AND ASS.EMAIL NOT IN('','********','a@a.com.br','prosaude@anajustra.org.br','naotem@gmail.com','asacinco@hotmail.com','a@gmail.com','naopossui@hotmail.com','a@a.com') 
