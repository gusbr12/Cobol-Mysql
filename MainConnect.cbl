       PROGRAM-ID.                 ConsultaMenu.
       AUTHOR.                     GUSTAVO DIAS.
       DATE-WRITTEN.               2024-03-18.
                       
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       
       SELECT ARQ-GRAVA ASSIGN TO DISK
            ORGANIZATION IS LINE SEQUENTIAL
            ACCESS MODE IS SEQUENTIAL.
  
       DATA DIVISION.
       FILE SECTION.                                        


       FD  ARQ-GRAVA
           LABEL RECORDS ARE STANDARD
           VALUE OF FILE-ID IS WS01-NOME-GRAVA.           

           01 ARQ-ESCREVE   PIC X(1700).                            
       
       WORKING-STORAGE   SECTION.
       
       77  skipscreen                    PIC X(04).                                                   
       01  WS01-NOME-GRAVA.
           03 FILLER               PIC X(08) VALUE "CONSULTA".
           03 FILLER               PIC X(04) VALUE ".txt".
       01  D-REC.
           05  D-ID                PIC 9(05).
           05  FILLER              PIC X.                      
           05  D-data              PIC 9(10).
           05  FILLER              PIC X.                      
           05  D-hora              PIC X(08).
           


       EXEC SQL BEGIN DECLARE SECTION END-EXEC.    
            
       01  IDSELECT                PIC  9(04).
       01  IDSELECT2               PIC  9(04).
       01  DATASELECT              PIC  9(08).       
       01  HORASELECT2             PIC  9(06).
       01  hrFORMAT                PIC  9(08).
       01  hrFORMATb               PIC  9(08).         
       01  IDMENU                  PIC  9(01).
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.
       01  TBLVARS.
           05  TBL-ID              PIC  9(05).           
           05  TBL-data            pic  9(10).
           05  TBL-hora            pic  X(08).          
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
    ******************************************************************                                            
                
       PROCEDURE  DIVISION.                                        
                                                                   
       ROTINA-PRINCIPAL.                      
  
           MOVE  "BANCONOME"                        TO   DBNAME.
           MOVE  "USUARIOS"                         TO   USERNAME.
           MOVE  "SENHABANCO"                       TO   PASSWD.
           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.
           IF  SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.
         
           PERFORM PROGSQL-MENU.     
  

           EXEC SQL
               OPEN C1
           END-EXEC.                                                   
        


           EXEC SQL 
               FETCH C1 INTO :TBL-ID, :TBL-data, :TBL-hora,               
           END-EXEC.
       
           PERFORM UNTIL SQLCODE NOT = ZERO
              MOVE  TBL-ID        TO    D-ID              
              MOVE  TBL-data      TO    D-data
              MOVE  TBL-hora      TO    D-hora                            
          
                
           PERFORM PROGSQL-SKET
           
          
               EXEC SQL 
                 FETCH C1 INTO :TBL-ID,:TBL-data, :TBL-hora,                 
               END-EXEC
           END-PERFORM.
           
      *    CLOSE CURSOR
           EXEC SQL 
               CLOSE C1 
           END-EXEC
                                  
           STOP RUN.

      ******************************************************************
       ERROR-RTN.
      ******************************************************************
           DISPLAY " "                 AT 0101 WITH ERASE EOS
           DISPLAY "*** SQL ERROR ***" AT 0101
           DISPLAY "SQLCODE: " SQLCODE AT 0201. 
           EVALUATE SQLCODE
              WHEN  +10
                 DISPLAY "O Registro não foi encontrado!" AT 0301
              WHEN  -01
                 DISPLAY "A conexão falhou!" AT 0301
              WHEN  -20
                 DISPLAY "Erro interno!" AT 0301 
              WHEN  -30
                 DISPLAY "PostgreSQL error" AT 0301 
                 DISPLAY "ERRCODE: "  SQLSTATE AT 0401 
                 DISPLAY SQLERRMC AT 0501
       
       PROGSQL-MENU. 
           Display " ___________________________"  AT 1101
           DISPLAY "|                           |" AT 1201           
           DISPLAY "| TESTE.               - [1]|" AT 1301
           DISPLAY "|                           |" AT 1401
           DISPLAY "|                           |" AT 1501
           DISPLAY "|                           |" AT 1601
           DISPLAY "|___________________________|" AT 1701           
           ACCEPT IDMENU                           AT 1530.       
           DISPLAY " "                        AT 0501 WITH ERASE EOS
                 
       IF  IDMENU = 1
           PERFORM PROGSQL-TESTE.     
       
       PROGSQL-SKET.
           DISPLAY " " AT 0501 WITH ERASE EOS.                       
           DISPLAY "TBLId: "           AT 0501
           DISPLAY D-id                AT 0508            
           DISPLAY "TBLData: "         AT 0601
           DISPLAY D-data              AT 0610
           DISPLAY "TBLHora: "         AT 0701
           DISPLAY D-hora              AT 0710
           
           
      *--------------------------------------------      
           ACCEPT skipscreen  AT 1801
           DISPLAY skipscreen AT 1815.
           

       IF  skipscreen = "@"
           OPEN OUTPUT ARQ-GRAVA           
           
           EXEC SQL 
               CLOSE C1 
           END-EXEC                                    
           EXEC SQL
                DISCONNECT ALL
           END-EXEC        
                                                                                                                                                                                      
           MOVE D-REC      TO  ARQ-ESCREVE        
           WRITE ARQ-ESCREVE
           CLOSE ARQ-GRAVA
       STOP RUN.                            
       
       PROGSQL-TESTE.              
       DISPLAY "INSIRA A DATA:" AT 0501
       ACCEPT wsDATA            AT 0512
       DISPLAY "INSIRA A HORA:" AT 0601
       ACCEPT wsHORA            AT 0612


       EXEC SQL
              DECLARE C1 CURSOR FOR
              SELECT TBLID, TBLDATA, TBLHora
              FROM SUA_TABELA
              WHERE TBLDATA = :wsDATA AND
              TBLHora = :wsHORA
              ORDER BY TBLID              
           END-EXEC.      


