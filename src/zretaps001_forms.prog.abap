*&---------------------------------------------------------------------*
*& Include          ZRETAPS001_FORMS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_FILE_PC
*&---------------------------------------------------------------------*
*       Abre popup del sistema para seleccionar fichero
*----------------------------------------------------------------------*
*      <--P_P_FILE3  text
*----------------------------------------------------------------------*
FORM f_get_file_pc  CHANGING ps_file.
  DATA: ld_file LIKE rlgrap-filename.


  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
*   EXPORTING
*     PROGRAM_NAME        = SYST-REPID
*     DYNPRO_NUMBER       = SYST-DYNNR
*     FIELD_NAME          = ' '
*     STATIC              = ' '
*     MASK                = ' '
*     FILEOPERATION       = 'R'
*     PATH                =
    CHANGING
      file_name     = ld_file
*     LOCATION_FLAG = 'P'
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    ps_file = ld_file.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_start_of_selection .

  DATA:
        lit_zretaps001t01 LIKE zretaps001t01 OCCURS 0 WITH HEADER LINE.

*  perform f_excel_import tables git_excel_import using p_file.
*
*  loop at git_excel_import.
*    clear git_monitor.
*
*    split git_excel_import-col01 at '/' into ld_dia ld_mes ld_ano.
*    unpack ld_mes to ld_mes.
*    CONCATENATE ld_ano ld_mes ld_dia into git_monitor-ftran.
*    git_monitor-mes = ld_mes.
*    git_monitor-anyo = ld_ano.
*    git_monitor-RESPO = git_excel_import-col04.
*    git_monitor-CATe1 = git_excel_import-col05.
*    git_monitor-CATe2 = git_excel_import-col06.
*    git_monitor-CATe3 = git_excel_import-col07.
*    git_monitor-OUTfl = git_excel_import-col08.
*    git_monitor-OUTfr = git_excel_import-col09.
*    git_monitor-INflo = git_excel_import-col10.
*    git_monitor-WAERS = 'EUR'.
*    append git_monitor.
*
*  endloop.

  SELECT *
    FROM zretaps001t01
    INTO CORRESPONDING FIELDS OF TABLE @git_monitor
   WHERE ftran IN @s_ftran
     AND respo IN @s_respo
     AND cate1 IN @s_cate1
     AND cate2 IN @s_cate2
     AND cate3 IN @s_cate3.

  LOOP AT git_monitor.
    git_monitor-mes = git_monitor-ftran+4(2).
    git_monitor-anyo = git_monitor-ftran(4).

    IF git_monitor-consol = '' AND git_monitor-import = ''.
      git_monitor-dele = gc_icono_papelera.
      git_monitor-gc = gc_icono_compartido.
      git_monitor-gnc = gc_icono_nocompartido.
    ENDIF.

    MODIFY git_monitor.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_end_of_selection .
  PERFORM f_listar_datos
    USING
      'ZRETAPS001S01'         "Estructura columnas ALV
      'F_STATUS_MONITOR'      "Form STATUS
      'F_UCOMM_MONITOR'       "Form UCOMM
      ''                      "Form cabecera clásica
      ''                      "Form cabecera HTML
      'GIT_MONITOR[]'         "Tabla de datos
      ''                      "Campo info color linea
      'X'.                    "Seleccionable

ENDFORM.

*===================================================================================================
*&      Form  f_listar_datos
*===================================================================================================
FORM f_listar_datos USING     pe_estructura     LIKE  dd02l-tabname
                              pe_status         TYPE  slis_formname
                              pe_ucomm          TYPE  slis_formname
                              pe_top            TYPE  slis_formname
                              pe_top_html       TYPE  slis_formname
                              pe_datos
                              pe_color_line
                              pe_sel.

