* @ValidationCode : MjotMjA4ODc0ODUxNDpDcDEyNTI6MTU3MDU5OTc4NDU0NDpNT1JUT1pBOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjE5X1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Oct 2019 11:43:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : MORTOZA
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R19_SP3.0
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE BD.BB.SECTOR
*-----------------------------------------------------------------------------
* Developed By : Md. Sarowar Mortoza
*                FDS Pvt Ltd
*                09/10/2019
*<doc>
* TODO add a description of the application here.
* @author mortoza@datasoft-bd.com
* @stereotype H type template Application
* @package TODO define the product group and product, e.g. infra.eb
* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 19/10/07 - EN_10003543
*            New Template changes
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'BD.BB.SECTOR'        ;* Full application name including product prefix
    Table.title = 'BD BB.SECTOR'       ;* Screen title
    Table.stereotype = 'H'    ;* H, U, L, W or T
    Table.product = 'EB'      ;* Must be on EB.PRODUCT
    Table.subProduct = ''     ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'        ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y'         ;* As per FILE.CONTROL
    Table.relatedFiles = ''   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''        ;* As per FILE.CONTROL
    Table.equatePrefix = 'BB.SECTOR'        ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = ''         ;* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
