/*    ==Scripting Parameters==

    Source Database Engine Edition : Microsoft Azure SQL Database Edition
    Source Database Engine Type : Microsoft Azure SQL Database

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [master]
GO
/****** Object:  Database [Conduit]    Script Date: 8/26/2017 10:35:27 PM ******/
CREATE DATABASE [Conduit]
GO
ALTER DATABASE [Conduit] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Conduit].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Conduit] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Conduit] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Conduit] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Conduit] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Conduit] SET ARITHABORT OFF 
GO
ALTER DATABASE [Conduit] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Conduit] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Conduit] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Conduit] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Conduit] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Conduit] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Conduit] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Conduit] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Conduit] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Conduit] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Conduit] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [Conduit] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Conduit] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [Conduit] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Conduit] SET  MULTI_USER 
GO
ALTER DATABASE [Conduit] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Conduit] SET ENCRYPTION ON
GO
ALTER DATABASE [Conduit] SET QUERY_STORE = ON
GO
ALTER DATABASE [Conduit] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 7), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 10, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO)
GO
USE [Conduit]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Conduit]
GO
/****** Object:  UserDefinedTableType [dbo].[TagList]    Script Date: 8/26/2017 10:35:28 PM ******/
CREATE TYPE [dbo].[TagList] AS TABLE(
	[Tag] [nvarchar](250) NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[SplitInts]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitInts]
(
   @List      VARCHAR(MAX),
   @Delimiter VARCHAR(255)
)
RETURNS TABLE
AS
  RETURN ( SELECT Item = CONVERT(INT, Item) FROM
      ( SELECT Item = x.i.value('(./text())[1]', 'varchar(max)')
        FROM ( SELECT [XML] = CONVERT(XML, '<i>'
        + REPLACE(@List, @Delimiter, '</i><i>') + '</i>').query('.')
          ) AS a CROSS APPLY [XML].nodes('i') AS x(i) ) AS y
      WHERE Item IS NOT NULL
  );
GO
/****** Object:  UserDefinedFunction [dbo].[SplitNVarchars]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitNVarchars]
(
   @List      VARCHAR(MAX),
   @Delimiter VARCHAR(255)
)
RETURNS TABLE
AS
  RETURN ( SELECT Item = CONVERT(NVarchar(max), Item) FROM
      ( SELECT Item = x.i.value('(./text())[1]', 'varchar(max)')
        FROM ( SELECT [XML] = CONVERT(XML, '<i>'
        + REPLACE(@List, @Delimiter, '</i><i>') + '</i>').query('.')
          ) AS a CROSS APPLY [XML].nodes('i') AS x(i) ) AS y
      WHERE Item IS NOT NULL
  );
GO
/****** Object:  Table [dbo].[Articles]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Slug] [nvarchar](250) NOT NULL,
	[Title] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](250) NOT NULL,
	[Body] [nvarchar](max) NOT NULL,
	[Created] [datetime] NOT NULL,
	[Updated] [datetime] NULL,
	[Author] [int] NOT NULL,
 CONSTRAINT [PK_Articles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
/****** Object:  Table [dbo].[ArticleTags]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticleTags](
	[ArticleId] [int] NOT NULL,
	[TagId] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[updatedAt] [datetime] NULL,
	[body] [nvarchar](max) NOT NULL,
	[ArticleId] [int] NOT NULL,
	[Author] [int] NOT NULL,
 CONSTRAINT [PK_comments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
/****** Object:  Table [dbo].[FavoritedArticles]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FavoritedArticles](
	[ArticleId] [int] NOT NULL,
	[UserId] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[Followings]    Script Date: 8/26/2017 10:35:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Followings](
	[FollowingId] [int] NOT NULL,
	[FollowerId] [int] NOT NULL
)
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 8/26/2017 10:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Tag] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
/****** Object:  Table [dbo].[Users]    Script Date: 8/26/2017 10:35:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[Token] [varchar](250) NOT NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[Bio] [nvarchar](max) NULL,
	[Image] [nvarchar](250) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Slug]    Script Date: 8/26/2017 10:35:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Slug] ON [dbo].[Articles]
(
	[Slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_Followings]    Script Date: 8/26/2017 10:35:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Followings] ON [dbo].[Followings]
(
	[FollowingId] ASC,
	[FollowerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Tag]    Script Date: 8/26/2017 10:35:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tag] ON [dbo].[Tags]
(
	[Tag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Email]    Script Date: 8/26/2017 10:35:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Email] ON [dbo].[Users]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserName]    Script Date: 8/26/2017 10:35:29 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserName] ON [dbo].[Users]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER TABLE [dbo].[Articles]  WITH NOCHECK ADD  CONSTRAINT [FK_Articles_Users] FOREIGN KEY([Author])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Articles] CHECK CONSTRAINT [FK_Articles_Users]
GO
ALTER TABLE [dbo].[ArticleTags]  WITH NOCHECK ADD  CONSTRAINT [FK_ArticleTags_Articles] FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([Id])
GO
ALTER TABLE [dbo].[ArticleTags] CHECK CONSTRAINT [FK_ArticleTags_Articles]
GO
ALTER TABLE [dbo].[ArticleTags]  WITH NOCHECK ADD  CONSTRAINT [FK_ArticleTags_Tags] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([Id])
GO
ALTER TABLE [dbo].[ArticleTags] CHECK CONSTRAINT [FK_ArticleTags_Tags]
GO
ALTER TABLE [dbo].[Comments]  WITH NOCHECK ADD  CONSTRAINT [FK_Comments_Articles] FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([Id])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Articles]
GO
ALTER TABLE [dbo].[Comments]  WITH NOCHECK ADD  CONSTRAINT [FK_Comments_Users] FOREIGN KEY([Author])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_Users]
GO
ALTER TABLE [dbo].[FavoritedArticles]  WITH NOCHECK ADD  CONSTRAINT [FK_FavoritedArticles_Articles] FOREIGN KEY([ArticleId])
REFERENCES [dbo].[Articles] ([Id])
GO
ALTER TABLE [dbo].[FavoritedArticles] CHECK CONSTRAINT [FK_FavoritedArticles_Articles]
GO
ALTER TABLE [dbo].[FavoritedArticles]  WITH NOCHECK ADD  CONSTRAINT [FK_FavoritedArticles_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[FavoritedArticles] CHECK CONSTRAINT [FK_FavoritedArticles_Users]
GO
ALTER TABLE [dbo].[Followings]  WITH NOCHECK ADD  CONSTRAINT [FK_Followings_Users] FOREIGN KEY([FollowerId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Followings] CHECK CONSTRAINT [FK_Followings_Users]
GO
ALTER TABLE [dbo].[Followings]  WITH NOCHECK ADD  CONSTRAINT [FK_Followings_Users1] FOREIGN KEY([FollowingId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Followings] CHECK CONSTRAINT [FK_Followings_Users1]
GO
USE [master]
GO
ALTER DATABASE [Conduit] SET  READ_WRITE 
GO