*0.- Declaracion de variables
*======================================================================
  DATA: lit_fieldcatalog TYPE         lvc_t_fcat,
        lr_layout        TYPE         lvc_s_layo,
        lr_variant       LIKE         disvariant,
        lit_sort         TYPE         slis_t_sortinfo_alv,
        wa_sort          TYPE         slis_sortinfo_alv,
        ld_index         LIKE         sy-tabix,
        lit_sort_lvc     TYPE         lvc_t_sort,
        wa_sort_lvc      TYPE         lvc_s_sort,
        lit_events       TYPE         slis_t_event,
        wa_events        TYPE         slis_alv_event.

* 1.- Logica
*======================================================================
  FIELD-SYMBOLS: <fs_tabla> TYPE STANDARD TABLE.

  ASSIGN (pe_datos) TO <fs_tabla>.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = pe_estructura
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
*     I_INTERNAL_TABNAME     =
    CHANGING
      ct_fieldcat            = lit_fieldcatalog
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  lr_layout-zebra             = 'X'.
* lr_layout-no_hgridln  = 'X'.
*  lr_layout-stylefname = 'FIELD_STYLE'.
* lr_layout-cwidth_opt = 'X'.
*  lr_layout-edit = 'X'.
  IF pe_sel = 'X'.
    lr_layout-box_fname = 'SEL'.
  ENDIF.



  IF pe_color_line <> ''.
    lr_layout-info_fname = pe_color_line.
  ENDIF.

*  lr_layout-ctab_fname = 'CELLCOLR'.

  PERFORM f_listar_datos_mapping TABLES lit_fieldcatalog.

  lr_variant-report = 'ZRETAPS001_1'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK           = ' '
*     I_BYPASSING_BUFFER          =
*     I_BUFFER_ACTIVE             =
      i_callback_program          = sy-repid
      i_callback_pf_status_set    = pe_status
      i_callback_user_command     = pe_ucomm
      i_callback_top_of_page      = pe_top
      i_callback_html_top_of_page = pe_top_html
*     I_CALLBACK_HTML_END_OF_LIST = ' '
*     I_STRUCTURE_NAME            =
*     i_background_id             = ''
*     I_GRID_TITLE                =
*     I_GRID_SETTINGS             =
      is_layout_lvc               = lr_layout
      it_fieldcat_lvc             = lit_fieldcatalog
*     IT_EXCLUDING                =
*     IT_SPECIAL_GROUPS_LVC       =
      it_sort_lvc                 = lit_sort_lvc
*     IT_FILTER_LVC               =
*     IT_HYPERLINK                =
*     IS_SEL_HIDE                 =
      i_default                   = 'X'
      i_save                      = 'A'
      is_variant                  = lr_variant
      it_events                   = lit_events
*     IT_EVENT_EXIT               =
*     IS_PRINT_LVC                =
*     IS_REPREP_ID_LVC            =
*     I_SCREEN_START_COLUMN       = 0
*     I_SCREEN_START_LINE         = 0
*     I_SCREEN_END_COLUMN         = 0
*     I_SCREEN_END_LINE           = 0
*     I_HTML_HEIGHT_TOP           =
*     I_HTML_HEIGHT_END           =
*     IT_ALV_GRAPHICS             =
*     IT_EXCEPT_QINFO_LVC         =
*     IR_SALV_FULLSCREEN_ADAPTER  =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER     =
*     ES_EXIT_CAUSED_BY_USER      =
    TABLES
      t_outtab                    = <fs_tabla>
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.
  IF sy-subrc <> 0. ENDIF.
ENDFORM.                    " f_listar_datos

*===================================================================================================
*& Form f_listar_datos_mapping
*===================================================================================================
FORM f_listar_datos_mapping  TABLES   lit_fieldcatalog TYPE         lvc_t_fcat.
*===================================================================================================
* 0.- Declaración de variables
*===================================================================================================
  DATA: wa_fieldcatalog TYPE LINE OF lvc_t_fcat,
        ld_index        LIKE sy-tabix.

