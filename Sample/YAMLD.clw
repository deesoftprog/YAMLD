!-----------------------------
! YAMLD ���������� ������ ������������ �� ����� � ������� ��� YAMLD
! dee2019-08-26
! dee2019-08-11
! dee2019-08-09
!-----------------------------
   MEMBER
   PRAGMA('project(#pragma link(C%V%ASC%X%%L%.LIB))')
   map
   end
   Include('YAMLD.INC'),ONCE
!****************************************************************************************************
YAMLD.Construct    Procedure()
                   Code
                   self.YAMLD_cfgQ &= new YAMLD_cfgQ_TYPE
                   self.YAMLD_DimQ &= new YAMLD_DimQ_TYPE
                   Return
!****************************************************************************************************
YAMLD.Destruct     Procedure()
                   Code
                   if ~(Self.YAMLD_cfgQ &= null)
                      DISPOSE(Self.YAMLD_cfgQ)
                      Self.YAMLD_cfgQ &= Null
                   end
                   if ~(Self.YAMLD_DimQ &= null)
                      DISPOSE(Self.YAMLD_DimQ)
                      Self.YAMLD_DimQ &= Null
                   end
                   Return
!****************************************************************************************************     
YAMLD.YAMLD_Rcommand  Procedure(string _param)
                   !---�������� �������� ��������� ��� �����
                   code
                   if records(self.YAMLD_cfgQ)
                      self.YAMLD_cfgQ.Node = clip(upper(_param))
                      get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.Node)
                      if errorcode() then clear(self.YAMLD_cfgQ.Value).
                   end
                   return(clip(self.YAMLD_cfgQ.Value))
!****************************************************************************************************
YAMLD.YAMLD_Scommand Procedure(string _param, string _value)
                   !---������ �������� ��������� ��� �����
RetVal             long
                   code     
                   if records(self.YAMLD_cfgQ)
                      self.YAMLD_cfgQ.Node = clip(upper(_param))
                      get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.Node)
                      if errorcode() 
                         clear(self.YAMLD_cfgQ.Value)
                      else
                         self.YAMLD_cfgQ.Value = clip(_value)
                         put(self.YAMLD_cfgQ)
                         RetVal=true
                      end
                   end
                   return(RetVal)
!****************************************************************************************************
YAMLD.YAMLD_init   Procedure(String _InFile,<string _Sep>,<string _SComment>,byte _debug=0)
RetC               long
                   !---������������� ����� YAML
                   code
                   self.p_debug = _debug
                   if omitted(_SComment)
                      self.YAMLD_Comment = '!'
                   else
                      self.YAMLD_Comment = _SComment
                   end
                   if omitted(_Sep) 
                      self.YAMLD_SepFld = '='
                   else
                      self.YAMLD_SepFld = _Sep
                   end
                   retC += self.YAMLD_CfgLoadfile(_InFile)
                   retC += self.YAMLD_CfgDeSerelize()
                   retC += self.YAMLD_CfgHeirs()
                   Return(retC)
!****************************************************************************************************
YAMLD.YAMLD_GetIndex   procedure(string _param)
                   !---�������� ������ ������� ��������� ����� "-"
                   code
                   if records(self.YAMLD_DimQ)
                      self.YAMLD_DimQ.Node = clip(upper(_param))
                      get(self.YAMLD_DimQ,+self.YAMLD_DimQ.Node)
                      if errorcode()
                         clear(self.YAMLD_DimQ.size)
                      else
                      end
                   end
                   return(self.YAMLD_DimQ.size)
