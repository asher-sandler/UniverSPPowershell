USE [grs_users]
GO



/****** Object:  Table [dbo].[temp_users]    Script Date: 10/25/2021 10:29:34 AM ******/
DROP TABLE [dbo].[temp_users_1]
GO

/****** Object:  Table [dbo].[temp_users]    Script Date: 10/25/2021 10:29:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[temp_users_1](
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ZEHUT_KODEMET] [nvarchar](50) NOT NULL,
	[SUG_ZEHUT] [nchar](10) NULL,
	[FAMILY] [nvarchar](50) NULL,
	[NAME] [nvarchar](50) NULL,
	[ADDRESS] [nvarchar](100) NULL,
	[MIKUD] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](100) NULL,
	[YSHUV] [nvarchar](50) NULL,
	[TELEPHON] [nvarchar](50) NULL,
	[KIDOMET] [nvarchar](50) NULL,
	[TELEPHON_SELUL] [nvarchar](50) NULL,
	[KIDOMET_SELUL] [nvarchar](50) NULL,
	[RISHUM] [nchar](10) NULL,
	[CHATIMA] [nchar](10) NULL,
	[SHANA] [nchar](10) NULL,
	[SEMESTER] [nchar](10) NULL,
	[DATE_RISHUM] [datetime] NULL,
	[HUG_TOAR1] [nchar](10) NULL,
	[MEMUZA1] [nchar](10) NULL,
	[HUG_TOAR2] [nchar](10) NULL,
	[MEMUZA2] [nchar](10) NULL,
	[MEM_TOAR] [nchar](10) NULL,
	[HUG_LIMUD1] [nchar](10) NULL,
	[MEMUZA_HUG1] [nchar](10) NULL,
	[HUG_LIMUD2] [nchar](10) NULL,
	[MEMUZA_HUG2] [nchar](10) NULL,
	[MOSAD] [nchar](10) NULL,
	[FACULTA] [nchar](10) NULL,
	[YEAR_LIMUD] [nchar](10) NULL,
	[A1_MIS_BAKASHA] [nchar](10) NULL,
	[A1_HUG_MEVUKASH] [nchar](10) NULL,
	[A1_RAMA] [nchar](10) NULL,
	[A1_B_DATE] [datetime] NULL,
	[A1_B_BAKASHA] [datetime] NULL,
	[A2_MIS_BAKASHA] [nchar](10) NULL,
	[A2_HUG_MEVUKASH] [nchar](10) NULL,
	[A2_RAMA] [nchar](10) NULL,
	[A2_B_DATE] [datetime] NULL,
	[A2_B_BAKASHA] [datetime] NULL,
	[A3_MIS_BAKASHA] [nchar](10) NULL,
	[A3_HUG_MEVUKASH] [nchar](10) NULL,
	[A3_RAMA] [nchar](10) NULL,
	[A3_B_DATE] [datetime] NULL,
	[A3_B_BAKASHA] [datetime] NULL,
	[A4_MIS_BAKASHA] [nchar](10) NULL,
	[A4_HUG_MEVUKASH] [nchar](10) NULL,
	[A4_RAMA] [nchar](10) NULL,
	[A4_B_DATE] [datetime] NULL,
	[A4_B_BAKASHA] [datetime] NULL,
	[A5_MIS_BAKASHA] [nchar](10) NULL,
	[A5_HUG_MEVUKASH] [nchar](10) NULL,
	[A5_RAMA] [nchar](10) NULL,
	[A5_B_DATE] [datetime] NULL,
	[A5_B_BAKASHA] [datetime] NULL,
	[RAMAT_IVRIT] [nchar](10) NULL,
	[RAMAT_ANGLIT] [nchar](10) NULL,
	[OLD_E_MAIL] [nvarchar](100) NULL,
	[L_FAMILY] [nvarchar](50) NULL,
	[LNAME] [nvarchar](50) NULL,
	[VATIK] [nchar](10) NULL,
	[HUL] [nchar](10) NULL,
	[STUDENT_ID] [nvarchar](50) NOT NULL,
	[CC_USERNAME] [nvarchar](50) NULL,
	[f_appended] [bit] NULL,
	[f_appended_date] [datetime] NULL,
	[f_cancelled] [bit] NULL,
	[f_cancelled_date] [datetime] NULL,
	[f_updated] [bit] NULL,
	[f_updated_date] [datetime] NULL,
	[f_regchange] [bit] NULL,
	[f_regchange_date] [datetime] NULL
) ON [PRIMARY]

GO



/****** Object:  Table [dbo].[production_users]    Script Date: 10/25/2021 10:31:42 AM ******/
DROP TABLE [dbo].[production_users_1]
GO

