#ifndef C_FILECONTROL
#define C_FILECONTROL
#define C_FILECONTROL_DEBUG false
//+------------------------------------------------------------------+
//|                                                 cFileControl.mqh |
//|                                            Rafael Floriani Pinto |
//|                           https://www.mql5.com/pt/users/rafaelfp |
//+------------------------------------------------------------------+
#property copyright "Rafael Floriani Pinto"
#property link      "https://www.mql5.com/pt/users/rafaelfp"
#include<FileControl/NewTypes.mqh>

class c_FileControl{
  public:
   c_FileControl();
   bool newFileWriteString(const string,const string,const int);
   ENUM_FILECONTROL_ERRO getLastErro()const{return m_lasterro;};
   void setFileControlConfig(STRUCT_FILECONTROL_CONFIG&);
  private:
   //OBJ
   ENUM_FILECONTROL_ERRO m_lasterro;
   STRUCT_FILECONTROL_CONFIG m_fileconfig;
   int m_filehandle;
   //FUNCTION
   string getNewFileName(const string);
   string getFileBaseName(const string)const;
   string getFileExt(const string)const;
   void debugMessage(const string,const string)const;
   void resetLastErro(){m_lasterro=FILECONTROL_ERRO_NOERRO;ResetLastError();}
   
   
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  c_FileControl::c_FileControl(){
    resetLastErro();
    STRUCT_FILECONTROL_CONFIG set;
    set.maxnametries=500;
    set.commom_flag=0;
    setFileControlConfig(set);    
    debugMessage("END CONSTRUCT",__FUNCTION__);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
 bool c_FileControl::newFileWriteString(const string filename,const string data,const int flags){
   resetLastErro();
   const string writefilename=getNewFileName(filename);
   if(writefilename==""){
     debugMessage("Erro To Set FileName",__FUNCTION__);
     return false;
   }
   if(data==""){
     m_lasterro=FILECONTROL_ERRO_DATANULL;
     debugMessage("Data Null",__FUNCTION__);
     return false;
   }   
   m_filehandle=FileOpen(writefilename,FILE_WRITE|flags);
   if(m_filehandle==INVALID_HANDLE){
     m_lasterro=FILECONTROL_ERRO_INVALIDHANDLE;
     debugMessage("invalid Handle",__FUNCTION__);
     return false;     
   }
   uint ndata=FileWriteString(m_filehandle,data);
   m_lasterro=FILECONTROL_ERRO_NOERRO;
   debugMessage("File Create and Write nBytes="+IntegerToString(ndata),__FUNCTION__);
   FileClose(m_filehandle);
   return true;
 }
//---

  void c_FileControl::setFileControlConfig(STRUCT_FILECONTROL_CONFIG &set){
    resetLastErro();
    m_fileconfig.maxnametries=set.maxnametries;
    m_fileconfig.commom_flag=set.commom_flag;
    const string infostring="STRUCT_FILECONTROL_CONFIG\n"+
                            "maxnametries: "+IntegerToString(m_fileconfig.maxnametries)+"\n"+
                            "commom_flag: "+IntegerToString(m_fileconfig.commom_flag)+"\n";
    debugMessage(infostring,__FUNCTION__);                        
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  string c_FileControl::getNewFileName(const string filename){
    debugMessage("Arg FileName: "+filename,__FUNCTION__);
    const string base=getFileBaseName(filename);
    if(base==""){
      m_lasterro=FILECONTROL_ERRO_FILENAMENULL;
      debugMessage("FileBaseNull",__FUNCTION__);
      return "";
    }
    const string ext=getFileExt(filename);
    if(ext==""){
      m_lasterro=FILECONTROL_ERRO_EXTNULL;
      debugMessage("Extesion Null",__FUNCTION__);
      return "";
    }
    string tempfilename=base+"."+ext;
    int i=0;
    while(FileIsExist(tempfilename,m_fileconfig.commom_flag)){
    i++;
    tempfilename=base+"("+IntegerToString(i)+")."+ext;
    if(m_fileconfig.maxnametries<i){
      m_lasterro=FILECONTROL_ERRO_MAXFILENAMETRIES;
      debugMessage("Max FileName Tries LastFileName: "+tempfilename,__FUNCTION__);
      return "";
    }    
    }
    m_lasterro=FILECONTROL_ERRO_NOERRO;    
    debugMessage("FileNameReturn: "+tempfilename,__FUNCTION__);
    return tempfilename;
  }
  //---
  string c_FileControl::getFileBaseName(const string filename)const{
    const int size=StringLen(filename);
    if(size<1)return "";
    int i=0;    
    string tempstr="";
    while(filename[i]!=0 && i<size){
      if(filename[i]==46)break;
      StringAdd(tempstr,CharToString((uchar)filename[i]));
      i++;
    }
    debugMessage("BaseName: "+tempstr,__FUNCTION__);
    return tempstr;  
  }
  //---
  string c_FileControl::getFileExt(const string filename)const{
    const int size=StringLen(filename);
    if(size<1)return "";
    string tempstr="";
    int i=0;
    while(filename[i]!=0){
      if(filename[i]==46){i++;break;}
      i++;      
    }
    while(filename[i]!=0){
    StringAdd(tempstr,CharToString((uchar)filename[i]));
    i++;
    }
    debugMessage("EXT: "+tempstr,__FUNCTION__);
    return tempstr;
  }
  
  //---
  void c_FileControl::debugMessage(const string message,const string fname)const{
     if(!C_FILECONTROL_DEBUG)return;
     Print("__DEBUG__ Message: "+message+
            " FuncName: "+fname+
            " cFile_LastErro: "+EnumToString(m_lasterro)+
            " MQL_LastErro: "+IntegerToString(GetLastError())
           
           );
  }

#endif