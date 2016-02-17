#!/bin/bash

src_main_dir=$1
trg_main_dir=$2

mkdir -p $trg_main_dir
for i in `seq 0 24`; do
    i_str=`printf "%02d\n" $i`;
    trg_dir=$trg_main_dir/$i_str;
    mkdir $trg_dir;
    for j in $src_main_dir/cs/data/wsj$i_str*; do \
        src_file=`basename $j`; \
        src_base=`echo $src_file | sed 's/\..*$//'`;
        trg_file=`echo $src_file | sed 's/^wsj/wsj_/' | sed 's/cz/cs/'`;
        trg_base=`echo $trg_file | sed 's/\..*$//'`;
        cp $j $trg_dir/$trg_file;
        if [[ "$trg_file" == *.gz ]]; then
            gunzip $trg_dir/$trg_file;
            trg_file=${trg_file%.gz}
        fi
        echo $j "--->" $trg_dir/$trg_file.gz;
        cat $trg_dir/$trg_file | \
            sed "s/$src_base\.cz\.\([aptmw]\)\(\.gz\)\?/$trg_base.cs.\1.gz/g" | \
            sed 's/target-node\.rf/target_node.rf/g' | \
            sed 's/informal-type/type/g' | \
            gzip -c > $trg_dir/$trg_file.gz;
        rm $trg_dir/$trg_file;
    done;
    for j in $src_main_dir/en/data/$i_str*/*; do
        src_file=`basename $j`;
        src_base=`echo $src_file | sed 's/\..*$//'`;
        trg_file=`echo $src_file | sed 's/\.\(.\)\.gz$/.en.\1.gz/'`;
        trg_base=`echo $trg_file | sed 's/\..*$//'`;
        echo $j "--->" $trg_dir/$trg_file;
        zcat $j | \
            sed "s/$src_base\.\([aptmw]\)\.gz/$trg_base.en.\1.gz/g" | \
            sed 's/target-node\.rf/target_node.rf/g' | \
            sed 's/informal-type/type/g' | \
            gzip -c > $trg_dir/$trg_file;
    done;
done