/****** Object:  Table [dbo].[production_users]    Script Date: 10/25/2021 10:31:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[production_users_1](
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ZEHUT_KODEMET] [nvarchar](50) NOT NULL,
	[SUG_ZEHUT] [nchar](10) NULL,
	[FAMILY] [nvarchar](50) NULL,
	[NAME] [nvarchar](50) NULL,
	[ADDRESS] [nvarchar](100) NULL,
	[MIKUD] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](100) NULL,
	[YSHUV] [nvarchar](50) NULL,
	[TELEPHON] [nvarchar](50) NULL,
	[KIDOMET] [nvarchar](50) NULL,
	[TELEPHON_SELUL] [nvarchar](50) NULL,
	[KIDOMET_SELUL] [nvarchar](50) NULL,
	[RISHUM] [nchar](10) NULL,
	[CHATIMA] [nchar](10) NULL,
	[SHANA] [nchar](10) NULL,
	[SEMESTER] [nchar](10) NULL,
	[DATE_RISHUM] [datetime] NULL,
	[HUG_TOAR1] [nchar](10) NULL,
	[MEMUZA1] [nchar](10) NULL,
	[HUG_TOAR2] [nchar](10) NULL,
	[MEMUZA2] [nchar](10) NULL,
	[MEM_TOAR] [nchar](10) NULL,
	[HUG_LIMUD1] [nchar](10) NULL,
	[MEMUZA_HUG1] [nchar](10) NULL,
	[HUG_LIMUD2] [nchar](10) NULL,
	[MEMUZA_HUG2] [nchar](10) NULL,
	[MOSAD] [nchar](10) NULL,
	[FACULTA] [nchar](10) NULL,
	[YEAR_LIMUD] [nchar](10) NULL,
	[A1_MIS_BAKASHA] [nchar](10) NULL,
	[A1_HUG_MEVUKASH] [nchar](10) NULL,
	[A1_RAMA] [nchar](10) NULL,
	[A1_B_DATE] [datetime] NULL,
	[A1_B_BAKASHA] [datetime] NULL,
	[A2_MIS_BAKASHA] [nchar](10) NULL,
	[A2_HUG_MEVUKASH] [nchar](10) NULL,
	[A2_RAMA] [nchar](10) NULL,
	[A2_B_DATE] [datetime] NULL,
	[A2_B_BAKASHA] [datetime] NULL,
	[A3_MIS_BAKASHA] [nchar](10) NULL,
	[A3_HUG_MEVUKASH] [nchar](10) NULL,
	[A3_RAMA] [nchar](10) NULL,
	[A3_B_DATE] [datetime] NULL,
	[A3_B_BAKASHA] [datetime] NULL,
	[A4_MIS_BAKASHA] [nchar](10) NULL,
	[A4_HUG_MEVUKASH] [nchar](10) NULL,
	[A4_RAMA] [nchar](10) NULL,
	[A4_B_DATE] [datetime] NULL,
	[A4_B_BAKASHA] [datetime] NULL,
	[A5_MIS_BAKASHA] [nchar](10) NULL,
	[A5_HUG_MEVUKASH] [nchar](10) NULL,
	[A5_RAMA] [nchar](10) NULL,
	[A5_B_DATE] [datetime] NULL,
	[A5_B_BAKASHA] [datetime] NULL,
	[RAMAT_IVRIT] [nchar](10) NULL,
	[RAMAT_ANGLIT] [nchar](10) NULL,
	[OLD_E_MAIL] [nvarchar](100) NULL,
	[L_FAMILY] [nvarchar](50) NULL,
	[LNAME] [nvarchar](50) NULL,
	[VATIK] [nchar](10) NULL,
	[HUL] [nchar](10) NULL,
	[STUDENT_ID] [nvarchar](50) NOT NULL,
	[CC_USERNAME] [nvarchar](50) NULL,
	[f_appended] [bit] NULL,
	[f_appended_date] [datetime] NULL,
	[f_cancelled] [bit] NULL,
	[f_cancelled_date] [datetime] NULL,
	[f_updated] [bit] NULL,
	[f_updated_date] [datetime] NULL,
	[f_regchange] [bit] NULL,
	[f_regchange_date] [datetime] NULL,
 CONSTRAINT [PK_production_users_1] PRIMARY KEY CLUSTERED 
(
	[ZEHUT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


Insert Into [dbo].[production_users_1] 
	Select * from [dbo].[production_users]

GO

/****** Object:  Table [dbo].[production_Pending_Actions]    Script Date: 10/25/2021 10:38:49 AM ******/
DROP TABLE [dbo].[production_Pending_Actions_1]
GO

