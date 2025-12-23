#!/bin/bash
TOP=`pwd`
CKSUM=`which cksum`
MD5SUM=`which md5sum`
enum_sig=".tgz .tar .gz .bz2 .bz .tbz2 .tbz .bzip2 .zip .Z .txz"
OUT_FILES="${TOP}/CKSUM_ALL_FILES.txt ${TOP}/CKSUM_ALL_ARCH_FILES.txt ${TOP}/MD5SUM_ALL_FILES.txt ${TOP}/MD5SUM_ALL_ARCH_FILES.txt"
LOOKUP_FL_IN_ARCH=${TOP}/LOOKUP_FILES_IN_ARCHS.txt
TMP_FILE=${TOP}/temp_file.txt
TMP_FILE_2=${TOP}/temp_file_2.txt

##for multidirs mode
TMP_DIR=${TOP}/temp_dir.txt 
TMP_DIR_2=${TOP}/temp_dir_2.txt
#used in unpacking script
ERRORS_FL=${TOP}/FIX_ERRORS.txt

init()
{

XZ=`which xz`
if [ -z ${XZ} ];then
	echo "ОШИБКА: Не могу найти утилиту xz"
	exit 1
else
	echo "Утилита xz: ${XZ}"
fi

TAR=`which tar`
if [ -z ${TAR} ];then
	echo "ОШИБКА: Не могу найти утилиту tar"
	exit 1
else
	echo "Утилита tar: ${TAR}"
fi

GZIP=`which gzip`
if [ -z ${GZIP} ];then
	echo "ОШИБКА: Не могу найти утилиту gzip"
	exit 1
else
	echo "Утилита gzip: ${GZIP}"
fi

ZIP=`which zip`
if [ -z ${ZIP} ];then
	echo "ОШИБКА: Не могу найти утилиту zip"
	exit 1
else
	echo "Утилита gzip: ${ZIP}"
fi

COUNT_FILES=0
COUNT_ARCH=0

for index in $OUT_FILES
do
	if [ -s $index ]; then
		rm -f $index
	fi
done

if [ -s $LOOKUP_FL_IN_ARCH ]; then
		rm -f $LOOKUP_FL_IN_ARCH
fi

if [ -f ${ERRORS_FL} ]; then
	rm -f ${ERRORS_FL}	
fi

}

exit_prog()
{
	msg="$1"
	code="$2"
	
	echo "ОШИБКА. $msg: $code"
	echo "ОСТАНОВ программы."
	exit 1
}

count_items()
{
	loop_items=0

	if [[ ! -z $1 ]];then
		
		for index in $1
		do
			loop_items=`expr $loop_items + 1`
		done
	fi
	
}

usage()
{
 	echo "USAGE:"
	echo "./prepare-unpacking-script.sh <полный путь к каталогу, содержащему архивные файлы> \ 
		<полный путь к каталогу, в который требуется распаковать архивные файлы> \
               <полный путь к скрипту распаковки> [--separator-enable] [--copy-all] [--no-multidir]"
	exit 0
}

