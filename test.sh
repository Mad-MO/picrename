#!/bin/bash

SOURCE="./TestFiles"
TARGET="./TestArea"

echo "Cleaning up"
rm $TARGET/*

echo "Copying testfiles"
cp -p $SOURCE/* $TARGET

echo "Running Program"
./picrenamer.sh $TARGET/*

