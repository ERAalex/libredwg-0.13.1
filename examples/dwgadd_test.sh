#!/bin/sh

abs_builddir="/home/rurban/Software/libredwg/.build-release/examples"
top_builddir=".."
EXEEXT=""
TESTS_ENVIRONMENT=""
srcdir="/home/rurban/Software/libredwg/.build-release/../examples"
echo srcdir: "$srcdir"

if [ -n "$VALGRIND" ] && [ -n "$LOG_COMPILER" ]; then
    TESTPROG="$LOG_COMPILER $LOG_FLAGS"
elif [ -n "" ]; then
    TESTPROG=""
elif [ -n "$TESTS_ENVIRONMENT" ]; then
    TESTPROG="$TESTS_ENVIRONMENT ${top_builddir}/libtool --mode=execute"
else
    TESTPROG="${top_builddir}/libtool --mode=execute"
fi

dwgaddtest() {
    MG="$1"
    V="$2"
    EX="${3:-dwgadd.example}"
    if [ -f "$srcdir/$EX" ]
    then
        FEX="$srcdir/$EX"
    else
        FEX="$EX"
    fi
    if [ -z "$V" ]; then
        echo ./dwgadd --verify -o dwgadd_test.dwg "$FEX"
        $TESTPROG "${abs_builddir}/dwgadd${EXEEXT}" --verify \
                       -o dwgadd_test.dwg "$FEX"
        ret=$?
    else
        #PRE=
        #if test "$V" = "r1.4" -a -n ""
        #then
        #   PRE="env ASAN_OPTIONS=detect_leaks=0"
        #fi
        echo "$PRE" ./dwgadd --verify -a "$V" -o dwgadd_test.dwg "$FEX"
        # shellcheck disable=SC2086
        $TESTPROG "${abs_builddir}/dwgadd${EXEEXT}" --verify \
                       -a "$V" -o dwgadd_test.dwg "$FEX"
        ret=$?
    fi
    if [ $ret -ne 0 ]
    then
        echo FAIL verify
        exit 1
    fi
    ver=$(head -c6 dwgadd_test.dwg)
    if [ -z "$ver" ]
    then
        echo FAIL
        exit 1
    fi
    if [ "$ver" = "$MG" ]
    then
        echo PASS
    else
        echo FAIL "$ver != $MG"
        exit 1
    fi
}

dwgaddtest AC1015
dwgaddtest AC1015 r2000
# skip. XRECORD.objid_handles double-free #530
#if [ 0 -gt 0 ]; then
#    dwgaddtest AC1014 r14
#    dwgaddtest AC1012 r13
#fi
# wrong DICTIONARY.ownerhandle
dwgaddtest AC1014 r14 dwgadd.example_r11
dwgaddtest AC1012 r13 dwgadd.example_r11
# --verify fails with error 0x100 (VX.size overflow)
dwgaddtest AC1009 r11 dwgadd.example_r11
#sed -e'/^dimstyle/d;/^ucs/d;/^lwpolyline/d;/^viewport/d;' <"$srcdir/dwgadd.example_r11" >"$srcdir/dwgadd.example_r10"
dwgaddtest AC1006 r10 dwgadd.example_r10
dwgaddtest AC1004 r9 dwgadd.example_r10
#sed -e'/^dimension/d;/^3dface/d;' <"$srcdir/dwgadd.example_r10" >"$srcdir/dwgadd.example_r2_10"
dwgaddtest AC2.10 r2.10 dwgadd.example_r2_10
dwgaddtest AC1003 r2.6 dwgadd.example_r2_10
#rm -f "$srcdir/dwgadd.example_r10" "$srcdir/dwgadd.example_r2_10"
dwgaddtest AC1.40 r1.4 dwgadd.example_r1_4

# not yet supported
#dwgaddtest AC1018 r2004
#dwgaddtest AC1021 r2007
#dwgaddtest AC1024 r2010
#dwgaddtest AC1027 r2013
#dwgaddtest AC1032 r2018

# special cases

tmp=dwgadd.tmp
echo "point (0 0 0)" >$tmp
echo "point (1 1 0)" >>$tmp
cat $tmp
dwgaddtest AC1015 r2000 $tmp

echo "point (0 0 0)" >$tmp
cat $tmp
dwgaddtest AC1015 r2000 $tmp
dwgaddtest AC1009 r11 $tmp

# cleanup
rm -f dwgadd_test.dwg $tmp
