#!/bin/bash


find . -name '*.smk' \
       -exec sed -i {} \
                 -e '/docker:/s@/@-@g' \
                 -e '/docker:/s@"$@.sif"@g' \
                 -e 's@docker:--\(.*\)@/cm/shared/containers/docker/\1@'  \;
