RM := rm -f
WCLEAN := wclean
WMAKE := FOAM_USER_SRC=${CURDIR}/src wmake

.PHONY: clean

# TODO: fix dependencies since many executables/libraries depend upon stuff in lnInclude, not just the .so
# we'll probably want .INTERMEDIATE trick again because wmake builds both the .so and lnInclude at the same time

LIB_EXNER_THETA := $(FOAM_USER_LIBBIN)/libExnerTheta.so
LIB_FINITE_VOLUME_USER := $(FOAM_USER_LIBBIN)/libfiniteVolumeUser.so
LIB_HOPS := $(FOAM_USER_LIBBIN)/libHops.so

EXNER_FOAM := $(FOAM_USER_APPBIN)/exnerFoam
EXNER_FOAM_H := $(FOAM_USER_APPBIN)/exnerFoamH
ADD_2D_MOUNTAIN := $(FOAM_USER_APPBIN)/add2dMountain
GLOBAL_SUM := $(FOAM_USER_APPBIN)/globalSum
SUM_FIELDS := $(FOAM_USER_APPBIN)/sumFields
SET_EXNER_BALANCED := $(FOAM_USER_APPBIN)/setExnerBalanced
SET_EXNER_BALANCED_H := $(FOAM_USER_APPBIN)/setExnerBalancedH
SET_SCALAR_OVER_OROGRAPHY := $(FOAM_USER_APPBIN)/setScalarOverOrography
SET_THETA := $(FOAM_USER_APPBIN)/setTheta
CREATE_SPONGE_LAYER := $(FOAM_USER_APPBIN)/createSpongeLayer
PLOT_PATCH_DATA := $(FOAM_USER_APPBIN)/plotPatchData
FIX_PROCESSOR_FACE_VELOCITIES := $(FOAM_USER_APPBIN)/fixProcessorFaceVelocities

ALL_LIBS := $(LIB_EXNER_THETA) \
	$(LIB_FINITE_VOLUME_USER) \
	$(LIB_HOPS)

ALL_EXECUTABLES := \
	$(EXNER_FOAM) \
	$(EXNER_FOAM_H) \
	$(ADD_2D_MOUNTAIN) \
	$(GLOBAL_SUM) \
	$(SUM_FIELDS) \
	$(SET_EXNER_BALANCED) \
	$(SET_EXNER_BALANCED_H) \
	$(SET_SCALAR_OVER_OROGRAPHY) \
	$(SET_THETA) \
	$(CREATE_SPONGE_LAYER) \
	$(FIX_PROCESSOR_FACE_VELOCITIES)
	#$(PLOT_PATCH_DATA) \

all: $(ALL_EXECUTABLES)

clean:
	$(WCLEAN) src/ExnerTheta
	$(WCLEAN) src/finiteVolume
	$(WCLEAN) src/Hops
	$(WCLEAN) applications/solvers/ExnerFoam/ExnerFoamH
	$(WCLEAN) applications/solvers/ExnerFoam/ExnerFoam
	$(WCLEAN) applications/utilities/mesh/add2dMountain
	$(WCLEAN) applications/utilities/preProcessing/createSpongeLayer
	$(WCLEAN) applications/utilities/preProcessing/setExnerBalanced
	$(WCLEAN) applications/utilities/preProcessing/setExnerBalancedH
	$(WCLEAN) applications/utilities/preProcessing/setScalarOverOrography
	$(WCLEAN) applications/utilities/preProcessing/setTheta
	$(WCLEAN) applications/utilities/preProcessing/fixProcessorFaceVelocities
	$(WCLEAN) applications/utilities/postProcessing/globalSum
	$(WCLEAN) applications/utilities/postProcessing/sumFields
	$(WCLEAN) applications/utilities/postProcessing/plotPatchData_gmt5.1
	$(RM) $(ALL_LIBS) $(ALL_EXECUTABLES)

$(LIB_EXNER_THETA): src/ExnerTheta/BCs/fixedFluxBuoyantExnerFvPatchScalarField.C $(LIB_FINITE_VOLUME_USER)
	$(WMAKE) src/ExnerTheta

# TODO: get dependencies from Make/files ?
$(LIB_FINITE_VOLUME_USER):
	$(WMAKE) src/finiteVolume

$(LIB_HOPS):
	$(WMAKE) src/Hops

$(EXNER_FOAM): $(LIB_HOPS) $(LIB_EXNER_THETA) $(LIB_FINITE_VOLUME_USER)
	$(WMAKE) applications/solvers/ExnerFoam/ExnerFoam

$(EXNER_FOAM_H): $(LIB_HOPS) $(LIB_EXNER_THETA)
	$(WMAKE) applications/solvers/ExnerFoam/ExnerFoamH	

$(SET_EXNER_BALANCED): $(LIB_HOPS) $(LIB_EXNER_THETA)
	$(WMAKE) applications/utilities/preProcessing/setExnerBalanced

$(SET_EXNER_BALANCED_H): $(LIB_HOPS) $(LIB_EXNER_THETA)
	$(WMAKE) applications/utilities/preProcessing/setExnerBalancedH

$(SET_THETA): $(LIB_EXNER_THETA)
	$(WMAKE) applications/utilities/preProcessing/setTheta

$(ADD_2D_MOUNTAIN):
	$(WMAKE) applications/utilities/mesh/add2dMountain

$(GLOBAL_SUM): $(LIB_FINITE_VOLUME_USER)
	$(WMAKE) applications/utilities/postProcessing/globalSum

$(SUM_FIELDS):
	$(WMAKE) applications/utilities/postProcessing/sumFields

$(SET_SCALAR_OVER_OROGRAPHY):
	$(WMAKE) applications/utilities/preProcessing/setScalarOverOrography

$(CREATE_SPONGE_LAYER): $(LIB_FINITE_VOLUME_USER)
	$(WMAKE) applications/utilities/preProcessing/createSpongeLayer

$(PLOT_PATCH_DATA): $(LIB_FINITE_VOLUME_USER)
	$(WMAKE) applications/utilities/postProcessing/plotPatchData_gmt5.1

$(FIX_PROCESSOR_FACE_VELOCITIES):
	$(WMAKE) applications/utilities/preProcessing/fixProcessorFaceVelocities