*===================================================================================================
* 1.- Lógica
*===================================================================================================
  LOOP AT lit_fieldcatalog INTO wa_fieldcatalog.
    ld_index = sy-tabix.

    CASE wa_fieldcatalog-fieldname.
      WHEN 'SEL'.
        DELETE lit_fieldcatalog INDEX ld_index.
        CONTINUE.
      WHEN 'FTRAN'.
        wa_fieldcatalog-reptext    = 'Fecha'.
        wa_fieldcatalog-scrtext_l  = 'Fecha'.
        wa_fieldcatalog-scrtext_m  = 'Fecha'.
        wa_fieldcatalog-scrtext_s  = 'Fecha'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C711'.
      WHEN 'MES'.
        wa_fieldcatalog-reptext    = 'Mes'.
        wa_fieldcatalog-scrtext_l  = 'Mes'.
        wa_fieldcatalog-scrtext_m  = 'Mes'.
        wa_fieldcatalog-scrtext_s  = 'Mes'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C711'.
      WHEN 'ANYO'.
        wa_fieldcatalog-reptext    = 'Año'.
        wa_fieldcatalog-scrtext_l  = 'Año'.
        wa_fieldcatalog-scrtext_m  = 'Año'.
        wa_fieldcatalog-scrtext_s  = 'Año'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C711'.
      WHEN 'RESPO'.
        wa_fieldcatalog-reptext    = 'Responsable'.
        wa_fieldcatalog-scrtext_l  = 'Responsable'.
        wa_fieldcatalog-scrtext_m  = 'Responsable'.
        wa_fieldcatalog-scrtext_s  = 'Responsable'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C311'.
      WHEN 'CATE1'.
        wa_fieldcatalog-reptext    = 'Categoría 1'.
        wa_fieldcatalog-scrtext_l  = 'Categoría 1'.
        wa_fieldcatalog-scrtext_m  = 'Categoría 1'.
        wa_fieldcatalog-scrtext_s  = 'Categoría 1'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C511'.
      WHEN 'CATE2'.
        wa_fieldcatalog-reptext    = 'Categoría 2'.
        wa_fieldcatalog-scrtext_l  = 'Categoría 2'.
        wa_fieldcatalog-scrtext_m  = 'Categoría 2'.
        wa_fieldcatalog-scrtext_s  = 'Categoría 2'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C511'.
      WHEN 'CATE3'.
        wa_fieldcatalog-reptext    = 'Categoría 3'.
        wa_fieldcatalog-scrtext_l  = 'Categoría 3'.
        wa_fieldcatalog-scrtext_m  = 'Categoría 3'.
        wa_fieldcatalog-scrtext_s  = 'Categoría 3'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C511'.
      WHEN 'OUTFL'.
        wa_fieldcatalog-reptext    = 'Outflow'.
        wa_fieldcatalog-scrtext_l  = 'Outflow'.
        wa_fieldcatalog-scrtext_m  = 'Outflow'.
        wa_fieldcatalog-scrtext_s  = 'Outflow'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-no_zero    = 'X'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'OUTFR'.
        wa_fieldcatalog-reptext    = 'Outflow Real'.
        wa_fieldcatalog-scrtext_l  = 'Outflow Real'.
        wa_fieldcatalog-scrtext_m  = 'Outflow Real'.
        wa_fieldcatalog-scrtext_s  = 'Outflow Real'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-no_zero    = 'X'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'INFLO'.
        wa_fieldcatalog-reptext    = 'Inflow'.
        wa_fieldcatalog-scrtext_l  = 'Inflow'.
        wa_fieldcatalog-scrtext_m  = 'Inflow'.
        wa_fieldcatalog-scrtext_s  = 'Inflow'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-no_zero    = 'X'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'WAERS'.
        wa_fieldcatalog-reptext    = 'Moneda'.
        wa_fieldcatalog-scrtext_l  = 'Mon.'.
        wa_fieldcatalog-scrtext_m  = 'Mon.'.
        wa_fieldcatalog-scrtext_s  = 'Mon.'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'IMPORT'.
        wa_fieldcatalog-reptext    = 'Importado'.
        wa_fieldcatalog-scrtext_l  = 'Import'.
        wa_fieldcatalog-scrtext_m  = 'Import'.
        wa_fieldcatalog-scrtext_s  = 'Import'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = 'C'.
        wa_fieldcatalog-icon       = 'X'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'CONSOL'.
        wa_fieldcatalog-reptext    = 'Consolidado'.
        wa_fieldcatalog-scrtext_l  = 'Consol'.
        wa_fieldcatalog-scrtext_m  = 'Consol'.
        wa_fieldcatalog-scrtext_s  = 'Consol'.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = 'C'.
        wa_fieldcatalog-checkbox   = 'X'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'DELE'.
        wa_fieldcatalog-reptext    = 'Borrar Gasto'.
        wa_fieldcatalog-scrtext_l  = 'BG'.
        wa_fieldcatalog-scrtext_m  = 'BG'.
        wa_fieldcatalog-scrtext_s  = 'BG'.
        wa_fieldcatalog-hotspot    = 'X'.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = 'C'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'GC'.
        wa_fieldcatalog-reptext    = 'Gasto Compartido'.
        wa_fieldcatalog-scrtext_l  = 'GC'.
        wa_fieldcatalog-scrtext_m  = 'GC'.
        wa_fieldcatalog-scrtext_s  = 'GC'.
        wa_fieldcatalog-hotspot    = 'X'.
        wa_fieldcatalog-icon       = 'X'.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = 'C'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN 'GNC'.
        wa_fieldcatalog-reptext    = 'Gasto NO Compartido'.
        wa_fieldcatalog-scrtext_l  = 'GNC'.
        wa_fieldcatalog-scrtext_m  = 'GNC'.
        wa_fieldcatalog-scrtext_s  = 'GNC'.
        wa_fieldcatalog-hotspot    = 'X'.
        wa_fieldcatalog-icon       = 'X'.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = 'C'.
        wa_fieldcatalog-emphasize  = 'C411'.
      WHEN ''.
        wa_fieldcatalog-reptext    = ''.
        wa_fieldcatalog-scrtext_l  = ''.
        wa_fieldcatalog-scrtext_m  = ''.
        wa_fieldcatalog-scrtext_s  = ''.
        wa_fieldcatalog-hotspot    = ''.
        wa_fieldcatalog-icon       = ''.
        wa_fieldcatalog-edit       = ''.
        wa_fieldcatalog-just       = ''.
        wa_fieldcatalog-emphasize  = 'C411'.
    ENDCASE.

    MODIFY lit_fieldcatalog FROM wa_fieldcatalog.
  ENDLOOP.
