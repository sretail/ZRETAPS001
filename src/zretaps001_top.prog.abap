*&---------------------------------------------------------------------*
*& Include          ZRETAPS001_TOP
*&---------------------------------------------------------------------*
tables: zretaps001t01.

*===================================================================================================
* CONSTANTES
*===================================================================================================
CONSTANTS: gc_semaforo_verde        TYPE icon_d VALUE '@08@',
           gc_semaforo_ambar        TYPE icon_d VALUE '@09@',
           gc_semaforo_rojo         TYPE icon_d VALUE '@0A@',
           gc_semaforo_inactivo     TYPE icon_d VALUE '@EB@',
           gc_minisemaforo_verde    TYPE icon_d VALUE '@5B@',
           gc_minisemaforo_ambar    TYPE icon_d VALUE '@5D@',
           gc_minisemaforo_rojo     TYPE icon_d VALUE '@5C@',
           gc_minisemaforo_inactivo TYPE icon_d VALUE '@BZ@',
           gc_icono_warning         type icon_d value '@1A@',
           gc_icono_detalle         TYPE icon_d VALUE '@FB@',
           gc_icono_papelera        TYPE icon_d VALUE '@11@',
           gc_icono_okay            TYPE icon_d VALUE '@0V@',
           gc_icono_crear           TYPE icon_d VALUE '@0Y@',
           gc_icono_modif           TYPE icon_d VALUE '@0Z@',
           gc_icono_compartido      type icon_d value '@92@',
           gc_icono_nocompartido    type icon_d value '@AW@'.

*===================================================================================================
* DEFINICIONES GLOBALES
*===================================================================================================
data: git_monitor       type ZRETAPS001S01 occurs 0 WITH HEADER LINE,
      git_excel_import  type ZRETAPS001S02 OCCURS 0 WITH HEADER LINE.
