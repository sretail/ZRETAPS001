*&---------------------------------------------------------------------*
*& Include          ZRETAPS001_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN begin of block b01 WITH FRAME TITLE text-001.
  select-options: s_IDGAS for ZRETAPS001t01-IDGAS,
                  s_FTRAN for ZRETAPS001t01-FTRAN,
                  s_RESPO for ZRETAPS001t01-RESPO,
                  s_CATE1 for ZRETAPS001t01-CATE1,
                  s_CATE2 for ZRETAPS001t01-CATE2,
                  s_CATE3 for ZRETAPS001t01-CATE3.
SELECTION-SCREEN end of BLOCK b01.

*PARAMETERS: p_file like rlgrap-filename.