check_cmd_param()
{
#echo "ФУНКЦИЯ: check_cmd_param()"
#проверяю входной параметр - анализируемую директорию
echo "Проверяю входные параметры"

if test -z $1
then
	echo "Введите путь до исходной директории"
	exit 1;
fi

if test -z $2
then
	echo "Введите путь до рабочей (целевой) директории"
	exit 1;
else
	echo "Удаляю файлы из рабочей директории: $2"
	rm -rf $2/*
fi

if test -z $3
then
	echo "Введите путь к скрипту распаковки архивов"
	exit 1;
else
	recur_untgz_mdr_name=`echo "$3"|awk -F"/" '{print $NF}'`

	if test -z $recur_untgz_mdr_name
	then
		echo "Введите путь к скрипту распаковки архивов"
		exit 1;
	else
		echo "Скрипт распаковки: "$recur_untgz_mdr_name
	fi
fi

if test -z $4
then
	echo "Установлен формат выходных файлов CKSUM_ALL_FILES.txt, MD5SUM_ALL_FILES.txt  - сплошной список"
	echo "Копирование файлов из каталога $1 в каталог $2 выполняться не будет"
	echo "Распаковка архивов будет осуществляться в одноименные каталоги"
	SEPARATOR_FL="NO"
	COPY_ALL_FL="NO"
	MULTIDIR="YES"
else	
	echo "Введен дополнительный параметр: "$4
	if test $4 = "--separator-enable"
	then
		echo "Установлен формат выходных файлов CKSUM_ALL_FILES.txt, MD5SUM_ALL_FILES.txt - список с разделителями по архивам"
		SEPARATOR_FL="YES"

	else
		SEPARATOR_FL="NO"
	fi
		

	if test $4 = "--copy-all"
	then
		echo "Копирование файлов из каталога $1 в каталог $2 будет выполняться"
		COPY_ALL_FL="YES"
	else
		COPY_ALL_FL="NO"
	fi
			
	if test $4 = "--no-multidir"
	then
		echo "Распаковка архивов будет осуществляться без создания одноименных каталогов"
		MULTIDIR="NO"
	else
		MULTIDIR="YES"
	fi
		
	

	if [ "$SEPARATOR_FL" = "NO" -a "$COPY_ALL_FL" = "NO" -a "$MULTIDIR" = "YES" ]; then
		exit_prog "Введен неверный дополнительный параметр $4. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi 

fi

if test ! -z $5 
then
	echo "Введен дополнительный параметр: "$5

	if test $5 = "--copy-all" 
	then
		echo "Копирование файлов из каталога $1 в каталог $2 будет выполняться"
		COPY_ALL_FL="YES"
	else
		if test -z $COPY_ALL_FL
		then
			COPY_ALL_FL="NO"
		fi
	fi

	if test $5 = "--separator-enable"
	then
		echo "Установлен формат выходных файлов CKSUM_ALL_FILES.txt, MD5SUM_ALL_FILES.txt - список с разделителями по архивам"
		SEPARATOR_FL="YES"
	else
		if test -z $SEPARATOR_FL
		then
			SEPARATOR_FL="NO"
		fi
	fi

	if test $5 = "--no-multidir"
	then
		MULTIDIR="NO"
	else
		if test -z $MULTIDIR
		then
			MULTIDIR="YES"
		fi
	fi
	
	if [ "$SEPARATOR_FL" = "NO" -a "$COPY_ALL_FL" = "NO" ]; then
		exit_prog "Введен неверный дополнительный параметр $5. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi 

	if [ "$COPY_ALL_FL" = "NO" -a "$MULTIDIR" = "YES" ]; then
		exit_prog "Введен неверный дополнительный параметр $5. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi

	if [ "$SEPARATOR_FL" = "NO" -a "$MULTIDIR" = "YES" ]; then
		exit_prog "Введен неверный дополнительный параметр $5. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi
	
else
	if test -z $COPY_ALL_FL
	then
		COPY_ALL_FL="NO"
	fi

	if test -z $SEPARATOR_FL
	then
		SEPARATOR_FL="NO"
	fi

	if test -z $MULTIDIR
	then
		MULTIDIR="YES"
	fi
fi


if test ! -z $6 
then
	echo "Введен дополнительный параметр: "$6
	if test $6 = "--copy-all" 
	then
		echo "Копирование файлов из каталога $1 в каталог $2 будет выполняться"
		COPY_ALL_FL="YES"
	else
		if test -z $COPY_ALL_FL
		then
		COPY_ALL_FL="NO"
		fi
	fi

	if test $6 = "--separator-enable"
	then
		echo "Установлен формат выходных файлов CKSUM_ALL_FILES.txt, MD5SUM_ALL_FILES.txt - список с разделителями по архивам"
		SEPARATOR_FL="YES"
	else
		if test -z $SEPARATOR_FL
		then
			SEPARATOR_FL="NO"
		fi
	fi

	if test $6 = "--no-multidir"
	then
		MULTIDIR="NO"
	else
		if test -z $MULTIDIR
		then
			MULTIDIR="YES"
		fi
	fi
	
	
	if [ "$SEPARATOR_FL" = "NO" ]; then
		exit_prog "Введен неверный дополнительный параметр $6. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi

	if [ "$COPY_ALL_FL" = "NO" ]; then
		exit_prog "Введен неверный дополнительный параметр $6. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi

	if [ "$MULTIDIR" = "YES" ]; then
		exit_prog "Введен неверный дополнительный параметр $6. Доступные параметры: <--copy-all>|<--separator-enable>|<--no-multidir>"
	fi
	
else
	if test -z $COPY_ALL_FL
	then
		COPY_ALL_FL="NO"
	fi

	if test -z $SEPARATOR_FL
	then
		SEPARATOR_FL="NO"
	fi

	if test -z $MULTIDIR
	then
		MULTIDIR="YES"
	fi
fi
}
cp_simple_files()
{
echo "ФУНКЦИЯ: cp_simple_files()"
FIRST_DIR="$1"
SECOND_DIR="$2"
echo "Ищу все файлы кроме архивных с раширениями $enum_sig"
	find $FIRST_DIR ! -name "*.tgz" ! -name "*.tar" \
			! -name "*.gz" ! -name "*.bz2" \
			! -name "*.bz" ! -name "*.tbz2" \
			! -name "*.tbz" ! -name "*.bzip2"\
			! -name "*.zip" ! -name "*.Z" \
			! -name "*.txz" -type f > ${TMP_FILE}
	COUNT_FILES=`cat ${TMP_FILE}|wc -l`
	echo $COUNT_FILES
	while read index
	do
		if [ ! -f "${index}" ]; then
			exit_prog "Файл  ${index} не существует"
		fi
		#echo "${index}"
		file_dir=`dirname "${index}"`
		arch_file_name=`basename "${index}"`
		if [ ! -d "${file_dir}" ]; then
			exit_prog "Каталог не существует" "${file_dir}"
		fi
		echo "file name:" "${arch_file_name}"
		echo "dir name:" "${file_dir}"
		echo "Каталог для файла $arch_file_name :  $file_dir"
		echo "Исходных каталог с архивными файлами: $FIRST_DIR"
		if [ "$file_dir" = "$FIRST_DIR" ]; then
			mk_wd_flag="${SECOND_DIR}"
			echo "Рабочий каталог создавать не нужно."
		else
			delta_wd=`echo "$file_dir"|awk -F$FIRST_DIR '{print $2}'`
			mk_wd_flag="${SECOND_DIR}${delta_wd}"
			echo "Нужно создать рабочий каталог :$mk_wd_flag"
		fi

		work_dir="${mk_wd_flag}"
		
		if [ -d "$work_dir" ]; then
			echo "Рабочий каталог уже существует:$work_dir"
		else
			echo "Создаю рабочий каталог:"$work_dir
			mkdir -p "$work_dir"
		fi

		echo "Копирую исходный файл $index в каталог $work_dir"
		cp "$index" "$work_dir" || exit 1

		$CKSUM "${work_dir}/${arch_file_name}" >> "${TOP}/CKSUM_ALL_FILES.txt"
		$MD5SUM "${work_dir}/${arch_file_name}" >> "${TOP}/MD5SUM_ALL_FILES.txt"

	done < ${TMP_FILE}
	
	echo "Cкопированно $COUNT_FILES файлов из каталога $FIRST_DIR в каталог $SECOND_DIR:"
	echo ""

	if [ -f ${TMP_FILE} ]; then
		rm -f ${TMP_FILE}
	fi
}

	#если выходной файл уже существует, то удаляю его
main_loop()
{
	echo "ФУНКЦИЯ: main_loop()"
	FIRST_DIR="$1"
	SECOND_DIR="$2"
	#ищу все файлы с расширениями *.tgz *.tar *.gz *.bz2 *.bz *.tbz2 *.tbz *.bzip2 *.zip *gzip *.txz
	echo "Ищу все файлы с расширениями $enum_sig в каталоге: $FIRST_DIR"

	if [ -f ${TMP_FILE} ]; then
		rm -f ${TMP_FILE}
	fi

	for index in $enum_sig
	do
		echo "find $FIRST_DIR -name \"*${index}\" -type f >> ${TMP_FILE}"
		find $FIRST_DIR -name "*${index}" -type f >> ${TMP_FILE}
	done
	
	COUNT_ARCH=`cat ${TMP_FILE}|wc -l`
	echo "Найдено ${COUNT_ARCH} архивных файлов:"
	echo "`cat ${TMP_FILE}`"

	#определяю расширение файл и соответствующей командой распаковываю архив
	#echo "Определяю расширение архивного файла"

	while read index
	do
		if [ ! -f "${index}" ]; then
			exit_prog "Файл  ${index} не существует"
		else
			echo "Считаю контрольную сумму архива: ${index}"
			$CKSUM "${index}" >> "${TOP}/CKSUM_ALL_ARCH_FILES.txt"
			$MD5SUM "${index}" >> "${TOP}/MD5SUM_ALL_ARCH_FILES.txt"
		fi

		typefl=`echo "${index}"|awk -F"." '{print $NF}'`

		echo "Анализирую тип архива ${typefl} файла ${index}"

		file_dir=`dirname "${index}"`
		arch_file_name=`basename "${index}"`

		if [ ! -d "${file_dir}" ]; then
			exit_prog "Каталог не существует" "${file_dir}"
		fi

		echo "Каталог для файла ${arch_file_name} :  ${file_dir}"
		echo "Исходных каталог с архивными файлами: ${FIRST_DIR}"

		if [ "${file_dir}" = "${FIRST_DIR}" ]; then

			#for MULTIDIR_SETTINGS
			if [ "$MULTIDIR" = "YES" ]; then
				mk_wd_flag="${SECOND_DIR}"/"${arch_file_name}"
			else
				mk_wd_flag="${SECOND_DIR}"
			fi
			echo "Вложенный каталог создавать не нужно."
		else
			delta_wd=`echo ${file_dir}|awk -F"${FIRST_DIR}" '{print $2}'`

			#for MULTIDIR_SETTINGS
			if [ "$MULTIDIR" = "YES" ]; then
				mk_wd_flag="${SECOND_DIR}""${delta_wd}"/"${arch_file_name}"
			else
				mk_wd_flag="${SECOND_DIR}""${delta_wd}"
			fi
			echo "Нужно создать вложенный каталог :${mk_wd_flag}"
		fi

		work_dir="${mk_wd_flag}"
		
		if [ -d "${work_dir}" ]; then
			echo "Рабочий каталог уже существует:${work_dir}"
		else
			echo "Создаю каталог:\"${work_dir}\""
			mkdir -p "${work_dir}"||exit 1
		fi

		echo "Копирую архив ${index} в каталог \"${work_dir}\""
		cp "${index}" "${work_dir}" || exit 1
	
		echo "Копирую скрипт $3 в каталог \"$work_dir\""
		cp "${3}" "${work_dir}" || exit 1
	
		echo "Перехожу в директорию каталога: $work_dir"
		cd "${work_dir}" || exit

		#echo "Считаю контрольную сумму исходного архива в рабочей директории "`pwd`
		#$CKSUM "${work_dir}"/"${arch_file_name}" >> "${TOP}/CKSUM_ALL_ARCH_FILES.txt"
		#$MD5SUM "${work_dir}"/"${arch_file_name}" >> "${TOP}/MD5SUM_ALL_ARCH_FILES.txt"

		
		#for MULTIDIR_SETTINGS
		if [ "$MULTIDIR" = "NO" ]; then
			ls -1 ${work_dir} > ${TMP_DIR}
			#echo "Каталог 1: `cat ${TMP_DIR}`"
		fi

		echo "Запускаю скрипт распаковки из директории `pwd`"
		sh ./${recur_untgz_mdr_name} "${TOP}" -rm-tar || exit 1
		echo "Удаляю скрипт распаковки из директории "`pwd`
		rm -f ./${recur_untgz_mdr_name} || exit 1
	
		if [ "$MULTIDIR" = "NO" ]; then
			ls -1 ${work_dir} > ${TMP_DIR_2}
			#echo "Каталог 2: `cat ${TMP_DIR_2}`"
		fi

		if [ "$MULTIDIR" = "NO" ]; then
			
			#echo "СРАВНЕНИЕ КАТАЛОГОВ `comm -13 ${TMP_DIR} ${TMP_DIR_2}`"

			for index_dir in `comm -13 ${TMP_DIR} ${TMP_DIR_2}`
			do
				if [ -d "${work_dir}/${index_dir}" ];then
					#echo "КАТАЛОГ: ${work_dir}/${index_dir}"
					if [ ${SEPARATOR_FL} = "YES" ]; then
					echo "" >> "${TOP}/CKSUM_ALL_FILES.txt"
					echo "Архив ${index}/${index_dir} содержит файлы:" >> "${TOP}/CKSUM_ALL_FILES.txt"

					echo "" >> "$TOP/MD5SUM_ALL_FILES.txt"
					echo "Архив ${index}/${index_dir} содержит файлы:" >> "$TOP/MD5SUM_ALL_FILES.txt"

					echo "Считаю контрольную сумму файлов в директории ${index}/${index_dir}"
					find "${work_dir}/${index_dir}" -xtype f -print0|xargs -0 $CKSUM >> "${TOP}/CKSUM_ALL_FILES.txt"||exit 1
					find "${work_dir}/${index_dir}" -xtype f -print0|xargs -0 $MD5SUM >> "${TOP}/MD5SUM_ALL_FILES.txt"||exit 1
				else
					exit_prog "Каталог не существует" "${work_dir}/${index_dir}"
				fi
			fi
			done
		else
			if [ ${SEPARATOR_FL} = "YES" ]; then
				echo "" >> "${TOP}/CKSUM_ALL_FILES.txt"
				echo "Архив ${index} содержит файлы:" >> "${TOP}/CKSUM_ALL_FILES.txt"

				echo "" >> "$TOP/MD5SUM_ALL_FILES.txt"
				echo "Архив $index содержит файлы:" >> "$TOP/MD5SUM_ALL_FILES.txt"
			fi
	
			echo "Считаю контрольную сумму файлов в директории "`pwd`

			find "${work_dir}" -xtype f -print0|xargs -0 $CKSUM >> "${TOP}/CKSUM_ALL_FILES.txt"||exit 1
			find "${work_dir}" -xtype f -print0|xargs -0 $MD5SUM >> "${TOP}/MD5SUM_ALL_FILES.txt"||exit 1
		fi

		
		echo "Возвращаюся в директорию: "$TOP
		cd $TOP

	done < ${TMP_FILE}
	
	if [ -f ${TMP_FILE} ]; then
		rm -f ${TMP_FILE}
	fi

	if [ -f ${TMP_FILE_2} ]; then
		rm -f ${TMP_FILE_2}
	fi

	if [ -f ${TMP_DIR} ]; then
		rm -f ${TMP_DIR}
	fi

	if [ -f ${TMP_DIR_2} ]; then
		rm -f ${TMP_DIR_2}
	fi

	echo "Распаковка архивов завершена :))"
} #end of main_loop()

######################## MAIN ##########################

if [ $# -lt 3 ];then
	usage
fi

check_cmd_param "$1" "$2" "$3" "$4" "$5" "$6"
init

#echo "COPY_ALL_FL: $COPY_ALL_FL"
#echo "SEPARATOR_FL: $SEPARATOR_FL"

if [ $COPY_ALL_FL = "YES" ]; then
	cp_simple_files "$1" "$2"
fi

main_loop "$1" "$2" "$3"