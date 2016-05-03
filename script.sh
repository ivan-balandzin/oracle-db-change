#!/usr/bin/bash

cd ${WORKSPACE}
out="$(git log --pretty=format:"%an"| tail -1)"
sed -i "s/author: .*/author: $out/g" database.changelog-master.json