ENDFORM.

*===================================================================================================
*&      Form   f_status_monitor
*===================================================================================================
FORM f_status_monitor USING extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS_MONITOR'.
ENDFORM.                    "F_STATUS_S02

*===================================================================================================
*&      Form   f_ucomm_monitor
*===================================================================================================
FORM f_ucomm_monitor USING pe_ucomm   LIKE sy-ucomm
                                   rs_selfield TYPE slis_selfield.

* 0.- Declaración de variables
*===================================================================================================
  DATA: ref_grid TYPE REF TO cl_gui_alv_grid,
        BEGIN OF lit_fichero OCCURS 0,
          linea TYPE string,
        END OF lit_fichero,
        ld_respuesta,
        lit_zretaps001t01 LIKE zretaps001t01 OCCURS 0 WITH HEADER LINE.

* 1.- Lógica
*===================================================================================================
  DATA: l_valid TYPE c.

  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.

* Code to reflect the changes done in the internal table
  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data
      IMPORTING
        e_valid = l_valid.
  ENDIF.

  IF l_valid = 'X'.
    CASE pe_ucomm.
      WHEN '&IC1'.
        READ TABLE git_monitor INDEX rs_selfield-tabindex.

        CASE rs_selfield-fieldname.
          WHEN 'DELE'.
            IF git_monitor-import IS INITIAL AND git_monitor-consol = ''.
              DELETE git_monitor INDEX rs_selfield-tabindex.

              DELETE FROM zretaps001t01 WHERE idgas = git_monitor-idgas.

              MESSAGE 'Gasto borrado' TYPE 'S'.
            ELSE.
              IF git_monitor-import IS NOT INITIAL.
                MESSAGE 'Gasto sin grabar en sistema' TYPE 'S' DISPLAY LIKE 'E'.
              ELSEIF git_monitor-consol IS NOT INITIAL.
                MESSAGE 'Gasto consolidado en sistema. en sistema' TYPE 'S' DISPLAY LIKE 'E'.
              ENDIF.
            ENDIF.
          WHEN 'GC'.
            IF git_monitor-import = ''.
              git_monitor-outfr = git_monitor-outfl / 2.
              MODIFY git_monitor INDEX rs_selfield-tabindex.

              UPDATE zretaps001t01 SET outfr = git_monitor-outfr WHERE idgas = git_monitor-idgas.

              MESSAGE 'Gasto compartido' TYPE 'S'.
            ENDIF.
          WHEN 'GNC'.
            IF git_monitor-import = ''.
              git_monitor-outfr = git_monitor-outfl.
              MODIFY git_monitor INDEX rs_selfield-tabindex.

              UPDATE zretaps001t01 SET outfr = git_monitor-outfr WHERE idgas = git_monitor-idgas.

              MESSAGE 'Gasto no compartido' TYPE 'S'.
            ENDIF.
        ENDCASE.
      WHEN 'IMPORT'.
        PERFORM f_ucomm_monitor_import.
      WHEN 'SAVE'.
        LOOP AT git_monitor WHERE import IS NOT INITIAL.

          CLEAR lit_zretaps001t01.

          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr             = '01'
              object                  = 'ZRETAPS001'
