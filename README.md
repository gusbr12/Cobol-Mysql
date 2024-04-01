# CobolMysql
COBOL - Conexão MYSQL via Postgresql remoto
1.1 - SISTEMA e PROGRAMAS.
    
    (DIST. atuais não são compativeis com a versão necessária do GnuCOBOL)

 ° SISTEMA OPERACIONAL: Linux Mint 21.2 Victoria Cinnamon 5.8.4 
 ° VERSÃO DO COBOL: GnuCOBOL 3.1.2.0
 ° VERSÃO DO GNU COMPILER: GCC version 11.4.0
 ° VERSÃO DO MYSQL: Mysql  Ver 8.0.35
 ° VERSÃO DO POSTGRESQL: PostgreSQL 14.9    
 ° OPEN COBOL ESQL(PRE-COMPILADOR): https://github.com/opensourcecobol/Open-COBOL-ESQL



1.2 - CONFIGURAÇÃO e AVISOS.

 -  Não é recomendado usar o 'sudo apt update' no terminal APÓS instalar o GnuCOBOL, senão, corre o risco de atualizar o compilador(COBOL) e as funções para gerar arquivos indexados
    pararem de funcionar (ler e gerar arquivos indexados está indisponivel na versão atual do GnuCobol (4.0)).    
 -  O pré-compilador Open Cobol ESQL possui um manual nos arquivos de instalações(README), para testar basta digitar o comando ocesql no terminal e deve retornar as infos do pré-com
    pilador.  
 -  Todos os programas foram instalados pelo terminal com excessão do OPEN COBOL ESQL - (sudo apt install(***)).

 -  Será necessário editar as variáveis do sistema, caso não forem editadas, após a instalação de diversos programas ocorre um conflito de diretorios após uma compilação:
                _______________________________________________________ 
               |                                                       | 
               | export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib|
               |_______________________________________________________|

    
 -  O arquivo "sqlca.cbl"(se encontra na pasta "COPY" do arquivo raiz do pré-compilador ESQL) deve estar presente no mesmo diretório do código que vá utilizar o pre-compilador ESQL.
 -  Há outra forma de utilizar o arquivo sem precisar manter ele no mesmo diretório do código:
                 ________________________________________________________
                |                                                        |
                | export COBCPY= *caminho da raiz do pré-compilador*/copy|
                |________________________________________________________|    
    Importante!
            Todos os programas compilados após editar a variavel do sistema(COBCPY) vão utilizar 
            o mesmo diretório para buscar TODOS os 'COPY', então, é recomendado utilizar uma pasta
            fixa para colocar todos no mesmo diretório.
    !Importante






1.3 - COMPILAÇÃO e MODOS DE USO. 

 -  Para compilar os programas foi criado um script em ShellScript com todos os parâmetros necessários (scriptcomp.sh).
 -  O programa que obter conteúdo do OPEN ESQL deve ser compilado com os parâmetros '-static' e '-locesql'.

 -  O pré-compilador ESQL não vai reconhecer nenhuma variável que for usada com os comandos ESQL(EXEC SQL, SELECT, ETC) se estiver fora da área de declaração SQL.  
                                                                                                
                   77  WS-COUNTER                    pic 9(02).                              
                   
                   EXEC SQL BEGIN DECLARE SECTION END-EXEC.                                         |   Apresentará erro se:  |

                   01  wPOSICAO                PIC  9(04).                        ° Declarar uma variável no level 77, pois, não é aceito na sessão de declaração do SQL.                       
                   01  wSEQUENCIA              PIC  9(06).                        ° Direcionar um File-ID através de uma variável não será aceito.
                   01  IDSELECT                PIC  9(04).                          EXEMPLO:
                   01  IDSELECT2               PIC  9(04).                                  77    WS77-RV000000-IDX PIC X(13) VALUE "RV000000.IDX".                             
                   01  DATASELECT              PIC  9(10).                          
                   01  HORASELECT              PIC  9(06).                        ° Variáveis que vão armazenar dados na memória devem ser declaradas 
                   01  HORASELECT2             PIC  9(06).                          fora da sessão de declaração do SQL.        
                   01  hrFORMAT                PIC  9(08).
                   01  hrFORMATb               PIC  9(08).                        ° Para usar variáveis com dados armazenados na memória deve ser usado da seguinte forma:
                   01  IDMENU                  PIC  9(02).                                                      
                   01  DBNAME                  PIC  X(30) VALUE SPACE.                       MOVE WS03-RECPOSICAO   TO wPOSICAO                                                    
                   01  USERNAME                PIC  X(30) VALUE SPACE.                       MOVE WS03-RECSEQUENCIA TO wSEQUENCIA   <- Move a var. para outra que esteja dentro da 
                   01  PASSWD                  PIC  X(10) VALUE SPACE.                                                                 sessão de declaração do SQL.
                    
                   EXEC SQL END DECLARE SECTION END-EXEC.                                     EXEC SQL                                               
                                                                                                   DECLARE C1 CURSOR FOR
                                                                                                   SELECT RecID, RecReg, RecData, RecHora, RecPosicao,
                                                                                                   RecSequencia
                                                                                                   FROM Arqrec_MYSQL
                                                                                                   WHERE (RecPosicao = :wPOSICAO AND  <-- Deve ser usada com ":" para ser reconhecida.
                                                                                                   RecSequencia = :wSEQUENCIA)  <--------/  (:wPOSICAO, :wSEQUENCIA)
                                                                                                   ORDER BY RecID, RecData DESC
                                                                                              END-EXEC
                    
 -  Após ser compilado, o programa será executado através do script 'reca.sh'.         



1.4 - GUIA DO ESQL

SQLCODE: https://www.ibm.com/docs/en/db2-for-zos/11?topic=codes-sql-error

    0 - A instrução foi executada sem erros.
    1 - A instrução foi executada, mas foi gerado um aviso. Os valores das flags SQLWARN devem ser verificados para determinar o tipo de erro.
    100 - Não foram encontrados dados correspondentes à consulta ou o final do conjunto de resultados foi alcançado. Nenhuma linha foi processada.
    < 0 (negativo) - A instrução não foi executada devido a um erro de aplicativo, banco de dados, sistema ou rede.

Fonte dos códigos de erro: http://www.cadcobol.com.br/negcodes.htm   
                           http://www.cadcobol.com.br/db2_v_12_sqlcode_negativos.htm 
                           https://www.ibm.com/docs/en/db2-for-zos/11?topic=codes-sql-error
    