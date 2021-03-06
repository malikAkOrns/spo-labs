#!/bin/bash

#Функция для рекурсивного поиска
function chart() {
	IFS=$'\n'  #разбиение на имена
	for files in $@
	do
		echo "$files"  #вывод в консоль
		if [[ -d "$files" ]]	#поиск файлов в директории
		then
			cd "$files"
			chart $(ls "$(pwd)")
			cd ..
		fi		
		if [[ -f $files ]]
		then
    		Name=$(echo "$files")
			Extension=${files##*.}
			Date=$(stat -c%s "$files")
			Size=$(stat -c "%y" "$files" | awk '{print $1}')
			Duration="None"

             #цикл для видео-файлов
			if file -ib "$files" | grep -qE 'video'
			then
				Duration=$(ffprobe -i "$files" -show_entries format=duration -v quiet -of csv="p=0") #используем ffprobe для определения продолжительности           
			elif file -ib "$files" | grep -qE 'audio' #аудио
			then
				Duration=$(mp3info -p "%S\n" "$files") #используем mp3info для опред продолжительности аудио
	 		fi


			Dir=$(pwd)	# смотримм, где находимся		
			cd $start_dir
			printf "$Dir\t$Name\t$Extension\t$Size\t$Date\t$Duration\n" >> output.xls #заголовок таблицы
			cd "$Dir" #запись
		fi
	done
}
start_dir=$(pwd)
rm -f ./output.xls #удаляем одноименный
printf "Dir\tName\tExtension\tSize\tLast modify date\tDuration (sec)\n" >> ./output.xls # заголовок
chart "$1" # получаем аргумент
echo -e "\nDONE!"
