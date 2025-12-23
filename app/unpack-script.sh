#!/bin/bash
set +x
TOP=`pwd`
CKSUM=`which cksum`
MD5SUM=`which md5sum`
LOOKUP_FL_IN_ARCH="${1}"/LOOKUP_FILES_IN_ARCHS.txt
TMP_FILE=${1}/temp_arch_file.txt
ERRORS_FL="${1}"/FIX_ERRORS.txt
fix_errors()
{
	echo "=====`date`=====" >> ${ERRORS_FL}
	echo "ОШИБКА при распаковке архива \"$1\"" >> ${ERRORS_FL}
	echo "ОПЕРАЦИЯ:$2 $1" >> ${ERRORS_FL}
	$2 $1 >> ${ERRORS_FL} 2>&1
	echo "КОД ВОЗВРАТА:$?" >> ${ERRORS_FL}
	cp $1 $1.error_unpack||exit 1
	echo "Архив оставлен без изменений и переименован в файл \"$1.error_unpack\" " >> ${ERRORS_FL}
}

if test $# -eq 0
then 
	echo "USAGE: You must give a start point dir, which to write logs"
exit 1
fi
echo "Запущен скрипт распаковки архивов из каталога \"${TOP}\""
#проверяю входной параметр - анализируемую директорию
echo "Проверяю входной параметр - анализируемую директорию"
if test -z ${1}
then
	echo "WARNING: You must give a start point dir, which to write logs"
	exit 1;
else
	OUT_FILES="${1}/CKSUM_ALL_FILES.txt ${1}/CKSUM_ALL_ARCH_FILES.txt ${1}/MD5SUM_ALL_FILES.txt ${1}/MD5SUM_ALL_ARCH_FILES.txt"
	echo "КОНТРОЛЬ:${1} : $OUT_FILES"
	for index in $OUT_FILES
	do
		echo "Контроль: ${index}"
		if [ ! -s ${index} ]; then
			echo "Не могу найти файл лога ${index}"
		fi
	done
        #exit 1;
fi
	enum_sig=".tgz .tar .gz .bz2 .bz .tbz2 .tbz .bzip2 .zip .Z .txz"
	#ищу все файлы с расширениями *.tgz, *.tar, *.tar.gz
	echo "Ищу все файлы с расширениями *.tgz, *.tar, *.tar.gz, *.gz *.bz2 *.bz *.tbz2 *.tbz *.bzip2 *.zip  *.txz в каталоге: "$1
	#next_iter="false"

if [ -f ${TMP_FILE} ];then
	rm -f ${TMP_FILE}
fi

for index in ${enum_sig}
do
	echo "find \"${TOP}\" -name \"*${index}\" -type f"
	find "${TOP}" -name "*${index}" -type f >> ${TMP_FILE}
done

