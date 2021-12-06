use [GRS_users]
go

--##########################################################################
--##########################################################################

-- New records from [temp_users] which are not present in [production_users]
	SELECT * FROM [dbo].[temp_users] WHERE ZEHUT NOT IN (SELECT t.ZEHUT FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT);

	-- Update flag and date for new records - First query is ready!!!
	UPDATE [dbo].[temp_users]
	SET f_appended = 1, f_appended_date = GETDATE()
	WHERE [ZEHUT] NOT IN (SELECT t.ZEHUT FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT);
	go

--check the results
SELECT * FROM [dbo].[temp_users] WHERE f_appended = 1
go


-- Inserting new records
INSERT INTO [dbo].[production_users] SELECT * FROM [dbo].[temp_users]
WHERE f_appended = 1

--check the results
SELECT * FROM [dbo].[production_users] WHERE f_appended = 1
go

-- Inserting action Items for new records
INSERT INTO [dbo].[production_Pending_Actions] 
SELECT [ZEHUT], '1' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users]
WHERE f_appended = 1;

--check action item records
select * from [dbo].[production_Pending_Actions]
go


--##########################################################################
--##########################################################################


-- Cancelled records - Existing records from [production_users] which are not present in [temp_users]
	SELECT * FROM [dbo].[production_users] WHERE ZEHUT NOT IN (SELECT p.ZEHUT FROM [dbo].[production_users] p INNER JOIN [dbo].[temp_users] t ON p.ZEHUT = t.ZEHUT);


	-- Update flag and date for cancelled records - Second query is ready!!!
	UPDATE [dbo].[production_users]
	SET f_cancelled = 1, f_cancelled_date = GETDATE()
	WHERE ([f_cancelled] IS NULL Or [f_cancelled] = 0 ) AND [ZEHUT] NOT IN (SELECT p.ZEHUT FROM [dbo].[production_users] p INNER JOIN [dbo].[temp_users] t ON p.ZEHUT = t.ZEHUT);
	go

--check the results
SELECT * FROM [dbo].[production_users] WHERE f_cancelled = 1
go


--Inserting action Items for cancelled records
	INSERT INTO [dbo].[production_Pending_Actions] 
	SELECT [ZEHUT], '2' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date  FROM [dbo].[production_users] 
	WHERE ZEHUT NOT IN (SELECT p.ZEHUT FROM [dbo].[production_users] p INNER JOIN [dbo].[temp_users] t ON p.ZEHUT = t.ZEHUT);
--check action item records
select * from [dbo].[production_Pending_Actions]
go



--##########################################################################
--##########################################################################

-- 
-- Flag records of personal data update - Third query is ready!!!!
	UPDATE [dbo].[temp_users]  
	SET [f_updated] = 1, [f_updated_date] = GETDATE()
	FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
	WHERE 
t.[ZEHUT_KODEMET] <> p.[ZEHUT_KODEMET] OR 
t.[SUG_ZEHUT]  <> p.[SUG_ZEHUT]  OR 
t.[FAMILY]  <> p.[FAMILY]  OR 
t.[NAME] <> p.[NAME] OR 
t.[ADDRESS] <> p.[ADDRESS] OR 
t.[MIKUD] <> p.[MIKUD] OR 
t.[E_MAIL] <> p.[E_MAIL] OR 
t.[YSHUV] <> p.[YSHUV] OR 
t.[TELEPHON] <> p.[TELEPHON] OR 
t.[KIDOMET] <> p.[KIDOMET] OR 
t.[TELEPHON_SELUL] <> p.[TELEPHON_SELUL] OR 
t.[KIDOMET_SELUL] <> p.[KIDOMET_SELUL] OR 
t.[RISHUM] <> p.[RISHUM] OR 
t.[CHATIMA] <> p.[CHATIMA] OR 
t.[SHANA] <> p.[SHANA] OR 
t.[SEMESTER] <> p.[SEMESTER] OR 
t.[DATE_RISHUM] <> p.[DATE_RISHUM] OR 
t.[HUG_TOAR1] <> p.[HUG_TOAR1] OR 
t.[MEMUZA1] <> p.[MEMUZA1] OR 
t.[HUG_TOAR2] <> p.[HUG_TOAR2] OR 
t.[MEMUZA2] <> p.[MEMUZA2] OR 
t.[MEM_TOAR] <> p.[MEM_TOAR] OR 
t.[HUG_LIMUD1] <> p.[HUG_LIMUD1] OR 
t.[MEMUZA_HUG1] <> p.[MEMUZA_HUG1] OR 
t.[HUG_LIMUD2] <> p.[HUG_LIMUD2] OR 
t.[MEMUZA_HUG2] <> p.[MEMUZA_HUG2] OR 
t.[MOSAD] <> p.[MOSAD] OR 
t.[FACULTA] <> p.[FACULTA] OR 
t.[RAMAT_IVRIT] <> p.[RAMAT_IVRIT] OR 
t.[RAMAT_ANGLIT] <> p.[RAMAT_ANGLIT] OR 
t.[OLD_E_MAIL] <> p.[OLD_E_MAIL] OR 
t.[L_FAMILY] <> p.[L_FAMILY] OR 
t.[LNAME] <> p.[LNAME] OR 
t.[VATIK] <> p.[VATIK]
;
	go

