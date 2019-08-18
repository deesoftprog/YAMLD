!-----------------------------
! YAMLD Реализация чтение конфигурации из файла в формате аля YAMLD
! dee2019-08-17
! dee2019-08-11
! dee2019-08-09
!-----------------------------
      include('base64.inc'),ONCE   !BASE64 конвертор

YAMLD_MaxLenFLDFile  EQUATE(1024)  !размер строки в файле
YAMLD_MaxLenFLD      EQUATE(512)   !размер поля для цепочки поиска(имя1/имя2/имя3)
YAMLD_MaxLenFLDValue EQUATE(2048)  !размер поля возвращаемых значений

YAMLD_cfgQ_TYPE     QUEUE,pre(YAMLD_cfgQ_TYPE),THREAD,TYPE  !текст из файла CFG YAML
id                  long                             !номер строки
Indent              long                             !отступов
HeirsParent         long                             !парент наследника ID
Parvalue            STRING(YAMLD_MaxLenFLDFile)      !Значение параметра
Node                string(YAMLD_MaxLenFLD)          !цепочка поиска(имя1/имя2/имя3)
Value               string(YAMLD_MaxLenFLDValue)     !значение параметра
                    end
                   
YAMLD               Class,Type,Module('YAMLD.clw'),Link('YAMLD.clw'),THREAD
YAMLD_cfgQ          &YAMLD_cfgQ_TYPE,protected
YAMLD_SepFld        string(1),protected
YAMLD_Comment       string(1),protected
p_debug             byte,protected
Construct           Procedure(),Private
Destruct            Procedure(),Private
!---Рабочие метолы
YAMLD_Rcommand      Procedure(string _param),string                         !получить значение параметра или ветки
YAMLD_Scommand      Procedure(string _param, string _value),long,proc       !задать значение параметра или ветки RC=1 найден RC=0 не найден
YAMLD_init          procedure(String _InFile,<string _Sep>,<string _SComment>,byte _debug=0),long            !инициализация файла YAML с заданным сепаратором полей
!---Служебные
YAMLD_GetFieldp     Procedure(String Stro, Short Num, String Sep, <Byte QuoteFlag>),String,Private
YAMLD_CfgLoadfile   Procedure(String _InFile),long,Private                  !прочитать файл в формате YAML
YAMLD_CfgDeSerelize Procedure(),long,Private                                !1 этап обработки (получение цепочек вхожденией и данных)
YAMLD_CfgHeirs      Procedure(),long,Private                                !1 этап обработки (обработка наследования)
YAMLD_B64D          Procedure(String _InData),string,Private                !base64 decode
!---отладка
YAMLD_LoggerQ       Procedure(String _Message, *Queue _InQ),Private         !Отладка просмотр Q
YAMLD_xIsType       Procedure(*? _Var),long,Private
YAMLD_xIsDimSize    Procedure(*? _Var),long,Private
                    end

!-------------------
! Синтаксис:
! Параметр с начала строки корневой уровень
! Группа параметров с одним отступом является вложенной в элемент выше у которого отступ меньше
! обращение к вложенному элементу задается как: поле1/поле3 получаемое значение = значение3
! управляющие символы 
! Для поля значения: 
!         & и *. Эти элементы позволяют определить ссылку на элемент и затем его использовать.
!         &-группу ниже можно наследовать
!         *-в значение будет группа с указанным именем
!         |-группа будет обьеденена в одну строку (без сохранения перевода строки)
!         |binary- base64 строки будет обьеденены в одну строку и декодированы
!         >-группа будет обьеденена в одну строку (с сохранением перевода строки)
!         {-начало Json строки вида {key1: "value1", key2: "value2"}
! Для всего файла:
!         !-в любом месте комментарий (все что справа игнорируется программой)
!         [..]-(с начала строки) - строки игнорируются программой
!         ---  (с начала строки) - начало документа
!         ...  (с начала строки) - конец документа
!
!поле1 = значение1     !это комментарий
!    поле2 = значение2
!    поле3 = значение3
!это комментарий
!поле4 = значение4
!поле5 = &значение5    !Группа Для наследования
!    поле6 = значение6
!    поле7 = значение7
!поле8 = значение8
!поле9 = *значение5    !ссылка на наследуюемую группу
!поле10 = значение10
!поле10 = |            !группа будет обьеденена в одну строку Пример: поле10 = txttxttxttxttxttxt txttxt txttxt txttxttxttxt erte rte ttxttxt txttxt
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
!  ГруппаДлянаследования = &basic
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
!TestTXTRF
!   B64 = |binary
!     Ic/u5O/z7eryX+zg8fHo4jogWzEsIDIsIDNdDQ
!     ohDQoh0e/o8eroICjv7vHr5eTu4uDy5ev87e7x
!     8ugsIGxpc3RzLCBzZXF1ZW5jZXMsIGNvbGxlY3
!     Rpb25zKSDv8OXk8fLg4uv//vIg8e7h7ukg6u7r
!     6+Xq9ujoIA0KIfPv7vD/5O735e3t+/Ug5ODt7f
!     v1LCDk7vHy8+8g6iDq7vLu8PvsIOLu5+zu5uXt
!     IO/uIOj1IOjt5OXq8eDsLg0KIWJpbmRpbmdzOg
!     0KISAgLSBpcmNFdmVudDogUFJJVk1TRw0KISAg
!     ICBtZXRob2Q6IG5ld1VyaQ0KISAgICByZWdleH
!     A6ICdeaHR0cDovLy4qJw0KISAgLSBpcmNFdmVu
!     dDogUFJJVk1TRw0KISAgICBtZXRob2Q6IGRlbG
!     V0ZVVyaQ0KISAgICByZWdleHA6ICdeZGVsZXRl
!     LionDQohICAtIGlyY0V2ZW50OiBQUklWTVNHDQ
!     ohICAgIG1ldGhvZDogcmFuZG9tVXJpDQohICAg
!     IHJlZ2V4cDogJ15yYW5kb20uKicNCiEtLS0tLS
!     0tLS0tLS0tLS0tLS0tLS0tLS0t
!M800x600
!  CashrepGetVcode
!     MenuStyle = *MSTempl1
!     MenuScrollStyle = *MSSTempl1
!     MenuTypeID = 2
!     StrJson = {key1: "value1", key2: "value2"} 
!     323224 = 7777
!-------------------
