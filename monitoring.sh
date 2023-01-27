# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    monitoring.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: healexan <healexan@student.42porto.com>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/01/26 10:24:49 by healexan          #+#    #+#              #
#    Updated: 2023/01/27 11:29:51 by healexan         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
arc=$(uname -a)
#Uname exibe as informações do SO, O -a é para mostrar todas informações
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
#Grep Acha todas as as linha que contenham o padrão a seguir, Sort Coloca em ordem Alfábetica, Uniq remove duplicatas, wc mosta a quantidade de W,B,C e neste caso L=Lines
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
#A opção "^" especifica que a busca deve começar no início da linha.
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
#Free exibe uso da memória e -m mostra em mebibytes, awk filtra a linha designada "$1 == Mem " e imprime o segundo campo "$2"
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
#a mesma intenção do comando de cima porem com a coluna subsequente
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
#Mesma ideia que as anteriores porem divindo a terceira linha pela segunda e fazendo vezes 100(Cento)(regra de 3), %.2f é para imprimir casas decimais(float)
#Detalhe os comandos dentro das chaves "{ }" só se realizam se o que estiver dps do == for verdadeiro
fdisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
#"df" mostra informações sobre sistema de arquivos "-Bg" mostra em GB, grep seleciona os devices e grep -v remove o(os) boot(s)
#awk neste caso calcula o total da segunda coluna e imprime o resultado final que será o espaço total do disco.
udisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
#segue o principio da linha de comando anterior porem em MB e devolve o utilizado do disco.
pdisk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft += $2} END {printf("%d"), ut/ft*100}')
#segue o principio da linha de comando anterior porem usando o printf para fazer a regra de 3 e imprimir a porcentagem.
cpul=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
#top é o "gerenciador de tarefas do unix temos outros como htop que eu prefiro por ser visualmente amigavel" -b saida bruta, n1 é a quantidade de vezes que será executado o comando.
#xargs remove os espaços em branco, awk calcula e devolve o uso do cpu em float.
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')
#who mostra informações sobre ultimo (re)boot do SO, awk imprime 3ª e 4ª coluna.
lvmt=$(lsblk | grep "lvm" | wc -l)
#lsblk lista os devices, wc -l conta a quantidade de linhas pra ser utiliado no proximo comando.
lvmu=$(if [ $lvmt -eq 0 ]; then echo no; else echo yes; fi)
#Sempre que tiver um "if" deve se fechar com o "fi"
ctcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
ulog=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link show | awk '$1 == "link/ether" {print $2}')
cmds=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
wall "	#Architecture: $arc
		#CPU physical: $pcpu
		#vCPU: $vcpu
		#Memory Usage: $uram/${fram}MB ($pram%)
		#Disk Usage: $udisk/${fdisk}Gb ($pdisk%)
		#CPU load: $cpul
		#Last boot: $lb
		#LVM use: $lvmu
		#Connexions TCP: $ctcp ESTABLISHED
		#User log: $ulog
		#Network: IP $ip ($mac)
		#Sudo: $cmds cmd"