*             QUANTITY                = '1'
*             SUBOBJECT               = ' '
*             TOYEAR                  = '0000'
*             IGNORE_BUFFER           = ' '
            IMPORTING
              number                  = git_monitor-idgas
*             QUANTITY                =
*             RETURNCODE              =
            EXCEPTIONS
              interval_not_found      = 1
              number_range_not_intern = 2
              object_not_found        = 3
              quantity_is_0           = 4
              quantity_is_not_1       = 5
              interval_overflow       = 6
              buffer_overflow         = 7
              OTHERS                  = 8.
          IF sy-subrc <> 0.  ENDIF.

          MOVE-CORRESPONDING git_monitor TO lit_zretaps001t01.
          APPEND lit_zretaps001t01.

          git_monitor-import = ''.
          git_monitor-gc = gc_icono_compartido.
          git_monitor-gnc = gc_icono_nocompartido.
          git_monitor-dele = gc_icono_papelera.

          MODIFY git_monitor.
        ENDLOOP.

        INSERT zretaps001t01 FROM TABLE lit_zretaps001t01.
      WHEN 'CONSOLIDAR'.
        PERFORM f_popup_to_confirm
          USING
            '¿Consolidar gastos seleccionados?'
          CHANGING
            ld_respuesta.

        IF ld_respuesta <> '1'.
          EXIT.
        ENDIF.

        LOOP AT git_monitor WHERE sel = 'X' AND import = '' AND consol = ''.
          CLEAR: git_monitor-dele,
                 git_monitor-gc,
                 git_monitor-gnc.

          git_monitor-consol = 'X'.

          UPDATE zretaps001t01 SET consol = 'X' WHERE idgas =  git_monitor-idgas.
          COMMIT WORK AND WAIT.

          MODIFY git_monitor.
        ENDLOOP.
      WHEN 'EXCEL'.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
