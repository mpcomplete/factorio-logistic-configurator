#!/bin/sh
name=LogisticConfigurator_1.0.1
mkdir $name
cp -a * $name
rm $name/*.sh $name/*.zip $name/$name $name/*.png -rf
cp thumbnail.png $name
rm -rf ${name}.zip
7z a ${name}.zip $name
rm -rf $name
