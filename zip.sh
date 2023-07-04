#!/bin/sh
name=LogisticConfigurator_1.0.0
mkdir $name
cp -a * $name
rm $name/*.sh $name/*.zip $name/$name $name/action.gif -rf
rm -rf ${name}.zip
tar -acf ${name}.zip $name
rm -rf $name
