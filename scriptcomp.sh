#!/bin/bash

ocesql MainConnect.cbl MainConnect.cob
cobc -x -static -locesql -lm MainConnect.cob -L/usr/local/lib


##-L/usr/local/lib aqui seria o meu dir. para as libs do OCESQL(Open Cobol ESQL)
