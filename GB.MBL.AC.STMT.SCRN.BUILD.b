* @ValidationCode : MjoxMzY0NDQxMjA5OkNwMTI1MjoxNTkzOTczMzI0OTY3OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Jul 2020 00:22:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
*--------------------------------------------------------------------------
* <Rating>-67</Rating>
*--------------------------------------------------------------------------
SUBROUTINE GB.MBL.AC.STMT.SCRN.BUILD(ENQ.DATA)
*--------------------------------------------------------------------------
* MODIFICATION HISTORY:
************************
* 25/10/11 - En- 99120 / Task - 156274
*            Improvement odf stmt.enquiries
*
* 20/12/11 - Defect 325533 / Task 327440
*            Changes done to fetch past account.statement
*
* 08/08/13 - Defect 748536 / Task 752582
*            Amended the enquiry selection intead of replacing new selection criteria using INS
*            to solve the mandatory selection field missing while trying to server print in the desktop.
*
* 26/09/13 - Defect 748536 / Task 794439
*            Wrong entry displayed in the enquiry for the STMT.DATE inputted this is due to the wrong position of the
*            REQUESTED.DATE from the ENQ.DATA.
*
* 13/03/14 - Defect 929011 / TASK 939224
*            For HVT accounts call the core API EB.READ.HVT to get the merged information
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 12/08/15 - Defect - 1432048 / Task 1436284
*            Done the changes to display Balance brought forward when there is not entries for that date.
*
* 10/09/15 - Defect 1432048/Task 1465432
*            Passing NULL value to PROCESSING.DATE instead of space.
*
* 08/12/16 - Defect 1937970 / Task 1949261
*            Pass ACCOUNT.NUMBER<2> as PROCESS, to get the entries with
*            processing date as greater than booking date (Ex: vd system)
*
*--------------------------------------------------------------------------

    $USING AC.HighVolume
    $USING EB.API
    $USING EB.SystemTables
    $USING ST.AccountStatement

*--------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB FORM.ENQ.DATA
    
    Y.DATA = 'ENQ.DATA=':ENQ.DATA
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'AMC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
RETURN
*--------------------------------------------------------------------------
INITIALISE:
*---------

    R.ACCT.STMT.PRINT = ''
    TEMP.ENQ.DATA = ''

RETURN
*--------------------------------------------------------------------------
FORM.ENQ.DATA:
*------------
***
* ENQ.DATA assigned to the TEMP.ENQ.DATA and inserted the build routine selection fields
* after the related user level selection field in the TEMP.ENQ.DATA
* and finally assigned the TEMP.ENQ.DATA to the ENQ.DATA.

    TEMP.ENQ.DATA = ENQ.DATA
    LOCATE "SELECT.ACCOUNT" IN TEMP.ENQ.DATA<2,1> SETTING AC.POS THEN
        INS "ACCT.ID" BEFORE TEMP.ENQ.DATA<2,AC.POS+1>
        INS "EQ" BEFORE TEMP.ENQ.DATA<3,AC.POS+1>
        INS ENQ.DATA<4,AC.POS> BEFORE TEMP.ENQ.DATA<4,AC.POS+1>
    END

    LOCATE "STMT.DATE" IN TEMP.ENQ.DATA<2,1> SETTING DATE.POS THEN
        INS "PROCESSING.DATE" BEFORE TEMP.ENQ.DATA<2,DATE.POS+1>
    END

    ACCOUNT.ID = TEMP.ENQ.DATA<4,AC.POS>

    REQUESTED.DATE = TEMP.ENQ.DATA<4,DATE.POS>
    IF REQUESTED.DATE[1,1] = "!" THEN
        REQUESTED.DATE = EB.SystemTables.getToday()
    END

    GOSUB GET.DATES

    IF NOT(START.DATE) THEN
        INS "LE" BEFORE  TEMP.ENQ.DATA<3,DATE.POS+1>
        INS END.DATE BEFORE TEMP.ENQ.DATA<4,DATE.POS+1>
    END ELSE
        GOSUB CHECK.IF.MVMT.EXISTS
    END

    ENQ.DATA = TEMP.ENQ.DATA

    Y.DATA = 'E.AC.STMT.SCRN.BUILD.RPT=':'*':'ENQ.DATA=':ENQ.DATA
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'AMC'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END

RETURN
*
*--------------------------------------------------------------------------
GET.DATES:
*--------------
* Call EB.READ.HVT which has internal check for HVT processing and returns the requiered record
* either notinaly merged data for HVT accounts or direct read to the file for non HVT accounts
    R.ACCT.STMT.PRINT = ""
    AC.HighVolume.EbReadHvt('ACCT.STMT.PRINT', ACCOUNT.ID, R.ACCT.STMT.PRINT, '')      ;* Call the core api to get the merged info for HVT accounts

    Y.DATES = FIELDS(R.ACCT.STMT.PRINT , "/",1)
    CONVERT @VM TO @FM IN Y.DATES

    LOCATE REQUESTED.DATE IN Y.DATES BY "AR" SETTING POS ELSE
        NULL
    END

    END.DATE   = FIELD(R.ACCT.STMT.PRINT<POS>,"/",1,1)
    START.DATE = FIELD(R.ACCT.STMT.PRINT<POS-1>,"/",1,1)

    IF START.DATE THEN
        EB.API.Cdt('', START.DATE, '+1C')
    END

RETURN
*--------------------------------------------------------------------------
CHECK.IF.MVMT.EXISTS:
*********************
* Check whether any transaction exists within the statement period if so then modify the selection so that
* core routine will form dummy entry.
*
    ACCOUNT.NUMBER = ACCOUNT.ID
    ENTRY.LIST = ''
    OPENING.BAL = ''
    ER = ''

* ACCOUNT.STATEMENT related files such as ACCT.STMT.PRINT , STMT.PRINTED is updated based on
* processing date. Hence call EB.ACCT.ENTRY.LIST with ACCOUNT.NUMBER<2> as PROCESS, to fetch
* the entries based on processing date. This will ensure even the future value dated entries
* which falls on next statement cycle is displayed correctly.

    ACCOUNT.NUMBER<2> = "PROCESS"
    ST.AccountStatement.EbAcctEntryList(ACCOUNT.NUMBER,START.DATE,END.DATE,ENTRY.LIST,OPENING.BAL,ER)

    IF NOT(ENTRY.LIST) THEN
        TEMP.ENQ.DATA<3,DATE.POS+1> = 'EQ'
        TEMP.ENQ.DATA<4,DATE.POS+1> = ""
    END ELSE
        INS "RG" BEFORE  TEMP.ENQ.DATA<3,DATE.POS+1>
        INS START.DATE:@SM:END.DATE BEFORE TEMP.ENQ.DATA<4,DATE.POS+1>
    END

RETURN
*------------------------------------------------------------------------
END