--check the results
SELECT * FROM [dbo].[temp_users] WHERE f_updated = 1
go



-- Performing personal data update - Ready!!!!
UPDATE [dbo].[production_users]  
SET 
[f_updated] = 1, 
[f_updated_date] = GETDATE(),
[ZEHUT_KODEMET]= t.[ZEHUT_KODEMET], 
[SUG_ZEHUT]= t.[SUG_ZEHUT] , 
[FAMILY]= t.[FAMILY] , 
[NAME]= t.[NAME], 
[ADDRESS]= t.[ADDRESS], 
[MIKUD]= t.[MIKUD], 
[E_MAIL]= t.[E_MAIL], 
[YSHUV]= t.[YSHUV], 
[TELEPHON]= t.[TELEPHON], 
[KIDOMET]= t.[KIDOMET], 
[TELEPHON_SELUL]= t.[TELEPHON_SELUL], 
[KIDOMET_SELUL]= t.[KIDOMET_SELUL], 
[RISHUM]= t.[RISHUM], 
[CHATIMA]= t.[CHATIMA], 
[SHANA]= t.[SHANA], 
[SEMESTER]= t.[SEMESTER], 
[DATE_RISHUM]= t.[DATE_RISHUM], 
[HUG_TOAR1]= t.[HUG_TOAR1], 
[MEMUZA1]= t.[MEMUZA1], 
[HUG_TOAR2]= t.[HUG_TOAR2], 
[MEMUZA2]= t.[MEMUZA2], 
[MEM_TOAR]= t.[MEM_TOAR], 
[HUG_LIMUD1]= t.[HUG_LIMUD1], 
[MEMUZA_HUG1]= t.[MEMUZA_HUG1], 
[HUG_LIMUD2]= t.[HUG_LIMUD2], 
[MEMUZA_HUG2]= t.[MEMUZA_HUG2], 
[MOSAD]= t.[MOSAD], 
[FACULTA]= t.[FACULTA], 
[RAMAT_IVRIT]= t.[RAMAT_IVRIT], 
[RAMAT_ANGLIT]= t.[RAMAT_ANGLIT], 
[OLD_E_MAIL]= t.[OLD_E_MAIL], 
[L_FAMILY]= t.[L_FAMILY], 
[LNAME]= t.[LNAME], 
[VATIK]= t.[VATIK]
FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
WHERE t.[f_updated] = 1
;
	go


--check the results
SELECT * FROM [dbo].[production_users] WHERE f_updated = 1
go


-- Inserting action Items for personal data update records
INSERT INTO [dbo].[production_Pending_Actions] 
SELECT [ZEHUT], '3' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users]
WHERE [f_updated] = 1;

--check action item records
select * from [dbo].[production_Pending_Actions]
go






--##########################################################################
--##########################################################################


-- Flag records of registration data update - Forth query is ready!!!! - WRONG RESULTS !!!!!
	UPDATE [dbo].[temp_users]  
	SET [f_regchange] = 1, [f_regchange_date] = GETDATE()
	FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
	WHERE 