/****** Object:  Table [dbo].[production_Pending_Actions]    Script Date: 10/25/2021 10:38:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[production_Pending_Actions_1](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ACTION_TYPE_ID] [nchar](10) NULL,
	[ACTION_RESULT_ID] [nvarchar](150) NULL,
	[f_performed] [bit] NULL,
	[f_performed_date] [datetime] NULL,
 CONSTRAINT [PK_production_Pending_Actions_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

Insert Into [dbo].[production_Pending_Actions_1] 
	Select 	[ZEHUT],
	[ACTION_TYPE_ID],
	[ACTION_RESULT_ID] ,
	[f_performed],
	[f_performed_date]  from [dbo].[production_Pending_Actions]

GO

/****** Object:  Table [dbo].[temp_users]    Script Date: 10/25/2021 10:29:34 AM ******/
DROP TABLE [dbo].[temp_users_2]
GO

/****** Object:  Table [dbo].[temp_users]    Script Date: 10/25/2021 10:29:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[temp_users_2](
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ZEHUT_KODEMET] [nvarchar](50) NOT NULL,
	[SUG_ZEHUT] [nchar](10) NULL,
	[FAMILY] [nvarchar](50) NULL,
	[NAME] [nvarchar](50) NULL,
	[ADDRESS] [nvarchar](100) NULL,
	[MIKUD] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](100) NULL,
	[YSHUV] [nvarchar](50) NULL,
	[TELEPHON] [nvarchar](50) NULL,
	[KIDOMET] [nvarchar](50) NULL,
	[TELEPHON_SELUL] [nvarchar](50) NULL,
	[KIDOMET_SELUL] [nvarchar](50) NULL,
	[RISHUM] [nchar](10) NULL,
	[CHATIMA] [nchar](10) NULL,
	[SHANA] [nchar](10) NULL,
	[SEMESTER] [nchar](10) NULL,
	[DATE_RISHUM] [datetime] NULL,
	[HUG_TOAR1] [nchar](10) NULL,
	[MEMUZA1] [nchar](10) NULL,
	[HUG_TOAR2] [nchar](10) NULL,
	[MEMUZA2] [nchar](10) NULL,
	[MEM_TOAR] [nchar](10) NULL,
	[HUG_LIMUD1] [nchar](10) NULL,
	[MEMUZA_HUG1] [nchar](10) NULL,
	[HUG_LIMUD2] [nchar](10) NULL,
	[MEMUZA_HUG2] [nchar](10) NULL,
	[MOSAD] [nchar](10) NULL,
	[FACULTA] [nchar](10) NULL,
	[YEAR_LIMUD] [nchar](10) NULL,
	[A1_MIS_BAKASHA] [nchar](10) NULL,
	[A1_HUG_MEVUKASH] [nchar](10) NULL,
	[A1_RAMA] [nchar](10) NULL,
	[A1_B_DATE] [datetime] NULL,
	[A1_B_BAKASHA] [datetime] NULL,
	[A2_MIS_BAKASHA] [nchar](10) NULL,
	[A2_HUG_MEVUKASH] [nchar](10) NULL,
	[A2_RAMA] [nchar](10) NULL,
	[A2_B_DATE] [datetime] NULL,
	[A2_B_BAKASHA] [datetime] NULL,
	[A3_MIS_BAKASHA] [nchar](10) NULL,
	[A3_HUG_MEVUKASH] [nchar](10) NULL,
	[A3_RAMA] [nchar](10) NULL,
	[A3_B_DATE] [datetime] NULL,
	[A3_B_BAKASHA] [datetime] NULL,
	[A4_MIS_BAKASHA] [nchar](10) NULL,
	[A4_HUG_MEVUKASH] [nchar](10) NULL,
	[A4_RAMA] [nchar](10) NULL,
	[A4_B_DATE] [datetime] NULL,
	[A4_B_BAKASHA] [datetime] NULL,
	[A5_MIS_BAKASHA] [nchar](10) NULL,
	[A5_HUG_MEVUKASH] [nchar](10) NULL,
	[A5_RAMA] [nchar](10) NULL,
	[A5_B_DATE] [datetime] NULL,
	[A5_B_BAKASHA] [datetime] NULL,
	[RAMAT_IVRIT] [nchar](10) NULL,
	[RAMAT_ANGLIT] [nchar](10) NULL,
	[OLD_E_MAIL] [nvarchar](100) NULL,
	[L_FAMILY] [nvarchar](50) NULL,
	[LNAME] [nvarchar](50) NULL,
	[VATIK] [nchar](10) NULL,
	[HUL] [nchar](10) NULL,
	[STUDENT_ID] [nvarchar](50) NOT NULL,
	[CC_USERNAME] [nvarchar](50) NULL,
	[f_appended] [bit] NULL,
	[f_appended_date] [datetime] NULL,
	[f_cancelled] [bit] NULL,
	[f_cancelled_date] [datetime] NULL,
	[f_updated] [bit] NULL,
	[f_updated_date] [datetime] NULL,
	[f_regchange] [bit] NULL,
	[f_regchange_date] [datetime] NULL
) ON [PRIMARY]

GO



DROP TABLE [dbo].[production_users_2]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[production_users_2](
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ZEHUT_KODEMET] [nvarchar](50) NOT NULL,
	[SUG_ZEHUT] [nchar](10) NULL,
	[FAMILY] [nvarchar](50) NULL,
	[NAME] [nvarchar](50) NULL,
	[ADDRESS] [nvarchar](100) NULL,
	[MIKUD] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](100) NULL,
	[YSHUV] [nvarchar](50) NULL,
	[TELEPHON] [nvarchar](50) NULL,
	[KIDOMET] [nvarchar](50) NULL,
	[TELEPHON_SELUL] [nvarchar](50) NULL,
	[KIDOMET_SELUL] [nvarchar](50) NULL,
	[RISHUM] [nchar](10) NULL,
	[CHATIMA] [nchar](10) NULL,
	[SHANA] [nchar](10) NULL,
	[SEMESTER] [nchar](10) NULL,
	[DATE_RISHUM] [datetime] NULL,
	[HUG_TOAR1] [nchar](10) NULL,
	[MEMUZA1] [nchar](10) NULL,
	[HUG_TOAR2] [nchar](10) NULL,
	[MEMUZA2] [nchar](10) NULL,
	[MEM_TOAR] [nchar](10) NULL,
	[HUG_LIMUD1] [nchar](10) NULL,
	[MEMUZA_HUG1] [nchar](10) NULL,
	[HUG_LIMUD2] [nchar](10) NULL,
	[MEMUZA_HUG2] [nchar](10) NULL,
	[MOSAD] [nchar](10) NULL,
	[FACULTA] [nchar](10) NULL,
	[YEAR_LIMUD] [nchar](10) NULL,
	[A1_MIS_BAKASHA] [nchar](10) NULL,
	[A1_HUG_MEVUKASH] [nchar](10) NULL,
	[A1_RAMA] [nchar](10) NULL,
	[A1_B_DATE] [datetime] NULL,
	[A1_B_BAKASHA] [datetime] NULL,
	[A2_MIS_BAKASHA] [nchar](10) NULL,
	[A2_HUG_MEVUKASH] [nchar](10) NULL,
	[A2_RAMA] [nchar](10) NULL,
	[A2_B_DATE] [datetime] NULL,
	[A2_B_BAKASHA] [datetime] NULL,
	[A3_MIS_BAKASHA] [nchar](10) NULL,
	[A3_HUG_MEVUKASH] [nchar](10) NULL,
	[A3_RAMA] [nchar](10) NULL,
	[A3_B_DATE] [datetime] NULL,
	[A3_B_BAKASHA] [datetime] NULL,
	[A4_MIS_BAKASHA] [nchar](10) NULL,
	[A4_HUG_MEVUKASH] [nchar](10) NULL,
	[A4_RAMA] [nchar](10) NULL,
	[A4_B_DATE] [datetime] NULL,
	[A4_B_BAKASHA] [datetime] NULL,
	[A5_MIS_BAKASHA] [nchar](10) NULL,
	[A5_HUG_MEVUKASH] [nchar](10) NULL,
	[A5_RAMA] [nchar](10) NULL,
	[A5_B_DATE] [datetime] NULL,
	[A5_B_BAKASHA] [datetime] NULL,
	[RAMAT_IVRIT] [nchar](10) NULL,
	[RAMAT_ANGLIT] [nchar](10) NULL,
	[OLD_E_MAIL] [nvarchar](100) NULL,
	[L_FAMILY] [nvarchar](50) NULL,
	[LNAME] [nvarchar](50) NULL,
	[VATIK] [nchar](10) NULL,
	[HUL] [nchar](10) NULL,
	[STUDENT_ID] [nvarchar](50) NOT NULL,
	[CC_USERNAME] [nvarchar](50) NULL,
	[f_appended] [bit] NULL,
	[f_appended_date] [datetime] NULL,
	[f_cancelled] [bit] NULL,
	[f_cancelled_date] [datetime] NULL,
	[f_updated] [bit] NULL,
	[f_updated_date] [datetime] NULL,
	[f_regchange] [bit] NULL,
	[f_regchange_date] [datetime] NULL,
 CONSTRAINT [PK_production_users_2] PRIMARY KEY CLUSTERED 
(
	[ZEHUT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[production_Pending_Actions]    Script Date: 10/25/2021 10:38:49 AM ******/
