/* from Jeffrey's main.cpp */

#include <iostream>
#include <fstream>
#include <vector>
#include <chrono>
#include <math.h>
#include <utility>
#include <string>
#include <random>
#include <sstream>
#include "poi_polygon.h"

/* from lagrit lg_ codes */
#include "lg_c_interface.h"
#include "lg_f_interface.h"

#include "poi_routine_2D.h"

#include <stdio.h>
#include <cstring>

using std::cout;
using std::endl;

//const int LG_NAME_SIZE = 32;

void poisson_2d_(const char *mo_poly_name, const char *mo_pts, double *h, unsigned int *dfNumCellsX, unsigned int *dfNumCellsY) {
    cout << "===== Begin Poisson 2D Sampling =========\n\n" << endl;
    cout << "PD inputs:" << endl;
    cout << "h :" << *h << endl;
    cout << "mo_poly name : " << mo_poly_name << endl;
    cout << "dfNumCellsX: " << *dfNumCellsX << endl;
    cout << "dfNumCellsY: " << *dfNumCellsY << endl;
    LG_ERR err = 0;

    /*
    double *xptr;
    double *yptr;
    long *iptr;
    double xmin = 0;
    double xmax = 0;
    double ymin = 0;
    double ymax = 0;
    double zmin = 0;
    double zmax = 0;
    
    long nlen = 0;
    long nelem = 0;
    long ierr = 0;
    
    long icmolen;
    long iattlen;
    int ierror = 0;
    
    cout << "\n===== Enter Driver for poisson_2d  =========\n\n" << endl;
    cout << "-----------------------------------\n" << endl;
    cout << "Report LaGriT CMO for Polygon:\n\n" << endl;
    // get data from current polygon mesh object
    // char mo_poly_name[32];
    // err = lg_cmo_get_name(mo_poly_name, 32);
    // if (err != LG_ERR_SUCCESS) {
    //     cout << "Failed to get cmo name" << endl;
    //     return;
    // }
    unsigned int nnodes = lg_cmo_get_intinfo("nnodes", mo_poly_name);
    if (nnodes <= 0) {
        cout << "ERROR: No nodes in cmo: '" << mo_poly_name << "'" << endl;
        return;
    }
    
    int nelements = lg_cmo_get_intinfo("nelements", mo_poly_name);
    int ndim = lg_cmo_get_intinfo("ndimensions_topo", mo_poly_name);
    int ndim_geom = lg_cmo_get_intinfo("ndimensions_geom", mo_poly_name);
    if (err == LG_ERR_SUCCESS) {
        cout << "Mesh Data for cmo: '" << mo_poly_name << "'"<< endl;
        cout << "nnodes: " << nnodes << endl;
        cout << "nelements: " <<  nelements << endl;
        cout << "ndimensions_topo: " <<  ndim << endl;
        cout << "ndimensions_geom: " <<  ndim_geom << endl;
    }
    // get polygon xy minmax
    icmolen = strlen(mo_poly_name);
    iattlen = 4;
    fc_cmo_get_double_(mo_poly_name,"xmin",&xmin,&ierr,icmolen,iattlen);
    fc_cmo_get_double_(mo_poly_name,"xmax",&xmax,&ierr,icmolen,iattlen);
    fc_cmo_get_double_(mo_poly_name,"ymin",&ymin,&ierr,icmolen,iattlen);
    fc_cmo_get_double_(mo_poly_name,"ymax",&ymax,&ierr,icmolen,iattlen);
    fc_cmo_get_double_(mo_poly_name,"zmin",&zmin,&ierr,icmolen,iattlen);
    fc_cmo_get_double_(mo_poly_name,"zmax",&zmax,&ierr,icmolen,iattlen);
    
    cout << "xmin: " << xmin << ", xmax: " << xmax << endl;
    cout << "ymin: " << xmin << ", ymax: " << xmax << endl;
    cout << "zmin: " << xmin << ", zmax: " << xmax << endl;
    
    // get mesh object xic and yic data
    iattlen = 3;
    fc_cmo_get_vdouble_(mo_poly_name,"xic",&xptr,&nlen,&ierr,icmolen,iattlen);
    if (ierr != 0 || nlen != nnodes){
        cout << "ERROR: get xic returns length " << nlen << " error: " << ierr << endl;
        return;
    }
    fc_cmo_get_vdouble_(mo_poly_name,"yic",&yptr,&nlen,&ierr,icmolen,iattlen);
    if (ierr != 0 || nlen != nnodes){
        cout << "ERROR: get yic returns length " << nlen << " error: " << ierr << endl;
        return;
    }
    
    // report x,y coordinate data
    cout << "nodes:" << endl;
    for(int i = 0; i < nnodes; i++ ){
        cout << i+1 << " " << *(xptr+i) << " " << *(yptr+i) << endl;
    }
    
    */
    Polygon polygon;
    // This needs to be passed in somehow
    polygon.h = *h;
    cout << "h for sampling: " << polygon.h << endl;
    polygon.mo_poly_name = mo_poly_name;
    cout << "Loading polygon information from " << polygon.mo_poly_name << endl;
    polygon.mo_dfield_name = "mo_h_field_pts";
    cout << "Loading distance field information from " << polygon.mo_dfield_name << endl;
    polygon.dfNumCellsX = *dfNumCellsX;
    polygon.dfNumCellsY = *dfNumCellsY;
    // Defaults are set in poi_polygon.h, should be overloaded at some point in the function call
    polygon.numSamples = 10;
    polygon.resampleSweeps = 1;
    polygon.seed = 1;
    // initialize random number generator
    polygon.initializeRandomGenerator(polygon.seed);
    // load polygon vertices (polygon.cpp)
    bool inputCheck = polygon.loadVertices();
    if (!inputCheck){
        cout << "Error loading vertices from polygon.\nExitting Poisson Disc" << endl;
        return;
    }
    // Load distance field from file (distanceField.cpp)
    polygon.loadDistanceFieldCMO();
    // run initial analysis of polygon, obtain bounding box, etc. (polygon.cpp)
    polygon.initializeVariables();
    // Distribute points around the boundary of the polygon (sampling.cpp)
    polygon.sampleBoundaries();
//    polygon.printNodes();

    // Initialize the background look up grid (neighborGrid.cpp)
    polygon.initializeNeighborGrid();
    // Initial sampling sweep (sampling.cpp)
    polygon.mainSampling(0, false);
    // Find empty cells, resample therein, and restart the main sampling algorithm (sampling.capp)
    polygon.resample();
    // Write points to file
    polygon.dumpNodes();
    cout << "Done with Poisson 2D" << endl;
    return;
}
// #ifdef __cplusplus
// }
// #endif


