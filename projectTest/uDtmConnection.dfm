object DtmConnection: TDtmConnection
  OldCreateOrder = False
  Height = 245
  Width = 390
  object ConnectionFirebird: TSQLConnection
    ConnectionName = 'Devart InterBase'
    DriverName = 'DevartInterBase'
    LoginPrompt = False
    Params.Strings = (
      'Database='
      'DriverName=DevartInterBase'
      'User_Name=SYSDBA'
      'Password='
      'RoleName='
      'SQLDialect=1'
      'BlobSize=-1'
      'ErrorResourceFile='
      'LocaleCode=0000'
      'DevartInterBase TransIsolation=ReadCommited'
      'WaitOnLocks=True'
      'ServerCharset=Win1252'
      'CharLength=1'
      'EnableBCD=True'
      'OptimizedNumerics=True'
      'LongStrings=True'
      'UseQuoteChar=False'
      'FetchAll=False'
      'UseUnicode=False'
      'Trim Char=True'
      'DeferredBlobRead=False'
      'DeferredArrayRead=False'
      'TrimFixedChar=True'
      'TrimVarChar=True')
    Left = 46
    Top = 24
  end
  object ConnectionPostgres: TSQLConnection
    ConnectionName = 'Devart PostgreSQL'
    DriverName = 'DevartPostgreSQL'
    LoginPrompt = False
    Params.Strings = (
      'HostName='
      'DataBase='
      'User_Name=postgres'
      'Password='
      'SchemaName=public'
      'BlobSize=-1'
      'DriverName=DevartPostgreSQL'
      'FetchAll=False'
      'UseQuoteChar=False'
      'EnableBCD=True'
      'IPVersion=IPv4'
      'UseUnicode=False'
      'Charset=Win1252'
      'TrimFixedChar=True'
      'TrimVarChar=True'
      '')
    Left = 46
    Top = 80
  end
end