DROP TABLE [dbo].[production_Pending_Actions_2]
GO

/****** Object:  Table [dbo].[production_Pending_Actions]    Script Date: 10/25/2021 10:38:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[production_Pending_Actions_2](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ZEHUT] [nvarchar](50) NOT NULL,
	[ACTION_TYPE_ID] [nchar](10) NULL,
	[ACTION_RESULT_ID] [nvarchar](150) NULL,
	[f_performed] [bit] NULL,
	[f_performed_date] [datetime] NULL,
 CONSTRAINT [PK_production_Pending_Actions_2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


USE [grs_users]
GO

/****** Object:  View [dbo].[production_users_view]    Script Date: 10/26/2021 8:21:05 AM ******/
DROP VIEW [dbo].[production_users_view_1]
GO

/****** Object:  View [dbo].[production_users_view]    Script Date: 10/26/2021 8:21:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[production_users_view_1] AS
Select
    p.ZEHUT,
    p.L_FAMILY,
    p.LNAME,
	p.FAMILY, 
	p.NAME,
	p.E_MAIL,
	CASE
		WHEN LTRIM(p.TELEPHON) ='' OR LTRIM(p.KIDOMET) =''
			THEN Null
		WHEN p.TELEPHON = '0000000' OR p.KIDOMET = '000'
			THEN Null
		ELSE p.KIDOMET + '-' + p.TELEPHON
	END As PHONE,
	CASE
		WHEN LTRIM(p.TELEPHON_SELUL) ='' OR LTRIM(p.KIDOMET_SELUL) =''
			THEN Null
		WHEN p.KIDOMET_SELUL = '000' OR p.TELEPHON_SELUL = '0000000'
			THEN Null
		ELSE p.KIDOMET_SELUL + '-' + p.TELEPHON_SELUL
	END As MOBILE,
	p.ADDRESS,
	p.MIKUD,
	p.HUL,
	p.STUDENT_ID,
	p.CC_USERNAME,
    p.A1_HUG_MEVUKASH As A1_H,
    p.A2_HUG_MEVUKASH As A2_H,
    p.A3_HUG_MEVUKASH As A3_H,
    p.A4_HUG_MEVUKASH As A4_H,
    p.A5_HUG_MEVUKASH As A5_H,
    h1.EKMD As A1_H_EKMD,
    h2.EKMD As A2_H_EKMD,
    h3.EKMD As A3_H_EKMD,
    h4.EKMD As A4_H_EKMD,
    h5.EKMD As A5_H_EKMD,
	h1.Semester As HUG_SEMESTER,
	y.display_name_internet As YSH
   
From
    production_users_1 p
    Left Join production_HUG h1 On h1.ID = p.A1_HUG_MEVUKASH
    Left Join production_HUG h2 On h2.ID = p.A2_HUG_MEVUKASH
    Left Join production_HUG h3 On h3.ID = p.A3_HUG_MEVUKASH
    Left Join production_HUG h4 On h4.ID = p.A4_HUG_MEVUKASH
    Left Join production_HUG h5 On h5.ID = p.A5_HUG_MEVUKASH
    Left Join production_YSHUV y On y.ID = p.YSHUV;



GO



/****** Object:  View [dbo].[production_users_view]    Script Date: 10/26/2021 8:21:05 AM ******/
DROP VIEW [dbo].[production_users_view_2]
GO

