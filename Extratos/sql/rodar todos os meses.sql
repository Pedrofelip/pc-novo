

INSERT INTO [EXTRATO_MENSAL].[APOLICES_CORRETORA]
           ([VIGENCIA]
           ,[SEGURADO]
           ,[ASSOCIADO]
           ,[CPF]
           ,[RAMO]
           ,[APOLICE]
           ,[SEGURADORA]
           ,[PREMIO_LIQUIDO]
           ,[SEGURO_VAREJO]
           ,[ECONOMIA]
           ,[REFERENCIA])
SELECT [VIGENCIA]
      ,[SEGURADO]
      ,[ASSOCIADO]
      ,[CPF]
      ,[RAMO]
      ,[APOLICE]
      ,[SEGURADORA]
      ,[PREMIO_LIQUIDO]
      ,[SEGURO_VAREJO]
      ,[ECONOMIA]
      ,'01/2023' [REFERENCIA]
  FROM [INTRANET_ANAJUSTRA].[EXTRATO_MENSAL].[APOLICES_CORRETORA]
  WHERE REFERENCIA = '12/2023' AND convert(date,[VIGENCIA],103) > GETDATE()
  ORDER  BY convert(date,[VIGENCIA],103) ASC

  