t.[A1_MIS_BAKASHA] <> p.[A1_MIS_BAKASHA] OR 
t.[A1_HUG_MEVUKASH] <> p.[A1_HUG_MEVUKASH] OR 
t.[A1_RAMA] <> p.[A1_RAMA] OR 
t.[A1_B_DATE] <> p.[A1_B_DATE] OR 
t.[A1_B_BAKASHA] <> p.[A1_B_BAKASHA] OR 
t.[A2_MIS_BAKASHA] <> p.[A2_MIS_BAKASHA] OR 
t.[A2_HUG_MEVUKASH] <> p.[A2_HUG_MEVUKASH] OR 
t.[A2_RAMA] <> p.[A2_RAMA] OR 
t.[A2_B_DATE] <> p.[A2_B_DATE] OR 
t.[A2_B_BAKASHA] <> p.[A2_B_BAKASHA] OR 
t.[A3_MIS_BAKASHA] <> p.[A3_MIS_BAKASHA] OR 
t.[A3_HUG_MEVUKASH] <> p.[A3_HUG_MEVUKASH] OR 
t.[A3_RAMA] <> p.[A3_RAMA] OR 
t.[A3_B_DATE] <> p.[A3_B_DATE] OR 
t.[A3_B_BAKASHA] <> p.[A3_B_BAKASHA] OR 
t.[A4_MIS_BAKASHA] <> p.[A4_MIS_BAKASHA] OR 
t.[A4_HUG_MEVUKASH] <> p.[A4_HUG_MEVUKASH] OR 
t.[A4_RAMA] <> p.[A4_RAMA] OR 
t.[A4_B_DATE] <> p.[A4_B_DATE] OR 
t.[A4_B_BAKASHA] <> p.[A4_B_BAKASHA] OR 
t.[A5_MIS_BAKASHA] <> p.[A5_MIS_BAKASHA] OR 
t.[A5_HUG_MEVUKASH] <> p.[A5_HUG_MEVUKASH] OR 
t.[A5_RAMA] <> p.[A5_RAMA] OR 
t.[A5_B_DATE] <> p.[A5_B_DATE] OR 
t.[A5_B_BAKASHA] <> p.[A5_B_BAKASHA]
;
	go

--check the results
SELECT * FROM [dbo].[temp_users] WHERE f_regchange = 1
go


-- Performing registration data update - Query is ready!!!!
UPDATE [dbo].[production_users]  
SET 
[f_regchange] = 1, 
[f_regchange_date] = GETDATE(),
[A1_MIS_BAKASHA] = t.[A1_MIS_BAKASHA], 
[A1_HUG_MEVUKASH] = t.[A1_HUG_MEVUKASH], 
[A1_RAMA] = t.[A1_RAMA], 
[A1_B_DATE] = t.[A1_B_DATE], 
[A1_B_BAKASHA] = t.[A1_B_BAKASHA], 
[A2_MIS_BAKASHA] = t.[A2_MIS_BAKASHA], 
[A2_HUG_MEVUKASH] = t.[A2_HUG_MEVUKASH], 
[A2_RAMA] = t.[A2_RAMA], 
[A2_B_DATE] = t.[A2_B_DATE], 
[A2_B_BAKASHA] = t.[A2_B_BAKASHA], 
[A3_MIS_BAKASHA] = t.[A3_MIS_BAKASHA], 
[A3_HUG_MEVUKASH] = t.[A3_HUG_MEVUKASH], 
[A3_RAMA] = t.[A3_RAMA], 
[A3_B_DATE] = t.[A3_B_DATE], 
[A3_B_BAKASHA] = t.[A3_B_BAKASHA], 
[A4_MIS_BAKASHA] = t.[A4_MIS_BAKASHA], 
[A4_HUG_MEVUKASH] = t.[A4_HUG_MEVUKASH], 
[A4_RAMA] = t.[A4_RAMA], 
[A4_B_DATE] = t.[A4_B_DATE], 
[A4_B_BAKASHA] = t.[A4_B_BAKASHA], 
[A5_MIS_BAKASHA] = t.[A5_MIS_BAKASHA], 
[A5_HUG_MEVUKASH] = t.[A5_HUG_MEVUKASH], 
[A5_RAMA] = t.[A5_RAMA], 
[A5_B_DATE] = t.[A5_B_DATE], 
[A5_B_BAKASHA] = t.[A5_B_BAKASHA]
FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
WHERE 
t.[f_regchange] = 1
;
	go

--check the results
SELECT * FROM [dbo].[production_users] WHERE f_regchange = 1
go







-- Inserting action Items for registration data update records
INSERT INTO [dbo].[production_Pending_Actions] 
SELECT [ZEHUT], '4' as ACTION_TYPE_ID,Null as ACTION_RESULT_ID, Null as f_performed, Null as f_performed_date FROM [dbo].[temp_users]
WHERE [f_regchange] = 1;

--check action item records
select * from [dbo].[production_Pending_Actions]
go






