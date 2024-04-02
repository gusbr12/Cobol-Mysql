# COBOL - Conexão MYSQL via PostgreSQL remoto (unix).

 
   Grande parte do programa contém o uso do pré-compilador [Open-Cobol-ESQL](https://github.com/opensourcecobol/Open-COBOL-ESQL), por parte, há a possibilidade
   encontrar complicações na instalação dependendo da distribuição linux usada e faltam alguns ajustes para acertar o ponto no qual facilite a instalação e a 
   funcionalidade do pré-compilador com o GNUCOBOL.Em sistemas REDHAT/CentOs há muito para ser feito em questão de instalação do ESQL, pois, precisa de muitos pacotes de ferramentas, em      breve sairá uma sessão especial para tal sistema.
##

### SISTEMA e PROGRAMAS
    
 
 > [!IMPORTANT]
 > DIST. atuais não funcionam adequadamente com a versão necessária do GnuCOBOL!

   + Linux Mint 21.2 Victoria Cinnamon 5.8.4     
   + GnuCOBOL 3.1.2.0
   + GCC version 11.4.0
   + Mysql  Ver 8.0.35
   + PostgreSQL 14.9    
   + [Open Cobol ESQL](https://github.com/opensourcecobol/Open-COBOL-ESQL)

##

### CONFIGURAÇÃO e AVISOS

 -  Não é recomendado usar o 'sudo apt update' no terminal APÓS instalar o GnuCOBOL, senão, corre o risco de atualizar o compilador(COBOL) e as funções para gerar arquivos indexados
    pararem de funcionar (ler e gerar arquivos indexados está indisponivel na versão atual do GnuCobol (4.0)).    
 -  O pré-compilador Open Cobol ESQL possui um manual nos arquivos de instalações(README), para testar basta digitar o comando ocesql no terminal e deve retornar as infos do pré-com
    pilador.  
 -  Todos os programas foram instalados pelo terminal com exceção do OPEN COBOL ESQL - (sudo apt install(***)).

 -  Será necessário editar as variáveis do sistema, caso não forem editadas, após a instalação de diversos programas ocorre um conflito de diretorios após uma compilação:

                                                                      
                export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
               

    
 -  O arquivo "sqlca.cbl"(se encontra na pasta "COPY" do arquivo raiz do pré-compilador ESQL) deve estar presente no mesmo diretório do código que vá utilizar o pre-compilador ESQL.
 -  Há outra forma de utilizar o arquivo sem precisar manter ele no mesmo diretório do código:

                 export COBCPY= *caminho da raiz do pré-compilador*/copy
    
> [!WARNING]
> Todos os programas compilados após editar a variavel do sistema(COBCPY) vão utilizar 
o mesmo diretório para buscar TODOS os 'COPY', então, é recomendado utilizar uma pasta
fixa para colocar todos no mesmo diretório.

##


### COMPILAÇÃO e MODOS DE USO

 -  Para compilar os programas foi criado um script em ShellScript com todos os parâmetros necessários (scriptcomp.sh).
 -  O programa que obter conteúdo do OPEN ESQL deve ser compilado com os parâmetros '-static' e '-locesql'.

 -  O pré-compilador ESQL não vai reconhecer nenhuma variável que for usada com os comandos ESQL(EXEC SQL, SELECT, ETC) se estiver fora da área de declaração SQL.  
```COBOL                                                                                               
                   77  WS-COUNT                PIC  9(02).                              
                    
                   EXEC SQL BEGIN DECLARE SECTION END-EXEC.                                        
                   01  wsVAR1                  PIC  9(04).                      
                   01  wsVAR2                  PIC  9(06).                        
                   01  IDSELECT                PIC  9(04).                         
                   01  IDSELECT2               PIC  9(04).                                                        
                   01  DATASELECT              PIC  9(10).                          
                   01  HORASELECT              PIC  9(06).                       
                   01  HORASELECT2             PIC  9(06).                         
                   01  hrFORMAT                PIC  9(08).
                   01  hrFORMATb               PIC  9(08).                        
                   01  IDMENU                  PIC  9(02).                                                      
                   01  DBNAME                  PIC  X(30) VALUE SPACE.                                                                        
                   01  USERNAME                PIC  X(30) VALUE SPACE.                       
                   01  PASSWD                  PIC  X(10) VALUE SPACE.                                                        
                   EXEC SQL END DECLARE SECTION END-EXEC.
```
##
### Erros possíveis  

> [!CAUTION]
> Apresentará erro se executar o programa compilado no modo root.        
- Declarar uma variável no level 77, pois, não é aceito na sessão de declaração do SQL.                       
- Direcionar um File-ID através de uma variável.

```COBOL
                  EXEC SQL BEGIN DECLARE SECTION END-EXEC.

                  77    WS77-ARQUIVO PIC X(13) VALUE "texto.txt".

                  EXEC SQL END DECLARE SECTION END-EXEC.
```     
- Variáveis que vão armazenar dados na memória devem ser declaradas 
                            fora da sessão de declaração do SQL.                   
- Para usar variáveis com dados armazenados na memória deve ser usado da seguinte forma:
> [!IMPORTANT]
>> A var. deve ser movida para uma var. que esteja dentro da sessão de declaração do SQL.
>>> A variavel movida deve ser usada com ":" para ser reconhecida.
 
  
```COBOL                                                                      
                      MOVE WS01-HORA   TO wsHORA                                                    
                      MOVE ws01-DATA   TO wsDATA             
                                                                                   
                      EXEC SQL                                               
                           DECLARE C1 CURSOR FOR
                           SELECT TBLID, TBLData, TBLHora                           
                           FROM SUA_TABELA
                           WHERE (TBLDATA = :wsDATA AND   
                           TBLHORA = :wsHORA)           
                      END-EXEC                                           
```

##

### GUIA DO ESQL

  SQLCODE: https://www.ibm.com/docs/en/db2-for-zos/11?topic=codes-sql-error

> [!NOTE]
   >  Os valores das flags SQLWARN devem ser verificados para determinar o tipo de erro.
   >> Principalmente, verificar os valores quando acontecer o código-erro *1*.
  
  | CODIGO-ERRO  |   DESCRIÇÃO   |
  | -------------| ------------- |
  |      0       | A instrução foi executada sem erros.  |
  |      1       | A instrução foi executada, mas foi gerado um aviso  |
  |     100      |  Não foram encontrados dados correspondentes à consulta ou o final do conjunto de resultados foi alcançado  |
  |     <0       |  A instrução não foi executada devido a um erro de aplicativo, banco de dados, sistema ou rede|
 
  

   

## Fonte dos códigos de erro: 
http://www.cadcobol.com.br/negcodes.htm   

http://www.cadcobol.com.br/db2_v_12_sqlcode_negativos.htm 

https://www.ibm.com/docs/en/db2-for-zos/11?topic=codes-sql-error
    
