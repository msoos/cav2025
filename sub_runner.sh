#!/bin/bash

ulimit -t unlimited
shopt -s nullglob

filespos="all"
filespos="small"

opts_arr=(
"ganak"
"d4"
"gpmc"
"SharpSAT-TD"
)
output="out-others"
tlimit="3600"
memlimit="45000000"

numthreads=4
SCRATCH="/home/vboxuser/devel/run"
SLURM_SUBMIT_DIR=$SCRATCH
SLURM_JOB_ID="1"
OMPI_COMM_WORLD_RANK="$1"
WORKDIR="$SCRATCH/scratch/${SLURM_JOB_ID}_${OMPI_COMM_WORLD_RANK}"
rm -rf $WORKDIR
output="${output}-${SLURM_JOB_ID}"

# echo "Transferring files from server to compute node"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}" || exit
mkdir -p "tmp_dir"

files=$(ls ${SLURM_SUBMIT_DIR}/cnfs/${filespos}/*.cnf.gz | shuf --random-source=${SCRATCH}/myrnd)
outputdir="${SCRATCH}/outfiles/"
ln -s ${SLURM_SUBMIT_DIR}/ganak .
ln -s ${SLURM_SUBMIT_DIR}/mccomp2024 .
ln -s ${SLURM_SUBMIT_DIR}/mccomp2024/Track1_MC/SharpSAT-TD-unweighted/bin2/flow_cutter_pace17 .
ln -s ${SLURM_SUBMIT_DIR}/doalarm .
ln -s ${SLURM_SUBMIT_DIR}/runlim .
ln -s ${SLURM_SUBMIT_DIR}/timeout .

# create todo
rm -f todo
at_opt=0
numlines=0
for opts in "${opts_arr[@]}"
do
    fin_out_dir="${output}-${at_opt}"
    mkdir -p "${fin_out_dir}" || exit
    for file in $files
    do
        filename=$(basename "$file")
        filenameunzipped=${filename%.gz}

        # create dir
        echo "mkdir -p ${outputdir}/${fin_out_dir}" >> todo
        echo "cp ${SLURM_SUBMIT_DIR}/inputfiles/${filespos}/${filename} ." >> todo
        echo "gunzip ${filename}" >> todo
        baseout="${fin_out_dir}/${filename}"

        # run
        if [[ "${opts}" =~ "SharpSAT-TD" ]]; then
            if [[ "${filename}" =~ "track4" ]]; then
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./doalarm -t real ${tlimit} echo 'cannot deal wth projected' > ${baseout}.out_sharptd 2>&1" >> todo
            elif [[ "${filename}" =~ "track3" ]]; then
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./doalarm -t real ${tlimit} echo 'cannot deal wth projected' > ${baseout}.out_sharptd 2>&1" >> todo
            elif [[ "${filename}" =~ "track2" ]]; then
                exec="./mccomp2024/Track2_WMC/SharpSAT-TD-weighted/bin/sharpSAT -WE -decot 120 -decow 100 -tmpdir tmp_dir -cs 3500"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_sharptd 2>&1" >> todo
            else
                exec="./mccomp2024/Track1_MC/SharpSAT-TD-unweighted/bin/sharpSAT -decot 120 -decow 100 -tmpdir tmp_dir -cs 3500"
                echo "/usr/bin/time --verbose -o ${baseout}.timeout_sharptd ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_sharptd 2>&1" >> todo
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
        elif [[ "${opts}" =~ "ganak" ]]; then
		exec="./ganak --maxcache 5000"
		echo "/usr/bin/time --verbose -o ${baseout}.timeout_ganak ./doalarm -t real ${tlimit} ./${exec} ${filenameunzipped} > ${baseout}.out_ganak 2>&1" >> todo
        fi

        #copy back result
        echo "xz ${baseout}.out*" >> todo
        echo "xz ${baseout}.timeout*" >> todo
        echo "rm -f core.*" >> todo

        echo "mv ${baseout}.out* ${outputdir}/${fin_out_dir}/" >> todo
        echo "mv ${baseout}.timeout* ${outputdir}/${fin_out_dir}/"  >> todo
        echo "rm -f ${baseout}*" >> todo
        echo "rm -f ${filenameunzipped}" >> todo
        echo "rm -f ${filename}" >> todo

        #lines:
        # 3+1+3+5 = 12

        numlines=$((numlines+1))
    done
    let at_opt=at_opt+1
done
mylinesper=12

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
    if [[ $myi -eq $OMPI_COMM_WORLD_RANK ]]; then
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
                if [[ $myi -eq $OMPI_COMM_WORLD_RANK ]]; then
                    head -n $mys todo | tail -n $myp >> todo_$myi.sh
                fi
            else
                #we are at boundary, e.g. numlines is 100, numper is 3, mystart is 102
                #we must only print the last numper-(mystart-numlines) = 3-2 = 1
                mys=$((mystart*mylinesper))
                p=$(( numper-mystart+numlines ))
                if [[ $p -gt 0 ]]; then
                    myp=$((p*mylinesper))
                    if [[ $myi -eq $OMPI_COMM_WORLD_RANK ]]; then
                        head -n $mys todo | tail -n $myp >> todo_$myi.sh
                    fi
                fi
            fi
        fi
    else
        if [[ $remain -gt 0 ]]; then
            mys=$((mystart*mylinesper))
            mr=$((remain*mylinesper))
            if [[ $myi -eq $OMPI_COMM_WORLD_RANK ]]; then
                head -n $mys todo | tail -n $mr >> todo_$myi.sh
            fi
        fi
    fi
    if [[ $myi -eq $OMPI_COMM_WORLD_RANK ]]; then
        echo "exit 0" >> todo_$myi.sh
        chmod +x todo_$myi.sh
    fi
done

# Execute todos
echo "should execute: ./todo_${OMPI_COMM_WORLD_RANK}.sh > out_${OMPI_COMM_WORLD_RANK}"
echo "ind dir:"
echo $(pwd)
cat ./todo_${OMPI_COMM_WORLD_RANK}.sh
echo "Finished waiting rank $OMPI_COMM_WORLD_RANK"

exit 0