*           BIN_FILESIZE                    =
            filename                        = 'C:\Users\telem\Desktop\Download.txt'
*           FILETYPE                        = 'ASC'
*           APPEND                          = ' '
*           WRITE_FIELD_SEPARATOR           = ' '
*           HEADER                          = '00'
*           TRUNC_TRAILING_BLANKS           = ' '
*           WRITE_LF                        = 'X'
*           COL_SELECT                      = ' '
*           COL_SELECT_MASK                 = ' '
*           DAT_MODE                        = ' '
*           CONFIRM_OVERWRITE               = ' '
*           NO_AUTH_CHECK                   = ' '
*           CODEPAGE                        = ' '
*           IGNORE_CERR                     = ABAP_TRUE
*           REPLACEMENT                     = '#'
*           WRITE_BOM                       = ' '
*           TRUNC_TRAILING_BLANKS_EOL       = 'X'
*           WK1_N_FORMAT                    = ' '
*           WK1_N_SIZE                      = ' '
*           WK1_T_FORMAT                    = ' '
*           WK1_T_SIZE                      = ' '
*           WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*           SHOW_TRANSFER_STATUS            = ABAP_TRUE
*           VIRUS_SCAN_PROFILE              = '/SCET/GUI_DOWNLOAD'
*         IMPORTING
*           FILELENGTH                      =
          tables
            data_tab                        = git_monitor
*           FIELDNAMES                      =
         EXCEPTIONS
           FILE_WRITE_ERROR                = 1
           NO_BATCH                        = 2
           GUI_REFUSE_FILETRANSFER         = 3
           INVALID_TYPE                    = 4
           NO_AUTHORITY                    = 5
           UNKNOWN_ERROR                   = 6
           HEADER_NOT_ALLOWED              = 7
           SEPARATOR_NOT_ALLOWED           = 8
           FILESIZE_NOT_ALLOWED            = 9
           HEADER_TOO_LONG                 = 10
           DP_ERROR_CREATE                 = 11
           DP_ERROR_SEND                   = 12
           DP_ERROR_WRITE                  = 13
           UNKNOWN_DP_ERROR                = 14
           ACCESS_DENIED                   = 15
           DP_OUT_OF_MEMORY                = 16
           DISK_FULL                       = 17
           DP_TIMEOUT                      = 18
           FILE_NOT_FOUND                  = 19
           DATAPROVIDER_EXCEPTION          = 20
           CONTROL_FLUSH_ERROR             = 21
           OTHERS                          = 22
                  .
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.


      WHEN 'EXCEL_UP'.
    ENDCASE.

  ENDIF.
ENDFORM.

FORM f_popup_to_confirm  USING    pe_pregunta
                         CHANGING ps_respuesta.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
*     TITLEBAR       = ' '
*     DIAGNOSE_OBJECT             = ' '
      text_question  = pe_pregunta
*     TEXT_BUTTON_1  = 'Ja'(001)
*     ICON_BUTTON_1  = ' '
*     TEXT_BUTTON_2  = 'Nein'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = ps_respuesta
*   TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0. ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_excel_import
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GIT_EXCEL_IMPORT
*&      --> P_FILE
*&---------------------------------------------------------------------*
FORM f_excel_import  TABLES   git_excel_import STRUCTURE zretaps001s02
                     USING    pe_file.

  DATA: lr_ref_data         TYPE REF TO data,
        lit_worksheet_names TYPE if_fdt_doc_spreadsheet=>t_worksheet_names WITH HEADER LINE,
        lit_data_tab        TYPE TABLE OF raw255,
        lo_excel            TYPE REF TO cl_fdt_xl_spreadsheet,
        ld_document_name    TYPE string,
        ld_filelength       TYPE i,
        ld_file_xstring     TYPE xstring.

  FIELD-SYMBOLS: <fs_tabla_excel> TYPE ANY TABLE,
                 <fs_linea_excel> TYPE any,
                 <fs_valor>       TYPE any.

  ld_document_name = pe_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = ld_document_name
      filetype                = 'BIN'
