#!/bin/bash

######################################################################
#
# status : script para mostrar o status do sistema:
# 
# Espaço em disco; df
# Espaço ocupado pelos diretorios e ficheiros; du
# Memoria; free
# Temperatura da cpu; sensors
# Tempo e carga do sistema; uptime
# Conexão ou banda atual de download e upload; speedtest-cli ou simples ping
#
# Pode tanto ser usado como usuário normal, como pelo root
#
# Paulo Henrique Pedro
#
#######################################################################

#######################################################################
#
# Constantes
PROGRAMA="$(basename "$0")"
DATA="$(date "+%d-%m-%Y %H:%M" )"
TITLE="Relatório do sistema para $HOSTNAME"
GERADO="Relatório gerado: $DATA, por $USER"
#
#######################################################################

#######################################################################
#
# Funções

# ajuda
usg () {
	echo -e "\n$PROGRAMA: uso: $PROGRAMA [ -f ] [ -h ].

Script que analisa o status do sistema:

Espaço ocupado em disco;
Espaço ocupado por arquivos no HOME;
Memória livre, ocupada em cache/buffer;
Temperatura do sistema;
Tempo de atividade e carga média do sistema;
Conexão com o ping, ou banda de download e upload (tem que ter programa speedtest-cli).

Se o script for chamado com o parâmetro [ -f ], o script enviará a saída
para um arquivo de texto no seu HOME chamado "/home/usuario/status.txt", ou,
"/root/status_root.txt", caso o script seja rodado como usuário root.
Se o script for chamado com o parâmetro [ -h ], então este mesmo texto
será mostrado.
Caso o script seja chamado sem parâmetro algum, então a saída simplesmente
será exibida na tela."
	exit
}	

# Temp e carga
tempo_carga () {
	echo -e "\nTempo e carga média do sistema:"
	cat <<- _EOF_
		$(uptime)
	_EOF_
		return
}

#  Espaço em disco
disk_usage () {
	echo -e "\nEspaço ocupado em disco:"
	cat <<- _EOF_
		$(df -h)
	_EOF_
		return
}

# Espaço do home
home_space () {
	local format="%8s%10s%10s\n"
	local i dir_list total_files total_dirs total_size user_name
	
	
	if [[ "$(id -u)" -eq 0 ]]; then
		dir_list=/home/*
		user_name="Todos os usuários"
	else
		dir_list="$HOME"
		user_name="$USER"
	fi
	
	
	echo -e "\nUtilização de espaço no HOME ($user_name):"
	
	for i in $dir_list; do
	
		total_files="$(find "$i" -type f 2>/dev/null | wc -l)"
		total_dirs="$(find "$i" -type d 2>/dev/null | wc -l)"
		total_size="$(du -sh "$i" 2>/dev/null | cut -f 1)"
		
		
		echo -e "\n$i"
		printf "$format" "Diretórios" "Arquivos" "Tamanho"
		printf "$format" "--------------" "------------" "-------------"
		printf "$format" "$total_dirs" "$total_files" "$total_size"
	done
	return
}

#conexão
conect () {
	echo -e "\nConexão......."
	if ! ping -c2 www.google.com &>/dev/null; then
		echo -e "\nParece estar desconectado[a].....
Não iremos proseguir com o teste."
	else
		echo -e "\nConexão encontrada........."
	fi
		
	if [[ -n "$(which speedtest-cli)" ]]; then
		echo -e "\nVelocidade de download e upload, (speedtest-cli)......"
		speedtest-cli
	else
		echo -e "\nQualidade da connexão usando o ping......."
		ping -c5 www.google.com
	fi
	return
}

# Memória livre e ocupada
mem () {
	echo -e "\nMemória total, ocupada e livre:"
	cat <<- _EOF_
		$(free -h)
	_EOF_
		sleep 3
		return
}

# temp
temp () {
	echo -e "\nTemperatura atual:"
	cat <<- _EOF_
		$(sensors)
	_EOF_
		return
}

#programa
prog () {
	echo -e "\n$TITLE"
	echo -e "\n$GERADO"
	tempo_carga
	disk_usage
	home_space
	conect
	mem
	temp
}
#
######################################################################

######################################################################
#
# Programa
if [[ -z "$1" ]]; then
	prog
	echo -e "\nFinalizamos por aqui......"
	sleep 3
	exit
fi

# Se tem parâmetro qual foi?
if [[ -n "$1" ]]; then
	case "$1" in
		-f)	arquivo=1
			;;
		-h)	usg
			exit
			;;
		*)	usg
			exit 1
			;;
	esac
fi

# Tratando do parâmetro "-f (arquivo)"
if [[ -n "$arquivo" ]]; then
	if [[ "$(id -u)" -eq 0 ]]; then
		echo -e "\nAguarde enquanto criamos o arquivo com os dados......
		
Pode demorar um pouco......"
		prog &>/root/status_root.txt
		echo -e "\nArquivo salvo em /root/status_root.txt."
	else
		echo -e "\nAguarde enquanto criamos o arquivo com os dados......
		
Pode demorar um pouco......"
		prog &>/home/$USER/status.txt
		echo -e "\nArquivo salvo em /home/$USER/status.txt."
	fi
	sleep 2
	echo -e "\nSaíndo agora do programa......"
fi
#
######################################################################		
#		

exit