!****************************************************************************************************
YAMLD.YAMLD_GetFieldp  Procedure(String Stro, Short Num, String Sep, <Byte QuoteFlag>)
bpoz                SHORT,auto
epoz                SHORT,auto
loc:Str             STRING(size(Stro))       !�������� ������
loc:sep             string(1),auto           !���������
loc:Quote           string('"')              !�������
loc:Quote2          string('''')             !�������
                    CODE
                    if omitted(3)
                       QuoteFlag = 0
                    end
                    if Sep<>''
                       loc:sep=Sep[1:1]
                    else
                       loc:sep=' '
                    end
                    bpoz=1
                    epoz=0
                    loc:Str = ''
                    if Num = 1
                       epoz = InString(loc:sep,Stro,1,bpoz)
                       if epoz = 0
                          loc:Str = Stro
                       else
                          loc:Str = sub(Stro,1,epoz-bpoz)
                       end
                    elsif Num > 1
                       !--- ���� ������ ��������� �����
                       loop
                          epoz = InString(loc:sep,Stro,1,bpoz)
                          if epoz = 0
                             return('')
                          else
                             bpoz = epoz+1
                          end
                          Num -= 1
                          if Num <= 1
                             break
                          end
                       end  ! end loop
                       epoz = InString(loc:sep,Stro,1,bpoz)
                       if epoz = 0
                          loc:Str = sub(Stro,bpoz,len(Stro))
                       else
                          loc:Str = sub(Stro,bpoz,epoz-bpoz)
                       end
                    end
                    case QuoteFlag   ! ���� ������ � �������� (������ �������)
                    of 1   !������� �������
                       if sub(loc:str,1,1) = loc:Quote and sub(loc:str,len(clip(loc:Str)),1) = loc:Quote
                          loc:Str = sub(loc:str,2,len(clip(loc:Str))-2)
                       end
                    of 2   !��������� �������
                       if sub(loc:str,1,1) = loc:Quote2 and sub(loc:str,len(clip(loc:Str)),1) = loc:Quote2
                          loc:Str = sub(loc:str,2,len(clip(loc:Str))-2)
                       end
                    end
                    return(clip(loc:Str))
!****************************************************************************************************
YAMLD.YAMLD_CfgLoadfile  Procedure(String _InFile)                  
                    !---��������� ���� � ������� YAML
RC                  long
FINI_NAME           CSTRING(FILE:MaxFileName),static
FINI                FILE,PRE(FINI),DRIVER('ASCII'),NAME(FINI_NAME)
                       RECORD
RECORD                   STRING(YAMLD_MaxLenFLDFile)
                       end
                    end
SEP_C               EQUATE('[')              !������ ������ � cfg �����
SEP_CE              EQUATE(']')              !����� ������ � cfg �����
SEP_BD              EQUATE('---')            !������ ���������
SEP_ED              EQUATE('...')            !����� ���������
FL_REad             byte
LOCPARAM            STRING(YAMLD_MaxLenFLD)
                    code
                    Fini_Name = clip(_InFile)
                    i#=0
                    OPEN(FINI,0)
                    IF ERRORCODE() then RC=1; RETURN(RC).
                    SET(FINI)
                    LOOP
                        i#+=1    
                        NEXT(FINI)
                        IF ERRORCODE()          then BREAK. !��� ������
                        IF clip(FINI:RECORD)='' then CYCLE. !��� ������ ������
                        IF FINI:RECORD[1]=self.YAMLD_Comment then CYCLE. !��� �����������
                        if FINI:RECORD[1]=SEP_C and SUB(clip(FINI:RECORD),-1,1)=SEP_CE then CYCLE.  !�������� �� ��. ������
                        if FINI:RECORD[1 : 3]=SEP_BD
                           FL_REad=true
                           CYCLE
                        end
                        if FINI:RECORD[1 : 3]=SEP_ED
                           FL_REad=false
                        end
                        if FL_REad=false then CYCLE.
                        !---
                        LOCPARAM = CLIP(FINI:RECORD)
                        if instring(self.YAMLD_Comment,LOCPARAM)
                           !---�������� ������ �������� ��� ����������� (��������� �� ������ ����������)
                           LOCPARAM = self.YAMLD_GetFieldp(CLIP(LOCPARAM),1,self.YAMLD_Comment,0)
                        end
                        if clip(LOCPARAM)='' then CYCLE.    !������ ������ ������
                        !---������� �������
                        j#=0
                        loop j#=1 to size(FINI:RECORD)
                             if val(FINI:RECORD[j#])<>32
                                self.YAMLD_cfgQ.Indent = j#
                                break
                             end
                        end
                        !---    
                        self.YAMLD_cfgQ.id = i#
                        self.YAMLD_cfgQ.Parvalue = left(clip(LOCPARAM))
                        add(self.YAMLD_cfgQ)
                    end
                    CLOSE(FINI)
                    if records(self.YAMLD_cfgQ)=0
                       RC=2
                    end
                    RETURN(RC)
!****************************************************************************************************
YAMLD.YAMLD_CfgDeSerelize Procedure                               
                    !---1 ���� ��������� (��������� ������� ���������� � ������)
fl_root             long
fl_parent           long
fl_Heits            long
fl_MultiStr         long
fl_MultiStrType     byte
fl_json             byte
fl_dim              byte
LastNode            like(self.YAMLD_cfgQ.Node),dim(255)
LastParent          long
LastHeits           long
LastMultiStr        long
LastJson            long
LastDim             long
SEP_D               string(1)
                    MAP
                       GetPathNode(long _parent),string  !�������� ���� ������ ��������
                       isParentHeirs(string _value),long !�������� ��� ����������� ������ ��������  
                       isParentMultiStr(string _value),long !�������� ��� ����������� ������ ��������  
                       isParentJson(string _value),long !�������� ��� ����������� ������ ��������  
                       isParentDim(string _value),long !�������� ��� ����������� ������ ��������  
                    end
Ndx_J               long
                    code
                    if RECORDS(self.YAMLD_cfgQ)
                       SEP_D = self.YAMLD_SepFld
                       fl_root=false
                       fl_parent=0
                       loop Ndx_J=1 to RECORDS(self.YAMLD_cfgQ)
                            get(self.YAMLD_cfgQ,Ndx_J)
                            if self.YAMLD_cfgQ.Indent=1
                               fl_root = true
                               fl_parent=1;     LastParent=1
                               !---
                               fl_Heits=0;      LastHeits=0
                               fl_MultiStr=0;   LastMultiStr=0;   fl_MultiStrType=0
                               fl_json=0;       LastJson=0
                               fl_Dim=0;        LastDim=0
                               !---
                               clear(LastNode)
                            elsif self.YAMLD_cfgQ.Indent>1
                               fl_parent = self.YAMLD_cfgQ.Indent
                            end
                            !---save
                            if fl_root
                               self.YAMLD_cfgQ.Node = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               LastNode[1] = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               LastParent = fl_parent
                               self.YAMLD_cfgQ.Value = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               !---
                               if fl_Heits=0
                                  fl_Heits = isParentHeirs(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                               end 
                               LastHeits = fl_Heits
                               !---
                               if fl_MultiStr=0
                                  fl_MultiStr = isParentMultiStr(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                               end 
                               LastMultiStr = fl_MultiStr
                               !---
                               if fl_Json=0
                                  fl_Json = isParentJson(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                               end 
                               LastJson = fl_Json
                               !---
                               if fl_Dim=0
                                  fl_Dim = isParentDim(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,1,SEP_D,0))))
                               end 
                               LastDim = fl_Dim
                               !---
                               put(self.YAMLD_cfgQ)
                               fl_root = FALSE
                            elsif fl_parent
                               if LastParent <> fl_parent
                                  LastNode[fl_parent] = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                                  if fl_parent=1
                                     self.YAMLD_cfgQ.Node = clip(GetPathNode(LastParent)) 
                                  elsif LastParent > fl_parent      !������� �� child
                                     LastNode[LastParent] = ''
                                     !---
                                     if LastHeits = fl_Heits        !������������ �� ���������� ������ ����������
                                        fl_Heits = 0
                                        LastParent = 0
                                     end
                                     !---
                                     if LastMultiStr = fl_MultiStr  !������������ �� ���������� ������ ����������
                                        fl_MultiStr = 0
                                        LastMultiStr = 0
                                     end
                                     !---
                                     if Lastjson = fl_json          !������������ �� ���������� ������ ����������
                                        fl_json = 0
                                        Lastjson = 0
                                     end
                                     !---
                                     if LastDim = fl_Dim            !������������ �� ���������� ������ ����������
                                        fl_Dim = 0
                                        LastDim = 0
                                     end
                                     !---
                                     self.YAMLD_cfgQ.Node = clip(GetPathNode(fl_parent)) &'/'& self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                                  elsif LastParent < fl_parent      !������� � child
                                     self.YAMLD_cfgQ.Node = clip(GetPathNode(fl_parent)) &'/'& self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                                  end
                                  LastParent = fl_parent
                                  self.YAMLD_cfgQ.Value = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                                  !---
                                  if fl_Heits=0
                                     fl_Heits = isParentHeirs(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                                     LastHeits = fl_Heits
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_Heits
                                  end
                                  !---
                                  if fl_MultiStr=0
                                     fl_MultiStr = isParentMultiStr(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                                     LastMultiStr = fl_MultiStr
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_MultiStr
                                  end
                                  !---
                                  if fl_Json=0
                                     fl_Json = isParentJson(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                                     LastJson = fl_Json
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_Json
                                  end
                                  !---
                                  if fl_Dim=0
                                     fl_Dim = isParentDim(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,1,SEP_D,0))))
                                     LastDim = fl_Dim
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_Dim
                                  end
                                  !---
                               else
                                  LastNode[fl_parent] = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                                  self.YAMLD_cfgQ.Node = clip(GetPathNode(LastParent)) &'/'& self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                                  self.YAMLD_cfgQ.Value = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                                  !---
                                  if fl_Heits=0
                                     fl_Heits = isParentHeirs(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                                     LastHeits = fl_Heits
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_Heits
                                  end 
                                  !---
                                  if fl_MultiStr=0
                                     fl_MultiStr = isParentMultiStr(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0))))
                                     LastMultiStr = fl_MultiStr
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_MultiStr
                                  end 
                                  !---��� json ������ �����������
                                  !---
                                  if fl_Dim=0
                                     fl_Dim = isParentDim(clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,1,SEP_D,0))))
                                     LastDim = fl_Dim
                                  else
                                     self.YAMLD_cfgQ.HeirsParent = fl_Dim
                                  end 
                                  !---
                               end
                               put(self.YAMLD_cfgQ)
                            end
                       end
                    end
                    return(0)
  
GetPathNode         procedure(long _parent)   !�������� ���� ������ ��������
RetS                string(YAMLD_MaxLenFLD)
Ndx_i               long
                    code
                    LOOP Ndx_i=1 to maximum(LastNode,1)
                         if ~(Ndx_i < _parent or _parent=1) then break.
                         if clip(LastNode[Ndx_i])<>''
                            if clip(RetS)<>''
                               RetS = clip(RetS) &'/'& clip(LastNode[Ndx_i])
                            else
                               RetS = clip(LastNode[Ndx_i])
                            end
                         end
                    end
                    return(RetS)
  
isParentHeirs       PROCEDURE(string _value) !�������� ��� ����������� ������ �������� 
TmpS                string(YAMLD_MaxLenFLD)
RetI                long
                    code
                    TmpS = _value
                    if val(TmpS[1 : 1]) = 38 !'&'
                       RetI = self.YAMLD_cfgQ.id
                    end
                    return(RetI)
  
isParentMultiStr    PROCEDURE(string _value) !�������� ��� ����������� ������ �������� 
TmpS                string(YAMLD_MaxLenFLD)
RetI                long
                    code
                    TmpS = _value
                    case val(TmpS[1 : 1]) 
                    of 124 !'|'
                       RetI = self.YAMLD_cfgQ.id
                       fl_MultiStrType=1    !��� ���������� ��������� �����
                    of 62  !'>'
                       RetI = self.YAMLD_cfgQ.id
                       fl_MultiStrType=2    !c ����������� ��������� �����
                    end
                    return(RetI)
                    
isParentJson        PROCEDURE(string _value) !�������� ��� ����������� ������ �������� 
TmpS                string(YAMLD_MaxLenFLD)
RetI                long
PozE                long
                    code
                    TmpS = _value
                    PozE = len(clip(TmpS))
                    if PozE=0
                       return(0)
                    end
                    if val(TmpS[1 : 1]) = 123  and |
                       val(TmpS[PozE : PozE]) = 125  !'{ }'
                       RetI = self.YAMLD_cfgQ.id
                    end
                    return(RetI)
                    
isParentDim         PROCEDURE(string _value) !�������� ��� ����������� ������ �������� 
TmpS                string(YAMLD_MaxLenFLD)
RetI                long
                    code
                    TmpS = _value
                    if val(TmpS[1 : 1]) = 45 !'-'
                       RetI = self.YAMLD_cfgQ.id
                    end
                    return(RetI)
!****************************************************************************************************
YAMLD.YAMLD_CfgHeirs Procedure                                
                    !---2 ���� ��������� (��������� ������������)
SEP_D               string(1)
Temp_cfgQ           QUEUE(self.YAMLD_cfgQ),pre(tcfgq1)
                    end
Rec_cfgQ            group(self.YAMLD_cfgQ),pre(tcfgq2)
                    end
Temp_ParentQ        QUEUE
Type                   byte          !1-������ 2-�������� 3-���������� 4-json 5-Dim
MultiLineType          byte          !1-(���������� ��� ���������� �������� �����) 2-� �����������
Format                 byte          !0-txt 1-Base64
HeirsParent            long          !������ ���������� ID
id                     long          !�����
Parvalue               string(YAMLD_MaxLenFLD)   !��� ������������� ��������
Value                  string(YAMLD_MaxLenFLD)   !��� ������
                    end
QKeyPar             QUEUE
sKey                   string(50)              !��� ���������
sValue                 string(YAMLD_MaxLenFLD) !��������
                    end
Loc:KeyWord         string(50)
Loc:KeyValue        string(YAMLD_MaxLenFLD)
StrIn               string(YAMLD_MaxLenFLDValue)
FindValue           string(YAMLD_MaxLenFLD)
FindHeirsParent     long
SaveNode            like(self.YAMLD_cfgQ.Node)
SaveIndent          long
Ndx_J               long
Ndx_J2              long
Ndx_J3              long
Ndx_J4              long
Flfind              byte
FlEnim              long
                    code
                    SEP_D = self.YAMLD_SepFld
                    loop Ndx_J=1 to records(self.YAMLD_cfgQ)
                         get(self.YAMLD_cfgQ,Ndx_J)
                         if self.YAMLD_cfgQ.HeirsParent
                            !---������ ���������
                            clear(Temp_ParentQ)
                            Temp_ParentQ.HeirsParent = self.YAMLD_cfgQ.HeirsParent
                            get(Temp_ParentQ,+Temp_ParentQ.HeirsParent)
                            if errorcode()
                               Temp_ParentQ.HeirsParent = self.YAMLD_cfgQ.HeirsParent
                               Temp_ParentQ.Type = 2         !2-��������
                               add(Temp_ParentQ)
                            end
                            !---������ �����
                            clear(Temp_cfgQ)
                            Temp_cfgQ :=: self.YAMLD_cfgQ
                            add(Temp_cfgQ)
                            !---
                         else
                            !---������ ������
                            case val(self.YAMLD_cfgQ.Value[1 : 1]) 
                            of 42  !'*'
                               clear(Temp_ParentQ)
                               Temp_ParentQ.id = self.YAMLD_cfgQ.id
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               Temp_ParentQ.Type = 1           !1-������
                               add(Temp_ParentQ)
                            of 124 !'|'
                               clear(Temp_ParentQ)
                               case clip(upper(self.YAMLD_cfgQ.Value[2 : len(self.YAMLD_cfgQ.Value)]))
                               of 'BINARY'
                                  Temp_ParentQ.Format=1        !1-������ base64
                               end
                               Temp_ParentQ.id = self.YAMLD_cfgQ.id
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               Temp_ParentQ.Type = 3           !3-����������
                               Temp_ParentQ.MultiLineType = 1  !��� ���������� ��������� �����
                               add(Temp_ParentQ)
                            of 62  !'>'
                               clear(Temp_ParentQ)
                               Temp_ParentQ.id = self.YAMLD_cfgQ.id
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               Temp_ParentQ.Type = 3           !3-����������
                               Temp_ParentQ.MultiLineType = 2  !� ����������� ��������� �����
                               add(Temp_ParentQ)
                            of 123 !{
                               clear(Temp_ParentQ)
                               Temp_ParentQ.id = self.YAMLD_cfgQ.id
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               Temp_ParentQ.Type = 4           !4-json
                               add(Temp_ParentQ)
                               
                               !---������ �����
                               clear(Temp_cfgQ)
                               Temp_cfgQ :=: self.YAMLD_cfgQ
                               Temp_cfgQ.HeirsParent = self.YAMLD_cfgQ.id
                               add(Temp_cfgQ)
                               !--- 
                            end
                            !---Dim
                            case val(self.YAMLD_cfgQ.Parvalue[1 : 1])
                            of 45  !'-'
                               SaveIndent = self.YAMLD_cfgQ.Indent
                               clear(Temp_ParentQ)
                               Temp_ParentQ.id = self.YAMLD_cfgQ.id
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               Temp_ParentQ.Type = 5         !5-Dim
                               add(Temp_ParentQ)
                            else
                               !---�������� �� ���������� �����
                               if SaveIndent > self.YAMLD_cfgQ.Indent
                                  clear(Temp_ParentQ)
                                  Temp_ParentQ.id = self.YAMLD_cfgQ.id
                                  Temp_ParentQ.Parvalue = '@'
                                  Temp_ParentQ.Value    = '@'
                                  Temp_ParentQ.Type = 0
                                  add(Temp_ParentQ)
                               end
                               !---
                            end
                         end
                    end

                    if records(Temp_ParentQ)
                       !---����� ������ ��������� (������������)  
                       loop Ndx_J=1 to records(Temp_ParentQ)
                            get(Temp_ParentQ,Ndx_J)
                            self.YAMLD_cfgQ.id = Temp_ParentQ.HeirsParent
                            get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.id)
                            if ~errorcode()
                               Temp_ParentQ.Parvalue = self.YAMLD_GetFieldp(upper(CLIP(self.YAMLD_cfgQ.Parvalue)),1,SEP_D,0)
                               Temp_ParentQ.Value    = clip(left(self.YAMLD_GetFieldp(self.YAMLD_cfgQ.Parvalue,2,SEP_D,0)))
                               put(Temp_ParentQ)
                            end
                       end
                       loop Ndx_J=1 to records(Temp_ParentQ)
                            get(Temp_ParentQ,Ndx_J)
                            if ~val(Temp_ParentQ.Value[1 : 1]) = 45 and |  !'-'
                               (Temp_ParentQ.Type=5 or Temp_ParentQ.Type=2)
                            else
                               !---���� �� ������ �� ������� ��������� �������
                               FlEnim=0
                            end
                            !---
                            case Temp_ParentQ.Type
                            of 2     !2-��������
                               FindValue = Temp_ParentQ.Value[2 : len(Temp_ParentQ.Value)]
                               FindHeirsParent = Temp_ParentQ.HeirsParent
                               do fillLinks
                            of 3     !3-����������
                               FindValue = Temp_ParentQ.Value[1 : 1]
                               FindHeirsParent = Temp_ParentQ.id
                               do fillMultiLine
                            of 4     !4-json
                               FindValue = Temp_ParentQ.Value[1 : 1]
                               FindHeirsParent = Temp_ParentQ.id
                               do fillJson
                            of 5     !5-Dim
                               FindValue = Temp_ParentQ.Parvalue[1 : 1]
                               FindHeirsParent = Temp_ParentQ.id
                               do fillDim
                            end
                       end
                       !---
                    end
                    !---DEBUG---
                    if self.p_debug
                       self.YAMLD_LoggerQ('Temp_cfgQ',Temp_cfgQ)
                       self.YAMLD_LoggerQ('Temp_ParentQ',Temp_ParentQ)
                       self.YAMLD_LoggerQ('self.YAMLD_DimQ',self.YAMLD_DimQ)
                       self.YAMLD_LoggerQ('self.YAMLD_cfgQ',self.YAMLD_cfgQ)
                    end
                    !---
                    return(0)
!-------------
fillDim             ROUTINE  !������� ������
                    loop Ndx_J2=1 to records(Temp_ParentQ)
                         get(Temp_ParentQ,Ndx_J2)

                         if Temp_ParentQ.Type=5 and |        !5-Dim
                            clip(Temp_ParentQ.Parvalue[1 : 1]) = clip(FindValue) |
                            and Temp_ParentQ.id = FindHeirsParent

                            self.YAMLD_cfgQ.id = Temp_ParentQ.id
                            get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.id)
                            if ~errorcode()
                               clear(Rec_cfgQ)
                               SaveNode = self.YAMLD_cfgQ.Node
                               Rec_cfgQ :=: self.YAMLD_cfgQ
                               FlEnim+=1             !��������� ������� �������
                               do FillChildDim
                            end
                         end
                    end
 
FillChildDim        ROUTINE   !���������� � Q ������
                    loop Ndx_J3=1 to records(Temp_cfgQ)
                         get(Temp_cfgQ,Ndx_J3)
                         if Temp_cfgQ.HeirsParent = FindHeirsParent
                            self.YAMLD_cfgQ :=: Rec_cfgQ 
                            self.YAMLD_cfgQ.Value = Temp_cfgQ.Value
                            !---�������� ���������� ������
                            SaveNode = SaveNode[1 : len(clip(SaveNode))-1] & FlEnim
                            self.YAMLD_cfgQ.Node  = clip(SaveNode) & Temp_cfgQ.Node[ |
                                                   instring('/',Temp_cfgQ.Node,|
                                                                            -1,|
                                                              len(Temp_cfgQ.Node)) : len(Temp_cfgQ.Node)]
                            self.YAMLD_cfgQ.Value = Temp_cfgQ.Value
                            add(self.YAMLD_cfgQ)
                            
                            !---�������� ������ ������� �������
                            self.YAMLD_DimQ.Node = SaveNode[1 : len(clip(SaveNode))-1]
                            get(self.YAMLD_DimQ,+self.YAMLD_DimQ.Node)
                            if errorcode()
                               self.YAMLD_DimQ.Node = SaveNode[1 : len(clip(SaveNode))-1]
                               self.YAMLD_DimQ.size = FlEnim
                               add(self.YAMLD_DimQ)
                            else
                               self.YAMLD_DimQ.size = FlEnim
                               put(self.YAMLD_DimQ)
                            end
                            !---
                         end
                    end
!-------------
fillJson            ROUTINE   !��������� ������� Json
                    loop Ndx_J2=1 to records(Temp_ParentQ)
                         get(Temp_ParentQ,Ndx_J2)

                         if Temp_ParentQ.Type=4 and |        !1-������
                            clip(Temp_ParentQ.Value[1 : 1]) = clip(FindValue) and |
                            Temp_ParentQ.id = FindHeirsParent                            

                            self.YAMLD_cfgQ.id = Temp_ParentQ.id
                            get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.id)
                            if ~errorcode()
                               clear(Rec_cfgQ)
                               SaveNode = self.YAMLD_cfgQ.Node
                               Rec_cfgQ :=: self.YAMLD_cfgQ
                               do FillJsonItem
                            end
                         end
                    end
                    
FillJsonItem        ROUTINE   !���������� � Q ������
                    loop Ndx_J3=1 to records(Temp_cfgQ)
                         get(Temp_cfgQ,Ndx_J3)
                         if Temp_cfgQ.HeirsParent = FindHeirsParent
                            self.YAMLD_cfgQ :=: Rec_cfgQ 
                            self.YAMLD_cfgQ.Value = Temp_cfgQ.Value
                            
                            !---������� ������ Json
                            do FillJsonType
                            loop Ndx_J4=1 to records(QKeyPar)
                                 get(QKeyPar,Ndx_J4)
                                 
                                 !---�������� ���������� ������
                                 self.YAMLD_cfgQ.Node  = clip(SaveNode) &'/'& clip(QKeyPar.sKey)
                                 self.YAMLD_cfgQ.Value = clip(QKeyPar.sValue)
                                 add(self.YAMLD_cfgQ)
                            end
                         end
                    end
!-------------
fillLinks           ROUTINE  !������� ������
                    loop Ndx_J2=1 to records(Temp_ParentQ)
                         get(Temp_ParentQ,Ndx_J2)

                         if Temp_ParentQ.Type=1 and |        !1-������
                            clip(Temp_ParentQ.Value[2 : len(Temp_ParentQ.Value)]) = clip(FindValue)

                            self.YAMLD_cfgQ.id = Temp_ParentQ.id
                            get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.id)
                            if ~errorcode()
                               clear(Rec_cfgQ)
                               SaveNode = self.YAMLD_cfgQ.Node
                               Rec_cfgQ :=: self.YAMLD_cfgQ
                               do FillChild
                            end
                         end
                    end
  
FillChild           ROUTINE   !���������� � Q ������
                    loop Ndx_J3=1 to records(Temp_cfgQ)
                         get(Temp_cfgQ,Ndx_J3)
                         if Temp_cfgQ.HeirsParent = FindHeirsParent
                            self.YAMLD_cfgQ :=: Rec_cfgQ 
                            self.YAMLD_cfgQ.Value = Temp_cfgQ.Value
                            !---�������� ���������� ������
                            self.YAMLD_cfgQ.Node  = clip(SaveNode) & Temp_cfgQ.Node[ |
                                                   instring('/',Temp_cfgQ.Node,|
                                                                            -1,|
                                                              len(Temp_cfgQ.Node)) : len(Temp_cfgQ.Node)]
                            self.YAMLD_cfgQ.Value = Temp_cfgQ.Value
                            add(self.YAMLD_cfgQ)
                         end
                    end
!-------------
fillMultiLine       ROUTINE  !����� ����� ���������� �����
                    loop Ndx_J2=1 to records(Temp_ParentQ)
                         get(Temp_ParentQ,Ndx_J2)

                         if Temp_ParentQ.Type=3 and |        !3-����������
                            clip(Temp_ParentQ.Value[1 : 1]) = clip(FindValue) and |
                            Temp_ParentQ.id = FindHeirsParent

                            self.YAMLD_cfgQ.id = Temp_ParentQ.id
                            get(self.YAMLD_cfgQ,+self.YAMLD_cfgQ.id)
                            if ~errorcode()
                               clear(Rec_cfgQ)
                               SaveNode = self.YAMLD_cfgQ.Node
                               Rec_cfgQ :=: self.YAMLD_cfgQ
                               do FillChildMultiLine
                            end
                         end
                    end
  
FillChildMultiLine  ROUTINE   !����������� ����� ���������� ������
                    Flfind=false
                    loop Ndx_J3=1 to records(Temp_cfgQ)
                         get(Temp_cfgQ,Ndx_J3)
                         if Temp_cfgQ.HeirsParent = FindHeirsParent
                            if Flfind=FALSE
                               self.YAMLD_cfgQ :=: Rec_cfgQ 
                               self.YAMLD_cfgQ.Value = ''
                               Flfind=true
                            end
                            !---��������� ������
                            case Temp_ParentQ.MultiLineType
                            of 1      !��� ���������� ��������� �����
                               if Ndx_J3=1
                                  self.YAMLD_cfgQ.Value = clip(Temp_cfgQ.Parvalue)
                               else
                                  self.YAMLD_cfgQ.Value = clip(self.YAMLD_cfgQ.Value) & clip(Temp_cfgQ.Parvalue)
                               end
                            of 2      !� ����������� ��������� �����
                               if Ndx_J3=1
                                  self.YAMLD_cfgQ.Value = clip(Temp_cfgQ.Parvalue) & '<13,10>'
                               else
                                  self.YAMLD_cfgQ.Value = clip(self.YAMLD_cfgQ.Value) & clip(Temp_cfgQ.Parvalue) & '<13,10>'
                               end
                            end
                         end
                    end
                    if Flfind
                       case Temp_ParentQ.Format
                       of 1           !1-������ base64
                          self.YAMLD_cfgQ.Value = self.YAMLD_B64D(self.YAMLD_cfgQ.Value)
                       end
                       put(self.YAMLD_cfgQ)
                    end
!-------------
FillJsonType        ROUTINE   !��������� ������ ���������� �� Json ������
                    free(QKeyPar)
                    StrIn =  self.YAMLD_cfgQ.Value  !'{{key1: "value1", key2: "value2"}'
                    StrIn = StrIn[2 : Len(Clip(StrIn))-1]
                    len# = Len(Clip(StrIn))
                    j# = 1
                    Loop
                       Loc:KeyWord = ''
                       i# = 1
                       Loop
                          If j#>len# or StrIn[j#]=':' Then Break.
                          If StrIn[j#]=','            Then Break.
                          if StrIn[j#]='<32>'         !��� ������
                             j#+=1
                             Cycle
                          end
                          Loc:KeyWord[i#] = StrIn[j#]
                          j# += 1
                          i# += 1
                       end
                       If Loc:KeyWord = '' Then Break.
                       If StrIn[j#]<>','   Then j# += 1.
                       Loc:KeyValue = ''
                       i# = 1
                       Loop
                          If j#>len# or StrIn[j#]=',' Then Break.
                          Loc:KeyValue[i#] = StrIn[j#]
                          j# += 1
                          i# += 1
                       end
                       If j#<len# Then j# += 1.

                       !---��������
                       Loc:KeyValue = clip(left(Loc:KeyValue))
                       pend# = Len(Clip(Loc:KeyValue))
                       if pend#=0 then pend#=1.
                       QKeyPar.sKey = clip(UPPER(Loc:KeyWord))
                       if val(Loc:KeyValue[1 : 1]) = 34 and |
                          val(Loc:KeyValue[pend# : pend#]) = 34
                          if pend#=1 then pend#=3.
                          QKeyPar.sValue = Loc:KeyValue[2 : pend#-1]
                       else
                          QKeyPar.sValue = Loc:KeyValue
                       end
                       add(QKeyPar)
                    end

                    !---DEBUG
                    if self.p_debug
                       self.YAMLD_LoggerQ('QKeyPar',QKeyPar)
                    end
!****************************************************************************************************
YAMLD.YAMLD_LoggerQ  Procedure(String _Message, *Queue _InQ)         
                    !������� �������� Q
Window              WINDOW('  ������'),AT(,,667,392),GRAY,IMM,SYSTEM,MAX,ICON(ICON:Thumbnail), |
                    FONT('Microsoft Sans Serif',10,,FONT:regular),DROPID('LOGGERWINDOW'),RESIZE
                    LIST,AT(2,6,662,365),USE(?LIST),HVSCROLL,FONT(,14),FROM(_InQ),GRID(COLOR:Silver), |
                     FORMAT('100L(2)|M~����1~C(2)@s500@')
                    BUTTON('&OK'),AT(618,376,41,14),USE(?OkButton),STD(STD:Close),DEFAULT
                    END
FormatStr           cstring(5000)  ! �������� ������� ������� (���������)
A                   ANY
Ndx                 LONG
Ndx2                LONG
MaxD                long
MapValueQ           queue,pre(MapValueQ)
NameField             string(40)   !��� ����
Gvalue                any          !�������� ����
Type                  byte         !��� ����
colW                  long         !������ �������
                    END
QColumns            long
ColMaxW             EQUATE(120)      !������ �������
SFormat             string(10)
                    code
                    do ShowList
                    return

ShowList            routine
                    open(Window)
                    !---���������
                    Window{PROP:Text}='  ����� �������: ' & records(_InQ)
                    Window{PROP:Text}='    '& clip(_Message) &'   ('& left(Window{PROP:Text})  &')'

                    !---��������� �� ������� ������ Q � �������� ����� �����
                    do GetMapInQ

                    !---����� �������
                    QColumns = records(MapValueQ)

                    !---���������� ������ �������
                    do BuildFormatStr

                    ?List{PROP:LineHeight}=?List{PROP:FontSize}+4  ! ��� ����� ��������
                    select(?LIST)

                    accept
                       case event()
                       of event:accepted
                          if field()=?OkButton
                             break
                          end
                       of EVENT:Sized
                          GETPOSITION(Window,x#,y#,w#,h#)
                          SETPOSITION(?LIST,1,1,w#,h#-20)
                          ?OkButton{prop:at,2} = h#-15
                          ?OkButton{prop:at,1} = w#/2-20
                       of EVENT:Maximized
                          GETPOSITION(Window,x#,y#,w#,h#)
                          SETPOSITION(?LIST,1,1,w#,h#-20)
                          ?OkButton{prop:at,2} = h#-15
                          ?OkButton{prop:at,1} = w#/2-20
                       end
                    end
                    close(Window)

GetMapInQ           routine
                    !---��������� �� ������� ������ Q � �������� ����� �����
                    free(MapValueQ)
                    Ndx = 0
                    Ndx2= 0
                    loop
                       Ndx += 1
                       A &= WHAT(_InQ, Ndx)
                       if A &= Null then break.
                       MaxD = self.YAMLD_xIsDimSize(A)
                       if MaxD
                          !---��������� ���� ���� ��� �������
                          loop Ndx2=1 to MaxD
                               A &= WHAT(_InQ, Ndx, Ndx2)
                               If A &= NULL then break.
                               clear(MapValueQ)
                               MapValueQ.NameField = clip(upper(WHO(_InQ,Ndx)))
                               MapValueQ.Gvalue = A 
                               MapValueQ.Type = self.YAMLD_xIsType(A)
                               MapValueQ.colW = ColMaxW
                               ADD(MapValueQ)
                          end
                       ELSE
                          clear(MapValueQ)
                          if ISGROUP(_InQ, Ndx) 
                             MapValueQ.colW = 0
                          else
                             MapValueQ.colW = ColMaxW
                          end
                          MapValueQ.NameField = clip(upper(WHO(_InQ,Ndx)))
                          MapValueQ.Gvalue = A 
                          MapValueQ.Type = self.YAMLD_xIsType(A)
                          ADD(MapValueQ)
                       END
                    end
                    A &=NULL

BuildFormatStr      routine
                    !---���������� ������ �������������� LIST
                    if QColumns=0 then QColumns=1.
                    FormatStr = ''
                    loop Ndx=1 to QColumns
                         get(MapValueQ,Ndx)
                         do GetFormatField                                 ! ������ ���� �������
                         FormatStr=FormatStr                          & |  ! ������: '13L(1)|_FMY~��~C(0)@s3@'
                                   MapValueQ.colW                     & |  ! ������ ������� (������ � dialog units)
                                   'L'                                & |  ! ���������
                                   '(2)|'                             & |  ! ������ �� ������� (� ����� ����������� � �������������)
                                   'M'                                & |  ! ������� ����������� ���.������ �������
                                   '~'&clip(MapValueQ.NameField)&'~'  & |  ! ��������� ������� (������)
                                   'C(2)'                             & |  ! �������� ���������
                                   clip(SFormat)                           ! ������ �������
                    end
                    ?LIST{PROP:Format}=FormatStr

GetFormatField      ROUTINE
                    !---������ ���� �������
                    case MapValueQ.Type
                    of 4 !DATE
                       SFormat = '@D12@'
                    of 5 !TIME
                       SFormat = '@T05@'
                    else !OZER
                       SFormat = '@s200@'
                    end
!****************************************************************************************************
YAMLD.YAMLD_B64D   Procedure(String _InData)
RetString          String(size(_InData))
LenRetString       ulong
                   CODE
                   LenRetString = size(RetString)
                   base64_decode(RetString, LenRetString, _InData, len(clip(_InData)))
                   Return(sub(RetString,1,LenRetString))
!****************************************************************************************************
YAMLD.YAMLD_xIsType  Procedure(*? _Var)
                    !����������� ���� ���������� for Clarion8-11
                    ! ������������ ���� ����� ������:
                    ! byte    - 1
                    ! short   - 2
                    ! date    - 4
                    ! time    - 5
                    ! long    - 6
                    ! real    - 9
                    ! decimal - 10
                    ! string  - 18
                    ! cstring - 19
iUFO                INTERFACE,TYPE
_Type                  PROCEDURE(LONG _UfoAddr),LONG       !+00h ��� ������� UFO-������
ToMem                  PROCEDURE                           !+04h
FromMem                PROCEDURE                           !+08h
OldFromMem             PROCEDURE                           !+0Ch
Pop                    PROCEDURE(LONG _UfoAddr)            !+10h ��������� �������� �� ���������� �����
Push                   PROCEDURE(LONG _UfoAddr)            !+14h ��������� �������� ������� UFO-������� �� ��������� ����
DPop                   PROCEDURE(LONG _UfoAddr)            !+18h ��������� �������� � DECIMAL-�����
DPush                  PROCEDURE(LONG _UfoAddr)            !+1Ch ��������� �������� ������� UFO-������� �� DECIMAL-����
_Real                  PROCEDURE(LONG _UfoAddr),REAL       !+20h ���������� �������� ������� UFO-������� � ���� REAL-��������
_Long                  PROCEDURE(LONG _UfoAddr),LONG       !+24h ���������� �������� ������� UFO-������� � ���� LONG-��������
_Free                  PROCEDURE(LONG _UfoAddr)            !+28h ���� ������ UFO-������ ��������� �� ������� ������������ ������, �� ��� �������������. � ����� ������ �������� ����� ������, �� ������� ��������� ������ UFO-������.
_Clear                 PROCEDURE                           !+2Ch ������� ����������, �� ������� ��������� ������ UFO-������
_Address               PROCEDURE(LONG _UfoAddr),LONG       !+30h ���������� ����� ���������� (������� ������) �� ������� ��������� ������ UFO-������
AssignLong             PROCEDURE                           !+34h ��������� LONG-��������
AssignReal             PROCEDURE                           !+38h ��������� REAL-��������
AssignUFO              PROCEDURE                           !+3Ch ��������� �������� ������� UFO-������
AClone                 PROCEDURE(LONG _UfoAddr),LONG       !+40h ���������� ���� ������� UFO-�������
Select                 PROCEDURE                           !+44h ��� �������� � ����� ����������� _Var[Ptr]
Slice                  PROCEDURE                           !+48h ��� ����� ����������� _Var[Ptr1:Ptr2]
Designate              PROCEDURE                           !+4Ch ������� ������������ ���� ������ � ���� UFO-�������
_Max                   PROCEDURE(LONG _UfoAddr),LONG       !+50h ���������� ���-�� ��������� � ������ ��������� �������
_Size                  PROCEDURE(LONG _UfoAddr),LONG       !+54h ���������� ������ ������ ���������� (������� ������), �� ������� ��������� ������ UFO-������
BaseType               PROCEDURE(LONG _UfoAddr),LONG       !+58h
DistinctUpper          PROCEDURE                           !+5Ch
DistinctsUFO           PROCEDURE                           !+60h
DistinctsLong          PROCEDURE                           !+64h
Cleared                PROCEDURE(LONG _UfoAddr)            !+68h ���������?
IsNull                 PROCEDURE(LONG _UfoAddr),LONG       !+6Ch
OEM2ANSI               PROCEDURE(LONG _UfoAddr)            !+70h
ANSI2OEM               PROCEDURE(LONG _UfoAddr)            !+74h
_Bind                  PROCEDURE(LONG _UfoAddr)            !+78h ���������� ����� ������
_Add                   PROCEDURE                           !+7Ch
Divide                 PROCEDURE                           !+80h
Hash                   PROCEDURE(LONG _UfoAddr),LONG       !+84h Calc CRC
SetAddress             PROCEDURE                           !+88h ������ ����� ���������� (������� ������), �� ������� ����� ��������� ������ UFO-������
Match                  PROCEDURE                           !+8Ch ���������� ��� � ������ ����, �� ������� ��������� ������ UFO-������ � ����� �� �������� ClassDesc-���������
Identical              PROCEDURE                           !+90h
Store                  PROCEDURE                           !+94h �������� �������� ������� UFO-������� � �������� ������� ������
                     END
UfoAddr              LONG,OVER(_Var)
UFO_VMTPtr           &LONG
Ufo                  &iUFO
                     CODE
                     LType# = 0
                     if UfoAddr
                        UFO_VMTPtr &= (UfoAddr)
                        if UFO_VMTPtr
                           Ufo &= (UfoAddr)
                           LType# = Ufo._Type(UfoAddr)
                     .  .
                     RETURN(LType#)
!****************************************************************************************************
YAMLD.YAMLD_xIsDimSize  Procedure(*? _Var)
!��� ���������� (���������� ���-�� ��������� � ������ ��������� �������) for Clarion8-11
iUFO                INTERFACE,TYPE
_Type                  PROCEDURE(LONG _UfoAddr),LONG       !+00h ��� ������� UFO-������
ToMem                  PROCEDURE                           !+04h
FromMem                PROCEDURE                           !+08h
OldFromMem             PROCEDURE                           !+0Ch
Pop                    PROCEDURE(LONG _UfoAddr)            !+10h ��������� �������� �� ���������� �����
Push                   PROCEDURE(LONG _UfoAddr)            !+14h ��������� �������� ������� UFO-������� �� ��������� ����
DPop                   PROCEDURE(LONG _UfoAddr)            !+18h ��������� �������� � DECIMAL-�����
DPush                  PROCEDURE(LONG _UfoAddr)            !+1Ch ��������� �������� ������� UFO-������� �� DECIMAL-����
_Real                  PROCEDURE(LONG _UfoAddr),REAL       !+20h ���������� �������� ������� UFO-������� � ���� REAL-��������
_Long                  PROCEDURE(LONG _UfoAddr),LONG       !+24h ���������� �������� ������� UFO-������� � ���� LONG-��������
_Free                  PROCEDURE(LONG _UfoAddr)            !+28h ���� ������ UFO-������ ��������� �� ������� ������������ ������, �� ��� �������������. � ����� ������ �������� ����� ������, �� ������� ��������� ������ UFO-������.
_Clear                 PROCEDURE                           !+2Ch ������� ����������, �� ������� ��������� ������ UFO-������
_Address               PROCEDURE(LONG _UfoAddr),LONG       !+30h ���������� ����� ���������� (������� ������) �� ������� ��������� ������ UFO-������
AssignLong             PROCEDURE                           !+34h ��������� LONG-��������
AssignReal             PROCEDURE                           !+38h ��������� REAL-��������
AssignUFO              PROCEDURE                           !+3Ch ��������� �������� ������� UFO-������
AClone                 PROCEDURE(LONG _UfoAddr),LONG       !+40h ���������� ���� ������� UFO-�������
Select                 PROCEDURE                           !+44h ��� �������� � ����� ����������� _Var[Ptr]
Slice                  PROCEDURE                           !+48h ��� ����� ����������� _Var[Ptr1:Ptr2]
Designate              PROCEDURE                           !+4Ch ������� ������������ ���� ������ � ���� UFO-�������
_Max                   PROCEDURE(LONG _UfoAddr),LONG       !+50h ���������� ���-�� ��������� � ������ ��������� �������
_Size                  PROCEDURE(LONG _UfoAddr),LONG       !+54h ���������� ������ ������ ���������� (������� ������), �� ������� ��������� ������ UFO-������
BaseType               PROCEDURE(LONG _UfoAddr),LONG       !+58h
DistinctUpper          PROCEDURE                           !+5Ch
DistinctsUFO           PROCEDURE                           !+60h
DistinctsLong          PROCEDURE                           !+64h
Cleared                PROCEDURE(LONG _UfoAddr)            !+68h ���������?
IsNull                 PROCEDURE(LONG _UfoAddr),LONG       !+6Ch
OEM2ANSI               PROCEDURE(LONG _UfoAddr)            !+70h
ANSI2OEM               PROCEDURE(LONG _UfoAddr)            !+74h
_Bind                  PROCEDURE(LONG _UfoAddr)            !+78h ���������� ����� ������
_Add                   PROCEDURE                           !+7Ch
Divide                 PROCEDURE                           !+80h
Hash                   PROCEDURE(LONG _UfoAddr),LONG       !+84h Calc CRC
SetAddress             PROCEDURE                           !+88h ������ ����� ���������� (������� ������), �� ������� ����� ��������� ������ UFO-������
Match                  PROCEDURE                           !+8Ch ���������� ��� � ������ ����, �� ������� ��������� ������ UFO-������ � ����� �� �������� ClassDesc-���������
Identical              PROCEDURE                           !+90h
Store                  PROCEDURE                           !+94h �������� �������� ������� UFO-������� � �������� ������� ������
                    END
UfoAddr             LONG,OVER(_Var)
UFO_VMTPtr          &LONG
Ufo                 &iUFO
                    CODE
                    LType# = 0
                    if UfoAddr
                       UFO_VMTPtr &= (UfoAddr)
                       if UFO_VMTPtr
                          Ufo &= (UfoAddr)
                          LType# = Ufo._Max(UfoAddr)
                    .  .
                    RETURN(LType#)
!****************************************************************************************************
!****************************************************************************************************
!****************************************************************************************************