/****** Object:  View [dbo].[production_users_view]    Script Date: 10/26/2021 8:21:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[production_users_view_2] AS
Select
    p.ZEHUT,
    p.L_FAMILY,
    p.LNAME,
	p.FAMILY, 
	p.NAME,
	p.E_MAIL,
	CASE
		WHEN LTRIM(p.TELEPHON) ='' OR LTRIM(p.KIDOMET) =''
			THEN Null
		WHEN p.TELEPHON = '0000000' OR p.KIDOMET = '000'
			THEN Null
		ELSE p.KIDOMET + '-' + p.TELEPHON
	END As PHONE,
	CASE
		WHEN LTRIM(p.TELEPHON_SELUL) ='' OR LTRIM(p.KIDOMET_SELUL) =''
			THEN Null
		WHEN p.KIDOMET_SELUL = '000' OR p.TELEPHON_SELUL = '0000000'
			THEN Null
		ELSE p.KIDOMET_SELUL + '-' + p.TELEPHON_SELUL
	END As MOBILE,
	p.ADDRESS,
	p.MIKUD,
	p.HUL,
	p.STUDENT_ID,
	p.CC_USERNAME,
    p.A1_HUG_MEVUKASH As A1_H,
    p.A2_HUG_MEVUKASH As A2_H,
    p.A3_HUG_MEVUKASH As A3_H,
    p.A4_HUG_MEVUKASH As A4_H,
    p.A5_HUG_MEVUKASH As A5_H,
    h1.EKMD As A1_H_EKMD,
    h2.EKMD As A2_H_EKMD,
    h3.EKMD As A3_H_EKMD,
    h4.EKMD As A4_H_EKMD,
    h5.EKMD As A5_H_EKMD,
	h1.Semester As HUG_SEMESTER,
	y.display_name_internet As YSH
   
From
    production_users_2 p
    Left Join production_HUG h1 On h1.ID = p.A1_HUG_MEVUKASH
    Left Join production_HUG h2 On h2.ID = p.A2_HUG_MEVUKASH
    Left Join production_HUG h3 On h3.ID = p.A3_HUG_MEVUKASH
    Left Join production_HUG h4 On h4.ID = p.A4_HUG_MEVUKASH
    Left Join production_HUG h5 On h5.ID = p.A5_HUG_MEVUKASH
    Left Join production_YSHUV y On y.ID = p.YSHUV;



GO

/*


alter table dbo.production_hug
add DeadLine Date
go

*/