#while read index_i
#do
while true
do
	#echo "Определяю расширение архивного файла \"${index_i}\" и его распаковываю"
	
	while read index_j
	do
		echo "Определяю расширение архивного файла \"${index_j}\" и его распаковываю"

		#echo "Работаю с файлом \"${index_j}\""
		typefl=`echo "${index_j}"|awk -F"." '{print $NF}'`
		file_dir=`dirname "${index_j}"`
		file_name=`basename "${index_j}"`

		if [ ! -f "${index_j}" ]; then
			echo " Файл не найден: \"${index_j}\""
			exit 1
		fi


		if [ ! -d "${file_dir}" ]; then
			echo "Каталог не найден: \"${file_dir}\""
			exit 1
		fi
			
		full_path="${index_j}"
		echo "Поиск распаковщика для файла \"${full_path}\" по тип-признаку \".${typefl}\""

		echo "Архив \"${index_j}\" содержит файлы:" >> $LOOKUP_FL_IN_ARCH
		
		#for *.bz2 *.bz *.tbz2 *.tbz *.bzip2, tar.bz
		if test "."$typefl = ".bz"
		then
			tmp_cell=`echo "${full_path}"|grep ".tar.bz"`
			echo "${tmp_cell}"
	
			if test -z ${tmp_cell}
			then
			#for ".bz2", ".bz", "bzip2"
				echo "Блок .bz: Распаковываю \"${full_path}"\"
				echo "Смена каталога на \"${file_dir}\""
				cd "${file_dir}"|| exit 1
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				bzip2 -tf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "bzip2 -df \"${full_path}\""
				bzip2 -d -f -k "${full_path}"||fix_errors "${full_path}" "bzip2 -tvv"
				echo "Возврат в прежний каталог ${TOP}"
				cd ${TOP}||exit 1
			else
				echo "Блок .tar.bz: Распаковываю \"${full_path}\""
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				tar -tjf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "tar -C \"${file_dir}\" -xjf \"${full_path}\""
				tar -C "${file_dir}" -xjf "${full_path}"||fix_errors "${full_path}" "tar -tjf"
			fi	
		fi

		if test "."${typefl} = ".bz2"
		then
			tmp_cell=`echo "${full_path}"|grep ".tar.bz2"`
			echo "${tmp_cell}"
	
			if test -z ${tmp_cell}
			then
			#for ".bz2", ".bz", "bzip2"
				echo ".bz2: Распаковываю \"${full_path}\""
				echo "Смена каталога на \"${file_dir}\""
				cd "${file_dir}"||exit 1
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				bzip2 -tf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "bzip2 -df \"${full_path}\""
				#bzip2 -df "${full_path}"||exit 1
				bzip2 -d -f -k "${full_path}"||fix_errors "${full_path}" "bzip2 -tvv"
				echo "Возврат в прежний каталог ${TOP}"
				cd ${TOP}||exit 1
			else
				echo "Блок .tar.bz2: Распаковываю "$full_path
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				tar -C "${file_dir}" -tjf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "tar -C \"${file_dir}\" -xjf \"${full_path}\""
				tar -C "${file_dir}" -xjf "${full_path}"||fix_errors "${full_path}" "tar -tjf"
			fi	
		fi

		if test "."${typefl} = ".bzip2"
		then
			tmp_cell=`echo "${full_path}"|grep ".tar.bzip2"`
			echo ${tmp_cell}
	
			if test -z ${tmp_cell}
			then
			#for ".bz2", ".bz", "bzip2"
				echo "Блок .bzip2: Распаковываю \"${full_path}\""
				echo "Смена каталога на \"${file_dir}\""
				cd "${file_dir}"||exit 1
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				bzip2 -tf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "bzip2 -df \"${full_path}\""
				bzip2 -df "${full_path}"||fix_errors "${full_path}" "tar -tvv"
				echo "Возврат в прежний каталог ${TOP}"
				cd ${TOP}||exit 1
			else
				echo "Блок .tar.bzip2: Распаковываю \"${full_path}\""
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				tar -tjf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "tar -C \"${file_dir}\" -xjf \"${full_path}\""
				tar -C "${file_dir}" -xjf "${full_path}"||fix_errors "${full_path}" "tar -tjf"
			fi
		fi

		if test "."${typefl} = ".tbz"
		then
			echo "Блок .tbz: Распаковываю \"${full_path}\""
			echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			tar -tjf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			echo "tar -C \"$file_dir\" -xjf \"${full_path}\""
			tar -C "${file_dir}" -xjf "${full_path}"||fix_errors "${full_path}" "tar -tjf"
		fi

		if test "."${typefl} = ".tbz2"
		then
			echo "Блок .tbz2: Распаковываю ${full_path}"
			echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			tar -tjf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			echo "tar -C \"${file_dir}\" -xjf \"${full_path}\""
			tar -C "${file_dir}" -xjf "${full_path}"||fix_errors "${full_path}" "tar -tjf"
		fi

		#for .zip .tgz, .tar.gz, .gz, .txz, .tar

		if test "."${typefl} = ".zip"
		then
			echo "Блок .zip: Распаковываю \"${full_path}\""
			echo "Смена каталога на \"${file_dir}\""
			cd "${file_dir}"||exit 1
			echo "Текущий каталог: `pwd`" >> $LOOKUP_FL_IN_ARCH 2>&1
			unzip -l "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			echo "unzip \"${full_path}\""
			unzip -o -K "${full_path}"||fix_errors "${full_path}" "unzip -t"
			echo "Возврат в прежний каталог ${TOP}"
			cd ${TOP}
		fi

		if test "."${typefl} = ".tgz"
		then
			echo "Блок tgz: Распаковываю \"${full_path}\""
			echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			tar -tzf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			echo "tar -C \"${file_dir}\" -xzf \"${full_path}\""
			tar -C "${file_dir}" -xzf "${full_path}"||fix_errors "${full_path}" "tar -tzf"
		fi

		if test "."${typefl} = ".txz"
		then
			echo "Блок txz: Распаковываю \"${full_path}\""
			echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			xz -tk "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			#echo "tar -C \"${file_dir}\" -xzf \"${full_path}\""
			#tar -C "${file_dir}" -xzf "${full_path}"||exit 1
			echo "xz -dk ${full_path}"
			xz -dk ${full_path}||fix_errors "${full_path}" "unxz -t"
		fi
	
		if test "."${typefl} = ".gz"
		then
			tmp_cell=`echo "${full_path}"|grep ".tar.gz"`
			echo $tmp_cell
	
			if test -z $tmp_cell
			then
			#for .gz
				echo "Блок .gz: Распаковываю \"${full_path}\""
				echo "Смена каталога на \"${file_dir}\""
				cd "${file_dir}"||exit 1
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				#gunzip -t-v "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				gunzip -l "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "gunzip \"${full_path}\""
				gunzip -f "${full_path}"||fix_errors "${full_path}" "gunzip -t"
				echo "Возврат в прежний каталог ${TOP}"
				cd ${TOP}
			else
			#for .tar.gz
				echo "Блок tar.gz: Распаковываю \"${full_path}\""
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				tar -tzf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "tar -C \"${file_dir}\" -xzf ${full_path}"
				tar -C "${file_dir}" -xzf "${full_path}"||fix_errors "${full_path}" "tar -tzf"	
			fi
		fi

		if test "."${typefl} = ".Z"
		then
			tmp_cell=`echo "${full_path}"|grep ".tar.Z"`
			echo $tmp_cell
	
			if test -z $tmp_cell
			then
			#for .Z
				echo "Блок .Z: Распаковываю \"${full_path}\""
				echo "Смена каталога на \"${file_dir}\""
				cd "${file_dir}"||exit 1
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				#gunzip -t-v "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				gunzip -l "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "gunzip \"${full_path}\""
				gunzip -f "${full_path}"||fix_errors "${full_path}" "gunzip -t"
				echo "Возврат в прежний каталог ${TOP}"
				cd ${TOP}
			else
			#for .tar.Z
				echo "Блок tar.Z: Распаковываю \"${full_path}\""
				echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				tar -tzf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
				echo "tar -C \"${file_dir}\" -xzf ${full_path}"
				tar -C "${file_dir}" -xzf "${full_path}"||fix_errors "${full_path}" "tar -tzf"	
			fi
		fi

		if test "."${typefl} = ".tar"
		then
			echo "Блок .tar: Растариваю \"${full_path}\""
			echo "Текущий каталог: `pwd`" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			tar -tf "${full_path}" >> ${LOOKUP_FL_IN_ARCH} 2>&1
			echo "tar -C \"${file_dir}\" -xf ${full_path}"
			tar -C ${file_dir} -xf ${full_path}||fix_errors "${full_path}" "tar -tf"
		fi

		echo "Удаляю исходный архив \"${full_path}\""
		rm -f "${full_path}"
	
	done < ${TMP_FILE} ###index_j
		#Конец цикла определения расширения архивного файла и его распаковки"

