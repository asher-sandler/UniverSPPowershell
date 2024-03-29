use grs_users
go

SELECT  'temp_users_1' AS TablName, [ZEHUT]
      ,[SEMESTER]
      ,[E_MAIL]
      ,[HUG_TOAR1],A1_HUG_MEVUKASH,A2_HUG_MEVUKASH
      ,[HUG_TOAR2]
	  ,f_appended , f_appended_date
	  ,f_updated , f_updated_date
  FROM [grs_users].[dbo].[temp_users_1]

  
SELECT  'temp_users_2' AS TablName, [ZEHUT]
      ,[SEMESTER]
      ,[E_MAIL]
      ,[HUG_TOAR1],A1_HUG_MEVUKASH,A2_HUG_MEVUKASH
      ,[HUG_TOAR2]
	  ,f_appended , f_appended_date
	  ,f_updated , f_updated_date
  FROM [grs_users].[dbo].[temp_users_2]
  
  
  

  SELECT TOP 10 'production_Pending_Actions_1' AS TablName,[ID]
      ,[ZEHUT]
      ,[ACTION_TYPE_ID]
      ,[ACTION_RESULT_ID]
      ,[f_performed]
      ,[f_performed_date]
  FROM [grs_users].[dbo].[production_Pending_Actions_1] 
  Where ZEHUT = '98765431-2' 
  or ZEHUT = '98765431-6'
  or ZEHUT = '98765431-5'
  Order By id Desc


  SELECT TOP 10 'production_Pending_Actions_2' AS TablName,[ID]
      ,[ZEHUT]
      ,[ACTION_TYPE_ID]
      ,[ACTION_RESULT_ID]
      ,[f_performed]
      ,[f_performed_date]
  FROM [grs_users].[dbo].[production_Pending_Actions_2] Order By id Desc


  

  select * from production_HUG

  go