-- compare records with regchange flag

SELECT * FROM [dbo].[temp_users] WHERE f_regchange = 1
go

SELECT * FROM [dbo].[production_users] p 
where
p.ZEHUT in
(SELECT [ZEHUT] FROM [dbo].[temp_users] WHERE f_regchange = 1)
go





-- refine regchange comparison

	UPDATE [dbo].[temp_users]  
	SET [f_regchange] = 1, [f_regchange_date] = GETDATE()
	FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
	WHERE 
t.[A1_MIS_BAKASHA] <> p.[A1_MIS_BAKASHA] OR 
t.[A1_HUG_MEVUKASH] <> p.[A1_HUG_MEVUKASH] OR 
t.[A1_RAMA] <> p.[A1_RAMA] OR 
t.[A1_B_DATE] <> p.[A1_B_DATE] OR 
t.[A1_B_BAKASHA] <> p.[A1_B_BAKASHA] OR 
t.[A2_MIS_BAKASHA] <> p.[A2_MIS_BAKASHA] OR 
t.[A2_HUG_MEVUKASH] <> p.[A2_HUG_MEVUKASH] OR 
t.[A2_RAMA] <> p.[A2_RAMA] OR 
t.[A2_B_DATE] <> p.[A2_B_DATE] OR 
t.[A2_B_BAKASHA] <> p.[A2_B_BAKASHA] OR 
t.[A3_MIS_BAKASHA] <> p.[A3_MIS_BAKASHA] OR 
t.[A3_HUG_MEVUKASH] <> p.[A3_HUG_MEVUKASH] OR 
t.[A3_RAMA] <> p.[A3_RAMA] OR 
t.[A3_B_DATE] <> p.[A3_B_DATE] OR 
t.[A3_B_BAKASHA] <> p.[A3_B_BAKASHA] OR 
t.[A4_MIS_BAKASHA] <> p.[A4_MIS_BAKASHA] OR 
t.[A4_HUG_MEVUKASH] <> p.[A4_HUG_MEVUKASH] OR 
t.[A4_RAMA] <> p.[A4_RAMA] OR 
t.[A4_B_DATE] <> p.[A4_B_DATE] OR 
t.[A4_B_BAKASHA] <> p.[A4_B_BAKASHA] OR 
t.[A5_MIS_BAKASHA] <> p.[A5_MIS_BAKASHA] OR 
t.[A5_HUG_MEVUKASH] <> p.[A5_HUG_MEVUKASH] OR 
t.[A5_RAMA] <> p.[A5_RAMA] OR 
t.[A5_B_DATE] <> p.[A5_B_DATE] OR 
t.[A5_B_BAKASHA] <> p.[A5_B_BAKASHA]
;
	go



	--shortened query

	UPDATE [dbo].[temp_users]  
	SET [f_regchange] = 1, [f_regchange_date] = GETDATE()
	FROM [dbo].[temp_users] t INNER JOIN [dbo].[production_users] p ON t.ZEHUT = p.ZEHUT
	WHERE 
t.[A1_MIS_BAKASHA] <> p.[A1_MIS_BAKASHA] OR 
t.[A1_HUG_MEVUKASH] <> p.[A1_HUG_MEVUKASH] OR 
t.[A2_MIS_BAKASHA] <> p.[A2_MIS_BAKASHA] OR 
t.[A2_HUG_MEVUKASH] <> p.[A2_HUG_MEVUKASH] OR 
t.[A3_MIS_BAKASHA] <> p.[A3_MIS_BAKASHA] OR 
t.[A3_HUG_MEVUKASH] <> p.[A3_HUG_MEVUKASH] OR 
t.[A4_MIS_BAKASHA] <> p.[A4_MIS_BAKASHA] OR 
t.[A4_HUG_MEVUKASH] <> p.[A4_HUG_MEVUKASH] OR 
t.[A5_MIS_BAKASHA] <> p.[A5_MIS_BAKASHA] OR 
t.[A5_HUG_MEVUKASH] <> p.[A5_HUG_MEVUKASH] OR
t.[A1_RAMA] <> p.[A1_RAMA] OR 
t.[A2_RAMA] <> p.[A2_RAMA] OR 
t.[A3_RAMA] <> p.[A3_RAMA] OR 
t.[A4_RAMA] <> p.[A4_RAMA] OR 
t.[A5_RAMA] <> p.[A5_RAMA]
;
	go


	















