# Matlab DCM conversion

Mat2Dcm is a Matlab data format conversion tool to generate `*.dcm` files from
`*.mat` files. Heuristics are used to distinguish the data types in the
resulting DCM. No emphasis is placed on full inforation transfer - instead only
the value of the label is deemed important. The conversion is subsequently lossy
and cannot be fully reversed.

## Example

Say you want to create a DCM containing the variables `K_LABEL_N1` and
`KL_ANOTHER_LABEL`, which you just created in your workspace:

    >> K_LABEL_N1 = 3.5;
    >> KL_ANOTHER_LABEL.x = [0 1 2 3];
    >> KL_ANOTHER_LABEL.y = {'true' 'true' 'false' 'true'};

    >> save('tmp.mat', 'K_LABEL_N1', 'KL_ANOTHER_LABEL');

    >> mat2dcm('tmp.mat', 'labels.dcm');
    labels.dcm: Exported 1 Festwert, 0 Festwertebloecke, 1 Kennlinie, 0 Kennfelder

    >> type('labels.dcm')

    * DCM export
    * User: q284114
    * Date: 03-Jul-2015
    * Script Version: 0.0.1


    KONSERVIERUNG_FORMAT 2.0

    KENNLINIE KL_ANOTHER_LABEL 4
      ST/X   0.000   1.000   2.000   3.000
      TEXT   "true"   "true"   "false"   "true"
    END

    FESTWERT K_LABEL_N1
      WERT 3.500
    END

## Options

The `mat2dcm` function takes two mandatory arguments (the source `*.mat` file
and the destination `*.dcm` file) and a number of optional key-value paris:

    >> help mat2dcm
    FUNCTION MAT2DCM
      Write a DCM of all variables saved in file MATFILENAME to DCMFILENAME.
      Parameters can be adapted to the INCA format, whereby matrices are reshaped
      into their transposed dimensions. Usage:

      MAT2DCM(MATFILENAME, DCMFILENAME[, KEY1, VAL1, ...])

      where the KEYS and VALUES can be any of the following

        KEY           DESCRIPTION                            DEFAULT
        ----------------------------------------------------------------
        Precision     Precision of the exported parameter    %1.3f
        Prefix        Prefix for all labels                  ''
        Verbose       Report exported labels                 true
        Encoding      Encoding to use for DCM file           'windows-1250'

      Jonas Mueller, EA-253
      02.07.2015

## Data types


## Todo

* Stützstellverteilungen
* Gruppenkennlinien/-kennfelder
* Bessere README Formattierung
