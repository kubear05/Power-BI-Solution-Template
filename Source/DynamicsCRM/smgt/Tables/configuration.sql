CREATE TABLE [Smgt].[configuration] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [configuration_group]    VARCHAR (150) NOT NULL,
    [configuration_subgroup] VARCHAR (150) NOT NULL,
    [name]                   VARCHAR (150) NOT NULL,
    [value]                  VARCHAR (max) NULL,
    [visible]                BIT           NOT NULL DEFAULT 0, 
    CONSTRAINT [pk_configuration] PRIMARY KEY CLUSTERED ([id] ASC)
);

