s  program  ! парсер ал€ YAML 
            ! dee2019-08-26
            ! dee2019-08-11
            ! dee2019-08-09

  PRAGMA('project(#pragma define(_ABCDllMode_ => 0))')
  PRAGMA('project(#pragma define(_ABCLinkMode_ => 1))')

! —интаксис:
! ѕараметр с начала строки корневой уровень
! √руппа параметров с одним отступом €вл€етс€ вложенной в элемент выше у которого отступ меньше
! обращение к вложенному элементу задаетс€ как: поле1/поле3 получаемое значение = значение3
! управл€ющие символы 
! ƒл€ пол€ значени€: 
!         & и *. Ёти элементы позвол€ют определить ссылку на элемент и затем его использовать.
!         &-группу ниже можно наследовать
!         *-в значение будет группа с указанным именем
!         |-группа будет обьеденена в одну строку (без сохранени€ перевода строки)
!         |binary- base64 строки будет обьеденены в одну строку и декодированы
!         >-группа будет обьеденена в одну строку (с сохранением перевода строки)
!         {-начало Json строки вида {key1: "value1", key2: "value2"}
! ƒл€ всего файла:
!         !-в любом месте комментарий (все что справа игнорируетс€ программой)
!         [..]-(с начала строки) - строки игнорируютс€ программой
!         ---  (с начала строки) - начало документа
!         ...  (с начала строки) - конец документа
!
!поле1 = значение1     !это комментарий
!    поле2 = значение2
!    поле3 = значение3
!это комментарий
!поле4 = значение4
!поле5 = &значение5    !√руппа ƒл€ наследовани€
!    поле6 = значение6
!    поле7 = значение7
!поле8 = значение8
!поле9 = *значение5    !ссылка на наследуюемую группу
!поле10 = значение10
!поле10 = |            !группа будет обьеденена в одну строку ѕример: поле10 = txttxttxttxttxttxt txttxt txttxt txttxttxttxt erte rte ttxttxt txttxt
!    txttxttxttxt
!    txttxt txttxt txttxt txttxt
!    txttxt erte rte t 
!    txttxt txttxt
!
!------тестовый файл-----------
!! City = table
!ID = field
!   type = int 11
!   null = false
!   unique = true
!Name = field
!   type = char 35
!   null = true
!   Rama
!       zalman = true
!       zalman2 = false
!!--------dtetretretretet---------
!   unique = false
!   unique2 = off       !sdfsfsfsdf sdfsf
!     toper
!        siko1 = on
!        siko2 = of
!   unique3 = wite
!City
!  ID = 1
!  Name = \Kabul
!  √руппаƒл€наследовани€ = &basic
!        siko1 = on
!        siko2 = of1  
!        toper
!             zzzz = 555
!        siko2 = of
!        siko3 = of2
!        siko4 = of3
!  Stor = fff
!City
!  ID = 4079
!  Name = \Rafah
!City
!  ID = 23023
!  gruppa =     *basic
!  siko3 = of2_2
!  Name = \Moscow
!TestTXT
!   Blob = |
!     ertetretert
!     etretet rtyry tryut yu
!     rtert erte rte t 
!     ertet etret
!   rine = 45
!M800x600
!  CashrepGetVcode
!     MenuStyle = *MSTempl1
!     MenuScrollStyle = *MSSTempl1
!     MenuTypeID = 2
!     StrJson = {key1: "value1", key2: "value2"} 
!     323224 = 7777
!TestTXT
!   Blob = |binary
!      R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5
!      OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+
!      +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC
!      AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
!
!—писки (последовательности, lists, sequences, collections) представл€ют собой коллекции 
!упор€доченных данных, доступ к которым возможен по их индексам.
!
!bindings
!  - 
!    ircEvent= PRIVMSG 1
!    method= newUri
!    regexp= '^http://.*'
!  - 
!    ircEvent= PRIVMSG 2
!    method= deleteUri 
!    regexp= '^delete.*'
!  - 
!    ircEvent= PRIVMSG 3
!    method= randomUri
!    regexp= '^random.*'
!
!------на будующее--------
!-------------------------

  include('YAMLD.inc')

  map
  end 

YD   &YAMLD
S    string(255)
S2   string(255)
S3   string(255)


  code
  SYSTEM{prop:charset} = CHARSET:CYRILLIC
  SYSTEM{PROP:FONT,1} = 'Microsoft Sans Serif'
  SYSTEM{PROP:FONT,2} = 12
  SYSTEM{PROP:FONT,3} = COLOR:Black
  SYSTEM{PROP:FONT,4} = FONT:thin
  SYSTEM{PROP:FONT,5} = CHARSET:CYRILLIC    
  
  YD &= NEW YAMLD
        
  !---загрузка файла------------
  if YD.YAMLD_init('in_test2.cfg',,,)
     stop('ќшибка')
  else
     S = 'M800X600/CASHREPGETVCODE/MENUSCROLLSTYLE/P4'
     stop(S &'<13,10>'&  clip(YD.YAMLD_Rcommand(S))  )
       
     S = 'TestTXT/Blob'
     stop(S &'<13,10>'&  YD.YAMLD_Rcommand(S)  )    

     YD.YAMLD_Scommand(S,'“ра л€ л€<13,10>пурум пум пум')
     stop(S &'<13,10>'&  YD.YAMLD_Rcommand(S)  )
     
     S = 'M800x600/CashrepGetVcode/StrJson/key2'
     stop(S &'<13,10>'&  YD.YAMLD_Rcommand(S)  )
     
     S = 'TestTXTRF/B64'
     stop(S &'<13,10>'&  YD.YAMLD_Rcommand(S)  )
     
     S = 'bindings4/2/method'
     stop(S &'<13,10>'&  YD.YAMLD_Rcommand(S)  )   
     
     DO GetItemDim
  end 


GetItemDim routine
  !---получить размер индекса в массиве по заданному пути"
  S = 'bindings4/'
  z# = yd.YAMLD_GetIndex(S)
  
  !---обойдем все индексы
  loop i#=1 to z#
       S =  'bindings4/'& i# &'/ircEvent'
       S2 = 'bindings4/'& i# &'/method'
       S3 = 'bindings4/'& i# &'/regexp'
       stop(clip(S)  &' = '&  clip(YD.YAMLD_Rcommand(S))  &'<13,10>'& |
            clip(S2) &' = '&  clip(YD.YAMLD_Rcommand(S2)) &'<13,10>'& |
            clip(S3) &' = '&  clip(YD.YAMLD_Rcommand(S3)) |
           )
  end