#	Если второй параметр не задан, то разархивация выполняется только до первого уровня
	if test $# -eq 1
	then
		break
	fi
	echo " " >> ${LOOKUP_FL_IN_ARCH} 2>&1

	echo "Повторный поиск архивных файлов с расширениями $enum_sig в каталоге: `pwd`"
	
	if [ -f ${TMP_FILE} ]; then
		rm -f ${TMP_FILE}
	fi
	
	for index in ${enum_sig}
	do
		echo "find \"${TOP}\" -name \"*${index}\" -type f"
		find "${TOP}" -name "*${index}" -type f >> ${TMP_FILE}
	done
	enum_fl=`cat ${TMP_FILE}`
	if [ -z $enum_fl ]; then
		echo "Архивных файлов не найдено"
		break
	else
		echo "Найдены новые архивные файлы:"
		echo "${enum_fl}"
		while read index_k
		do
			$CKSUM "${index_k}" >> "${1}/CKSUM_ALL_ARCH_FILES.txt" 2>&1
			$MD5SUM "${index_k}" >> "${1}/MD5SUM_ALL_ARCH_FILES.txt" 2>&1

		done < ${TMP_FILE}
	fi
done
#done <  ${TMP_FILE} ###index_i
	# Конец основного цикла
if [ -f ${TMP_FILE} ]; then
	rm -f ${TMP_FILE}
fi
echo "Распаковка архивов  в каталоге \"`pwd`\" завершена :)"