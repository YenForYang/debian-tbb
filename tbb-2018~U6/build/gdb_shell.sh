#!/bin/sh

# Run some tests through gdb, we rely on a hack to detect whether or
# or not the run completed successfully. $_exitcode will be set if the
# test finishes without breaking.
#
# If the test breaks, we dump a full backtrace. Then return with an
# error to ensure that the build stops.

programname=$1
shift
args=$@

$programname $args
rc=$?
if [ "$rc" -eq "0" ]; then
    exit 0
fi

echo "Unit test failed: rc=$rc, attempting to re-run with gdb and post-mortem."

temp_file=$(mktemp)

cat >$temp_file <<EOF
set pagination off
set \$_exitcode=3142
r $args
if \$_exitcode==3142
    bt full
    info proc mappings
    quit -1
end
quit
EOF

gdb $programname -x $temp_file
rc=$?
rm $temp_file
exit $rc
