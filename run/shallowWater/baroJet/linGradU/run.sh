#!/bin/bash -ve

# Create the case, run and post-process

# clear out old stuff
rm -rf [0-9]* constant/polyMesh constant/*/polyMesh core log* legends gmt.history *.dat

# Create initial mesh
blockMesh
mkdir -p constant/rMesh
cp -r constant/polyMesh constant/rMesh

# Createt initial conditions on the rMesh and plot
time=0
cp -r init0 0
setPlaneJet -region rMesh
gmtFoam -time $time -region rMesh hMesh
evince $time/hMesh.pdf &


# Solve the shallow water equations
movingshallowWaterFoamH >& log & sleep 0.01; tail -f log

# Plot the final solutions
time=1000000
gmtFoam -time $time h -region rMesh
evince $time/h.pdf &

gmtFoam -time $time monitor -region rMesh
evince $time/monitor.pdf &

# Plot animation of solutions
gmtFoam hU -region rMesh
eps2gif hU.gif 0/hU.pdf [1-9]00000/hU.pdf 1e+06/hU.pdf &

# Plot change between initial and final solutions
time=1e+06
sumFields $time hDiff $time h 0 h -scale0 1 -scale1 -1
sumFields $time UDiff $time U 0 U -scale0 1 -scale1 -1
gmtFoam -time $time hUDiff
evince $time/hUDiff.pdf &

# If we have an analytic solution in directory ref, then we can calculate 
# error norms relative to this solution. For demonstration, I assume that
# the analytic solution is the initial condition. This is not the case here
# as this is not a steady state problem
ref=0
time=1e+06
globalSum h -time $ref
globalSum hDiff -time $time
l1=`tail -1 globalSumh.dat | awk '{print $2}'`
l2=`tail -1 globalSumh.dat | awk '{print $3}'`
li=`tail -1 globalSumh.dat | awk '{print $4}'`
echo "time l1 l2 linf" > hErrors.dat
awk '{if ($1 == 1*$1) print $1, $2/'$l1', $3/'$l2', $4/'$li'}' \
    globalSumhDiff.dat >> hErrors.dat

# Calculate and plot the vorticity
time=1e+06
postProcess -func rMesh/vorticity2D -time $time -region rMesh
gmtFoam -time $time vorticity -region rMesh
evince $time/vorticity.pdf &

# animation of the vorticity
postProcess -func rMesh/vorticity2D -region rMesh
gmtFoam vorticity -region rMesh
eps2gif vorticity.gif 0/vorticity.pdf ?????/vorticity.pdf ??????/vorticity.pdf \
        ???????/vorticity.pdf

# animation of various fields
field=monitor
field=mesh
eps2gif $field.gif ?/$field.pdf ?????/$field.pdf ??????/$field.pdf \
        ???????/$field.pdf