*     has_field_separator     = SPACE
*     header_length           = 0
*     read_by_line            = 'X'
*     dat_mode                = SPACE
*     codepage                = SPACE
*     ignore_cerr             = ABAP_TRUE
*     replacement             = '#'
*     virus_scan_profile      =
    IMPORTING
      filelength              = ld_filelength
*     header                  =
    CHANGING
      data_tab                = lit_data_tab
*     isscanperformed         = SPACE
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
  ENDIF.


  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = ld_filelength
*     FIRST_LINE   = 0
*     LAST_LINE    = 0
    IMPORTING
      buffer       = ld_file_xstring
    TABLES
      binary_tab   = lit_data_tab
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  TRY.
      CREATE OBJECT lo_excel
        EXPORTING
          document_name = ld_document_name
          xdocument     = ld_file_xstring
*         mime_type     =
        .
    CATCH cx_fdt_excel_core .
      BREAK-POINT.
  ENDTRY.

  CALL METHOD lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names
    IMPORTING
      worksheet_names = lit_worksheet_names[].

  READ TABLE lit_worksheet_names INDEX 1.

  CALL METHOD lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet
    EXPORTING
      worksheet_name = lit_worksheet_names
*     iv_caller      =
*     iv_get_language =
    RECEIVING
      itab           = lr_ref_data.
  .

  ASSIGN lr_ref_data->* TO <fs_tabla_excel>.

  LOOP AT <fs_tabla_excel> ASSIGNING <fs_linea_excel>.
    IF sy-tabix = 1.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'A' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col01 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'B' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col02 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'C' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col03 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'D' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col04 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'E' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col05 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'F' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col06 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'G' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col07 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'H' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col08 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'I' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col09 = <fs_valor>.
    ENDIF.

    ASSIGN COMPONENT 'J' OF STRUCTURE <fs_linea_excel> TO <fs_valor>.

    IF sy-subrc = 0.
      git_excel_import-col10 = <fs_valor>.
    ENDIF.

    APPEND git_excel_import.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form f_ucomm_monitor_import
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_ucomm_monitor_import .
  DATA: ld_file_pc LIKE rlgrap-filename,
        ld_dia(2),
        ld_mes(2),
        ld_ano(4).

  PERFORM f_get_file_pc CHANGING ld_file_pc.

  PERFORM f_excel_import TABLES git_excel_import USING ld_file_pc.

  LOOP AT git_excel_import.
    CLEAR git_monitor.

    git_monitor-import = gc_icono_crear.
    SPLIT git_excel_import-col01 AT '/' INTO ld_dia ld_mes ld_ano.
    UNPACK ld_mes TO ld_mes.
    UNPACK ld_dia TO ld_dia.
    CONCATENATE ld_ano ld_mes ld_dia INTO git_monitor-ftran.
    git_monitor-mes = ld_mes.
    git_monitor-anyo = ld_ano.
    CONCATENATE ld_ano ld_mes ld_dia INTO git_monitor-ftran.
    git_monitor-cate3 = git_excel_import-col03.
    git_monitor-outfl = git_excel_import-col04.
    IF  git_monitor-outfl > 0.
      CLEAR git_monitor-outfl.
      git_monitor-inflo = git_excel_import-col04.
    ELSE.
      git_monitor-outfr = git_excel_import-col04.
    ENDIF.

    git_monitor-dele = gc_icono_papelera.
    git_monitor-gc = gc_icono_compartido.
    git_monitor-gnc = gc_icono_nocompartido.
    git_monitor-waers = 'EUR'.
    APPEND git_monitor.

  ENDLOOP.
ENDFORM.
