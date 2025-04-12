#!/bin/bash

ulimit -t unlimited
shopt -s nullglob

filespos="all"

opts_arr=(
"d4"
"gpmc"
"sharptd"
"ganak-baseline"
"ganak-basic-sat-and-chronobt"
"ganak-also-enhanced-sat"
"ganak-also-dual-indep"
"ganak-also-extend-d-set"
)
output="out"
memlimit="9000000"

filespos="all"
num=$1
numthreads=$2
tlimit=$3
rank=$4
if [ $# -lt 3 ]; then
    echo "NEVER use this script on its own!!!"
    exit 1
fi

basedir="/home/vboxuser/devel/run"
WORKDIR="${basedir}/scratch/${rank}"
# rm -rf ${WORKDIR}
mkdir -p "${WORKDIR}"
cd "${WORKDIR}" || exit 1
mkdir -p "tmp_dir"

files1=$(ls ${basedir}/cnfs/proj/*.cnf.gz | shuf --random-source=${basedir}/myrnd | head -n ${num})
files2=$(ls ${basedir}/cnfs/unproj/*.cnf.gz | shuf --random-source=${basedir}/myrnd | head -n ${num})
files=(${files1} ${files2})
outputdir="${basedir}"
# rm -rf ${outputdir}/out*
ln -s ${basedir}/ganak .
ln -s ${basedir}/mccomp2024 .
ln -s ${basedir}/mccomp2024/Track1_MC/SharpSAT-TD-unweighted/bin/flow_cutter_pace17 .
ln -s ${basedir}/doalarm .

# create todo
# rm -f todo
at_opt=0
numlines=0
for opts in "${opts_arr[@]}"
do
    fin_out_dir="${output}-${opts}"
    # rm -rf ${fin_out_dir}
    # rm -rf "${outputdir}/${fin_out_dir}"
    for file in $files
    do
        filename=$(basename "$file")
        filenameunzipped=${filename%.gz}

        # create dir
        echo "mkdir -p ${outputdir}/${fin_out_dir}" >> todo
        echo "cp ${basedir}/cnfs/${filespos}/${filename} ." >> todo
        echo "gunzip ${filename}" >> todo
        mkdir -p "${fin_out_dir}"
        baseout="${fin_out_dir}/${filename}"

        # run
        if [[ "${opts}" =~ "sharptd" ]]; then
            if [[ "${filename}" =~ "track4" ]]; then
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd echo 'cannot deal wth projected' > ${baseout}.out_sharptd 2>&1" >> todo
            elif [[ "${filename}" =~ "track3" ]]; then
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd echo 'cannot deal wth projected' > ${baseout}.out_sharptd 2>&1" >> todo
            elif [[ "${filename}" =~ "track2" ]]; then
                exec="./mccomp2024/Track2_WMC/SharpSAT-TD-weighted/bin/sharpSAT -WE -decot 120 -decow 100 -tmpdir tmp_dir -cs 3500"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./runlim -o /dev/null-r ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_sharptd 2>&1" >> todo
            else
                exec="./mccomp2024/Track1_MC/SharpSAT-TD-unweighted/bin/sharpSAT -decot 120 -decow 100 -tmpdir tmp_dir -cs 3500"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./runlim -o /dev/null -r ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_sharptd 2>&1" >> todo
            fi
        elif [[ "${opts}" =~ "gpmc" ]]; then
            if [[ "${filename}" =~ "track4" ]]; then
                exec="./mccomp2024/Track4_PWMC/gpmc-wmc/bin/gpmc -mode=3"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_gpmc ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_gpmc 2>&1" >> todo
            elif [[ "${filename}" =~ "track3" ]]; then
                exec="./mccomp2024/Track3_PMC/gpmc/bin/gpmc -mode=2"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_gpmc ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_gpmc 2>&1" >> todo
            elif [[ "${filename}" =~ "track2" ]]; then
                exec="./mccomp2024/Track2_WMC/gpmc-wmc/bin/gpmc -mode=1"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_gpmc ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_gpmc 2>&1" >> todo
            else
                exec="./mccomp2024/Track1_MC/gpmc/bin/gpmc -mode=0"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_gpmc ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_gpmc 2>&1" >> todo
            fi
        elif [[ "${opts}" =~ "d4" ]]; then
            if [[ "${filename}" =~ "track4" ]]; then
                exec="./mccomp2024/Track4_PWMC/d4_glucose4/bin/d4"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_d4 ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_d4 2>&1" >> todo
            elif [[ "${filename}" =~ "track3" ]]; then
                exec="./mccomp2024/Track3_PMC/d4_glucose4/bin/d4"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_d4 ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_d4 2>&1" >> todo
            elif [[ "${filename}" =~ "track2" ]]; then
                exec="./mccomp2024/Track2_WMC/d4_glucose4/bin/d4"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_d4 ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_d4 2>&1" >> todo
            else
                exec="./mccomp2024/Track1_MC/d4_glucose4/bin/d4"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_d4 ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_d4 2>&1" >> todo
            fi
        elif [[ "${opts}" =~ "ganak-baseline" ]]; then
            exec="./ganak --arjunverb 2 --maxcache 5000 --arjunextend 0 --optindep 0 --satsolver 0 --chronobt 0"
            echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        elif [[ "${opts}" =~ "ganak-basic-sat-and-chronobt" ]]; then
            exec="./ganak --arjunverb 2 --maxcache 5000 --optindep 0 --satrst 0 --satpolarcache 0 --satvsids 0"
            echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        elif [[ "${opts}" =~ "ganak-also-enhanced-sat" ]]; then
            exec="./ganak --arjunverb 2 --maxcache 5000 --optindep 0"
            echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        elif [[ "${opts}" =~ "ganak-also-dual-indep" ]]; then
            exec="./ganak --arjunverb 2 --maxcache 5000 --arjunextend 0"
            echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        elif [[ "${opts}" =~ "ganak-also-extend-d-set" ]]; then
            exec="./ganak --arjunverb 2 --maxcache 5000"
            echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        fi

        #copy back result
        echo "rm -f core.*" >> todo

        echo "mv ${baseout}.out* ${outputdir}/${fin_out_dir}/" >> todo
        echo "mv ${baseout}.timeout* ${outputdir}/${fin_out_dir}/"  >> todo
        echo "rm -f ${baseout}*" >> todo
        echo "rm -f ${filenameunzipped}" >> todo
        echo "rm -f ${filename}" >> todo

        #lines:
        # 3+1+1+5 = 10

        numlines=$((numlines+1))
    done
    let at_opt=at_opt+1
done
mylinesper=10

# create per-core todos
numper=$((numlines/numthreads))
remain=$((numlines-numper*numthreads))
if [[ $remain -ge 1 ]]; then
    numper=$((numper+1))
fi
remain=$((numlines-numper*(numthreads-1)))

moretime=$((tlimit+20))
mystart=0
for ((myi=0; myi < numthreads ; myi++))
do
    rm -f todo_$myi.sh
    if [[ $myi -eq $rank ]]; then
        touch todo_$myi.sh
        echo "#!/bin/bash" > todo_$myi.sh
        echo "ulimit -t $moretime" >> todo_$myi.sh
        echo "ulimit -v $memlimit" >> todo_$myi.sh
        echo "ulimit -c 0" >> todo_$myi.sh
        echo "set -x" >> todo_$myi.sh
    fi
    typeset -i myi
    typeset -i numper
    typeset -i mystart
    mystart=$((mystart + numper))
    if [[ $myi -lt $((numthreads-1)) ]]; then
        if [[ $mystart -gt $((numlines+numper)) ]]; then
            sleep 0
        else
            if [[ $mystart -lt $numlines ]]; then
                myp=$((numper*mylinesper))
                mys=$((mystart*mylinesper))
                if [[ $myi -eq $rank ]]; then
                    head -n $mys todo | tail -n $myp >> todo_$myi.sh
                fi
            else
                #we are at boundary, e.g. numlines is 100, numper is 3, mystart is 102
                #we must only print the last numper-(mystart-numlines) = 3-2 = 1
                mys=$((mystart*mylinesper))
                p=$(( numper-mystart+numlines ))
                if [[ $p -gt 0 ]]; then
                    myp=$((p*mylinesper))
                    if [[ $myi -eq $rank ]]; then
                        head -n $mys todo | tail -n $myp >> todo_$myi.sh
                    fi
                fi
            fi
        fi
    else
        if [[ $remain -gt 0 ]]; then
            mys=$((mystart*mylinesper))
            mr=$((remain*mylinesper))
            if [[ $myi -eq $rank ]]; then
                head -n $mys todo | tail -n $mr >> todo_$myi.sh
            fi
        fi
    fi
    if [[ $myi -eq $rank ]]; then
        echo "exit 0" >> todo_$myi.sh
        chmod +x todo_$myi.sh
    fi
done

# Execute todos
echo "should execute: ./todo_${rank}.sh > out_${rank}"
echo "in dir: $(pwd)"
./todo_${rank}.sh > out_${rank}
# cat ./todo_${rank}.sh
echo "Finished waiting rank $rank"
exit 0
